-- Function to extract title from a website URL
function extract_website_title(url)
    if not url:match("^https?://") then
        vim.notify("Invalid URL format. URL must start with http:// or https://", vim.log.levels.ERROR)
        return nil
    end

    -- Use curl to fetch the webpage content with proper headers
    local handle = io.popen('curl -L -s ' .. url)
    if not handle then
        vim.notify("Failed to execute curl command", vim.log.levels.ERROR)
        return nil
    end

    local html = handle:read("*a")
    handle:close()

    -- Extract title using more robust pattern matching
    local title = html:match("<title.->(.-)</title.->")

    if not title then
        vim.notify("Could not find title tag in the webpage", vim.log.levels.WARN)
        return nil
    end

    -- Clean up the title (remove extra whitespace, HTML entities, etc.)
    title = title:gsub("&amp;", "&")
    title = title:gsub("&lt;", "<")
    title = title:gsub("&gt;", ">")
    title = title:gsub("&quot;", '"')
    title = title:gsub("&#039;", "'")
    title = title:gsub("&#39;", "'")
    title = title:gsub("%s+", " ")
    title = title:gsub("^%s*(.-)%s*$", "%1") -- trim

    return title
end

-- Function to create basic output with fallback title
local function create_embed_output(url)
    local domain = extract_website_title(url) or "Website"
    local output = {
        "### " .. domain,
        string.format('<iframe src="%s" style="width:100%%; height:500px; border:none;"></iframe>', url)
    }
    return table.concat(output, "\n")
end

-- Function to format a website URL into markdown+iframe
local function format_website_url()
    -- Save current selection to register without changing the default register
    vim.cmd('normal! "zy')

    -- Get selected text from register
    local url = vim.fn.getreg('z')

    if not url or url == "" then
        vim.notify("No text selected", vim.log.levels.ERROR)
        return
    end

    -- Basic URL validation
    if not url:match("^https?://") then
        vim.notify("Invalid URL: " .. url, vim.log.levels.ERROR)
        return
    end

    -- Create basic output with the URL as fallback title
    local output = create_embed_output(url)

    -- Replace the selection with our formatted content
    vim.fn.setreg('z', output)
    vim.cmd('normal! gv"zp')
end

return format_website_url
