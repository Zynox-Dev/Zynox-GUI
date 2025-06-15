-- Example.lua
-- Demonstrates loading ZynoxUI through a Roblox executor.
-- Make sure you pushed the repo to GitHub and replaced <GITHUB_USERNAME> in Loader.lua.

local ZynoxUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/<GITHUB_USERNAME>/ZynoxUI/main/src/Loader.lua"))()

local window = ZynoxUI:WindowCreate("Demo Window")
window:AddButton{
    text = "Say Hello",
    callback = function()
        print("Hello from ZynoxUI!")
    end
}
