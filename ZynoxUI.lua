-- ZynoxUI: Fixed & Enhanced UI Library

local ZynoxUI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Fade in animation
local function fadeIn(window, duration)
	window.BackgroundTransparency = 1
	window.Visible = true
	for i = 1, 0, -0.1 do
		window.BackgroundTransparency = i
		task.wait(duration / 10)
	end
end

-- Create main window
function ZynoxUI:CreateMainWindow(title)
	local window = Instance.new("Frame")
	window.Name = title or "ZynoxUI"
	window.Size = UDim2.new(0, 400, 0, 300)
	window.Position = UDim2.new(0.5, -200, 0.5, -150)
	window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	window.BorderSizePixel = 0
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Visible = false

	fadeIn(window, 1)

	local dragging = false
	local dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	window.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)

	window.Parent = game:GetService("CoreGui")
	return window
end

-- Create a toggle
function ZynoxUI:CreateToggle(parent, label, initialState, callback)
	local toggle = Instance.new("Frame")
	toggle.Name = label or "Toggle"
	toggle.Size = UDim2.new(0, 100, 0, 50)
	toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggle.Parent = parent

	local toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(0, 20, 0, 20)
	toggleButton.Position = UDim2.new(0, 5, 0.5, -10)
	toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	toggleButton.Text = ""
	toggleButton.Parent = toggle

	toggleButton.MouseButton1Click:Connect(function()
		initialState = not initialState
		toggleButton.BackgroundColor3 = initialState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
		if callback then callback(initialState) end
	end)

	return toggle
end

-- Create a button
function ZynoxUI:CreateButton(parent, label, callback)
	local button = Instance.new("TextButton")
	button.Name = label or "Button"
	button.Size = UDim2.new(0, 100, 0, 50)
	button.Position = UDim2.new(0.5, -50, 0.5, -25)
	button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Text = label or "Button"
	button.Parent = parent

	button.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	return button
end

-- Create a label
function ZynoxUI:CreateLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 200, 0, 50)
	label.Position = UDim2.new(0.5, -100, 0.5, -25)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = text or "Label"
	label.Parent = parent
	return label
end

-- Create a slider
function ZynoxUI:CreateSlider(parent, label, min, max, initialValue, callback)
	local sliderFrame = Instance.new("Frame")
	sliderFrame.Size = UDim2.new(0, 200, 0, 50)
	sliderFrame.Position = UDim2.new(0.5, -100, 0.5, -25)
	sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	sliderFrame.Parent = parent

	local sliderLabel = Instance.new("TextLabel")
	sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
	sliderLabel.Position = UDim2.new(0, 0, 0, 0)
	sliderLabel.BackgroundTransparency = 1
	sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	sliderLabel.Text = label or "Slider"
	sliderLabel.Parent = sliderFrame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 5)
	track.Position = UDim2.new(0, 10, 0.75, -2)
	track.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	track.BorderSizePixel = 0
	track.Parent = sliderFrame

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 10, 1.5, 0)
	knob.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	knob.Text = ""
	knob.Parent = track

	local dragging = false

	local function updateKnob(input)
		local delta = input.Position.X - track.AbsolutePosition.X
		local percent = math.clamp(delta / track.AbsoluteSize.X, 0, 1)
		local value = math.floor((min + (max - min) * percent) + 0.5)
		knob.Position = UDim2.new(percent, -5, 0.5, -5)
		if callback then callback(value) end
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateKnob(input)
		end
	end)

	-- Initial value position
	local percent = (initialValue - min) / (max - min)
	knob.Position = UDim2.new(percent, -5, 0.5, -5)
	if callback then callback(initialValue) end

	return sliderFrame
end

return ZynoxUI
