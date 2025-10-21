local M = {}

function M.pf(name)
	-- Check if the first 4 characters are "http"
	if string.sub(name, 1, 4) ~= "http" then
		name = "https://github.com/" .. name
	end
	return { src = name }
end

return M
