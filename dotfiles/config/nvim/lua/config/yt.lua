local function extract_video_id(url)
    -- Common YouTube URL patterns
    local patterns = {
        "youtube%.com/watch%?v=([%w-_]+)",   -- Standard watch URL
        "youtube%.com/watch%?.*v=([%w-_]+)", -- Watch URL with other parameters
        "youtu%.be/([%w-_]+)",               -- Short URL
        "youtube%.com/embed/([%w-_]+)",      -- Embed URL
        "youtube%.com/shorts/([%w-_]+)",     -- Shorts URL
        "youtube%.com/v/([%w-_]+)",          -- Old style embed
        "youtube%.com/.*%?.*v=([%w-_]+)"     -- Any YouTube URL with v parameter
    }

    for _, pattern in ipairs(patterns) do
        local id = string.match(url, pattern)
        if id then
            return id
        end
    end

    return nil
end

-- Function to fetch YouTube video metadata using yt-dlp
local function fetch_youtube_metadata(video_id)
    -- Check if yt-dlp is available
    local has_ytdlp = vim.fn.executable("yt-dlp") == 1

    if not has_ytdlp then
        vim.notify("Error: yt-dlp not found. Please install yt-dlp (https://github.com/yt-dlp/yt-dlp)",
            vim.log.levels.ERROR)
        return "Title not found", "Description not found"
    end

    -- Use yt-dlp to fetch metadata
    local cmd = string.format('yt-dlp --no-warnings -j "https://www.youtube.com/watch?v=%s"', video_id)
    local json_data = vim.fn.system(cmd)

    -- Check for errors
    if vim.v.shell_error ~= 0 then
        vim.notify("Error fetching video data. Make sure yt-dlp is up to date.", vim.log.levels.ERROR)
        return "Title not found", "Description not found"
    end

    -- Parse JSON properly with vim.json if available
    local title = "Title not found"
    local description = "Description not found"

    -- Try using Neovim's JSON parser first
    local ok, decoded = pcall(function()
        if vim.json and vim.json.decode then
            return vim.json.decode(json_data)
        else
            return nil
        end
    end)

    if ok and decoded and decoded.title then
        title = decoded.title
        description = decoded.description or "Description not found"
    else
        -- Fallback to improved regex approach if JSON parsing fails
        -- Parse title with improved regex
        local title_json = json_data:match('"title":%s*"(.-[^\\])"[,%s}]')
        if title_json then
            title = title_json:gsub("\\u(%x%x%x%x)", function(hex)
                local code = tonumber(hex, 16)
                return string.char(code)
            end)
            title = title:gsub("\\\"", "\"")
            title = title:gsub("\\\\", "\\")
        end

        -- Parse description with improved regex
        local desc_json = json_data:match('"description":%s*"(.-[^\\])"[,%s}]')
        if desc_json then
            description = desc_json:gsub("\\u(%x%x%x%x)", function(hex)
                local code = tonumber(hex, 16)
                return string.char(code)
            end)
            description = description:gsub("\\n", "\n")
            description = description:gsub("\\\"", "\"")
            description = description:gsub("\\\\", "\\")
        end
    end

    return title, description
end

-- Function to format a YouTube URL into markdown+iframe
local function format_youtube_url()
    -- Save current selection to register without changing the default register
    vim.cmd('normal! "zy')

    -- Get selected text from register
    local url = vim.fn.getreg('z')

    if not url or url == "" then
        vim.notify("No text selected", vim.log.levels.ERROR)
        return
    end

    -- Extract video ID
    local video_id = extract_video_id(url)
    if not video_id then
        vim.notify("No valid YouTube URL found in selection: " .. url, vim.log.levels.ERROR)
        return
    end

    -- Fetch metadata
    local title, description = fetch_youtube_metadata(video_id)

    -- Extract first line for the callout title
    local first_line = description:match("^([^\n]*)")
    local rest_of_description = description:gsub("^[^\n]*\n?", "")

    -- Create formatted description with proper indentation
    local description_lines = {}
    for line in (rest_of_description .. "\n"):gmatch("(.-)\n") do
        table.insert(description_lines, "> " .. line)
    end

    local formatted_description = table.concat(description_lines, "\n")

    local output = {
        "### " .. title,
        string.format(
            '<iframe title="%s" src="https://www.youtube.com/embed/%s?feature=oembed" height="113" width="200" allowfullscreen="" allow="fullscreen" style="aspect-ratio: 16 / 9; width: 100%%; height: 100%%;"></iframe>',
            title:gsub('"', '&quot;'), video_id),
        "",
        "> [!info]- " .. first_line,
        formatted_description,
        ""
    }

    -- Join the output into a string
    local output_str = table.concat(output, "\n")

    -- Replace the selection with our formatted content
    vim.fn.setreg('z', output_str)
    vim.cmd('normal! gv"zp')
end

return format_youtube_url

