print("=== 脚本开始执行 ===")
-- 飞行脚本 with GUI
local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- 飞行状态和速度变量
local Flying = false
local FlySpeed = 50
local BodyVelocity
local BodyGyro

-- 创建主屏幕GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyGui"
ScreenGui.Parent = Player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- 主窗口
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- 标题文字
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0, 100, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "飞行控制"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.Gotham
Title.TextSize = 14
Title.Parent = TitleBar

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -25, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.Gotham
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if Flying then
        StopFlying()
    end
end)

-- 最小化按钮
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -50, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.Font = Enum.Font.Gotham
MinimizeButton.TextSize = 14
MinimizeButton.Parent = TitleBar

local Minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    if Minimized then
        -- 恢复窗口
        MainFrame.Size = UDim2.new(0, 250, 0, 150)
        Minimized = false
    else
        -- 最小化窗口
        MainFrame.Size = UDim2.new(0, 250, 0, 25)
        Minimized = true
    end
end)

-- 速度滑块
local SpeedSlider = Instance.new("Frame")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.Size = UDim2.new(0.9, 0, 0, 40)
SpeedSlider.Position = UDim2.new(0.05, 0, 0, 30)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "飞行速度: " .. FlySpeed
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.Parent = SpeedSlider

local Slider = Instance.new("Frame")
Slider.Name = "Slider"
Slider.Size = UDim2.new(1, -10, 0, 10)
Slider.Position = UDim2.new(0, 5, 0, 25)
Slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Slider.BorderSizePixel = 0
Slider.Parent = SpeedSlider

local SliderButton = Instance.new("TextButton")
SliderButton.Name = "SliderButton"
SliderButton.Size = UDim2.new(0, 15, 1, 0)
SliderButton.Position = UDim2.new((FlySpeed - 20) / 180, 0, 0, 0)
SliderButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
SliderButton.BorderSizePixel = 0
SliderButton.Text = ""
SliderButton.Parent = Slider

local SliderDragging = false
SliderButton.MouseButton1Down:Connect(function()
    SliderDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        SliderDragging = false
    end
end)

Mouse.Move:Connect(function()
    if SliderDragging then
        local X = math.clamp(Mouse.X - Slider.AbsolutePosition.X, 0, Slider.AbsoluteSize.X)
        local Ratio = X / Slider.AbsoluteSize.X
        SliderButton.Position = UDim2.new(Ratio, 0, 0, 0)
        FlySpeed = math.floor(20 + Ratio * 180)
        SpeedLabel.Text = "飞行速度: " .. FlySpeed
        
        if Flying then
            BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 飞行开关按钮
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
Toggl
