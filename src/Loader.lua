-- Loader.lua
-- Lightweight loader that fetches the latest ZynoxUI core module from GitHub
-- Replace <GITHUB_USERNAME> with your actual GitHub username before publishing.

local CORE_URL = "https://raw.githubusercontent.com/<GITHUB_USERNAME>/ZynoxUI/main/src/ZynoxUI.lua"

return loadstring(game:HttpGet(CORE_URL, true))()
