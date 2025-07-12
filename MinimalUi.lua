--[[
    Minimal UI Library made by -calista
]]

local MinimalUI = {}
MinimalUI.__index = MinimalUI

-- Configuration
local config = {
    font = "Gotham",
    titleSize = 18,
    textSize = 14,
    cornerRadius = UDim.new(0, 6),
    
    colors = {
        background = Color3.fromRGB(30, 30, 35),
        accent = Color3.fromRGB(90, 140, 240),
        text = Color3.fromRGB(240, 240, 240),
        subText = Color3.fromRGB(180, 180, 180),
        elementBg = Color3.fromRGB(45, 45, 50),
        elementHover = Color3.fromRGB(55, 55, 60),
        success = Color3.fromRGB(100, 200, 100),
        warning = Color3.fromRGB(240, 180, 80),
        error = Color3.fromRGB(240, 90, 90)
    },
    
    icons = {
        minimize = "rbxassetid://7072719338",
        maximize = "rbxassetid://7072720870",
        close = "rbxassetid://7072725342",
        toggle_on = "rbxassetid://7072706796",
        toggle_off = "rbxassetid://7072706318",
        settings = "rbxassetid://7072721954",
        info = "rbxassetid://7072716347"
    }
}

-- Create new window
function MinimalUI.new(title, position)
    local self = setmetatable({}, MinimalUI)
    
    self.title = title or "Minimal UI"
    self.position = position or UDim2.new(0.5, -200, 0.5, -150)
    self.size = UDim2.new(0, 400, 0, 300)
    self.minimized = false
    self.elements = {}
    
    -- Create main UI
    self:CreateUI()
    
    return self
end

-- Create the main UI frame
function MinimalUI:CreateUI()
    -- ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "MinimalUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    self.main = Instance.new("Frame")
    self.main.Name = "Main"
    self.main.Size = self.size
    self.main.Position = self.position
    self.main.BackgroundColor3 = config.colors.background
    self.main.BorderSizePixel = 0
    self.main.ClipsDescendants = true
    self.main.Parent = self.gui
    
    -- Apply corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = config.cornerRadius
    corner.Parent = self.main
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = self.main
    
    -- Titlebar
    self.titlebar = Instance.new("Frame")
    self.titlebar.Name = "Titlebar"
    self.titlebar.Size = UDim2.new(1, 0, 0, 40)
    self.titlebar.BackgroundColor3 = config.colors.background
    self.titlebar.BorderSizePixel = 0
    self.titlebar.Parent = self.main
    
    -- Title
    self.titleLabel = Instance.new("TextLabel")
    self.titleLabel.Name = "Title"
    self.titleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Font = Enum.Font[config.font]
    self.titleLabel.TextSize = config.titleSize
    self.titleLabel.TextColor3 = config.colors.text
    self.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.titleLabel.Text = self.title
    self.titleLabel.Parent = self.titlebar
    
    -- Close Button
    self.closeBtn = self:CreateIconButton(self.titlebar, config.icons.close, UDim2.new(1, -30, 0.5, -10), function()
        self.gui:Destroy()
    end)
    
    -- Minimize Button
    self.minimizeBtn = self:CreateIconButton(self.titlebar, config.icons.minimize, UDim2.new(1, -60, 0.5, -10), function()
        self:ToggleMinimize()
    end)
    
    -- Content Container
    self.container = Instance.new("ScrollingFrame")
    self.container.Name = "Container"
    self.container.Size = UDim2.new(1, 0, 1, -40)
    self.container.Position = UDim2.new(0, 0, 0, 40)
    self.container.BackgroundTransparency = 1
    self.container.BorderSizePixel = 0
    self.container.ScrollBarThickness = 4
    self.container.ScrollBarImageColor3 = config.colors.accent
    self.container.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.container.Parent = self.main
    
    -- Add padding to container
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = self.container
    
    -- Add list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = self.container
    
    -- Make titlebar draggable
    self:MakeDraggable(self.titlebar, self.main)
    
    -- Add to game
    self.gui.Parent = game:GetService("CoreGui")
end

-- Create icon button helper
function MinimalUI:CreateIconButton(parent, iconId, position, callback)
    local button = Instance.new("ImageButton")
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Position = position
    button.BackgroundTransparency = 1
    button.Image = iconId
    button.ImageColor3 = config.colors.subText
    button.Parent = parent
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.ImageColor3 = config.colors.text
    end)
    
    button.MouseLeave:Connect(function()
        button.ImageColor3 = config.colors.subText
    end)
    
    -- Click callback
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Make an object draggable
function MinimalUI:MakeDraggable(dragObject, dragTarget)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = dragTarget.Position
        end
    end)
    
    dragObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging and dragInput and mousePos then
            local delta = dragInput.Position - mousePos
            dragTarget.Position = UDim2.new(
                framePos.X.Scale, 
                framePos.X.Offset + delta.X, 
                framePos.Y.Scale, 
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Toggle minimize/maximize
function MinimalUI:ToggleMinimize()
    self.minimized = not self.minimized
    
    if self.minimized then
        self.container.Visible = false
        self.main:TweenSize(UDim2.new(0, 400, 0, 40), "Out", "Quad", 0.3, true)
        self.minimizeBtn.Image = config.icons.maximize
    else
        self.main:TweenSize(self.size, "Out", "Quad", 0.3, true, function()
            self.container.Visible = true
        end)
        self.minimizeBtn.Image = config.icons.minimize
    end
end

-- Add a section to the UI
function MinimalUI:AddSection(title)
    local section = {}
    
    -- Section frame
    section.frame = Instance.new("Frame")
    section.frame.Name = title .. "Section"
    section.frame.Size = UDim2.new(1, 0, 0, 30)
    section.frame.BackgroundTransparency = 1
    section.frame.AutomaticSize = Enum.AutomaticSize.Y
    section.frame.Parent = self.container
    
    -- Section title
    section.title = Instance.new("TextLabel")
    section.title.Name = "Title"
    section.title.Size = UDim2.new(1, 0, 0, 30)
    section.title.BackgroundTransparency = 1
    section.title.Font = Enum.Font[config.font]
    section.title.TextSize = config.titleSize - 2
    section.title.TextColor3 = config.colors.accent
    section.title.TextXAlignment = Enum.TextXAlignment.Left
    section.title.Text = title
    section.title.Parent = section.frame
    
    -- Content container
    section.container = Instance.new("Frame")
    section.container.Name = "Container"
    section.container.Size = UDim2.new(1, 0, 0, 0)
    section.container.Position = UDim2.new(0, 0, 0, 30)
    section.container.BackgroundTransparency = 1
    section.container.AutomaticSize = Enum.AutomaticSize.Y
    section.container.Parent = section.frame
    
    -- Add list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = section.container
    
    -- Add functions to section
    function section:AddButton(text, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(1, 0, 0, 36)
        button.BackgroundColor3 = config.colors.elementBg
        button.BorderSizePixel = 0
        button.Font = Enum.Font[config.font]
        button.TextSize = config.textSize
        button.TextColor3 = config.colors.text
        button.Text = text
        button.AutoButtonColor = false
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = config.cornerRadius
        corner.Parent = button
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = config.colors.elementHover
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = config.colors.elementBg
        end)
        
        -- Click callback
        button.MouseButton1Click:Connect(callback)
        
        button.Parent = section.container
        return button
    end
    
    function section:AddToggle(text, default, callback)
        local toggled = default or false
        
        -- Toggle container
        local container = Instance.new("Frame")
        container.Name = text .. "Toggle"
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundColor3 = config.colors.elementBg
        container.BorderSizePixel = 0
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = config.cornerRadius
        corner.Parent = container
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font[config.font]
        label.TextSize = config.textSize
        label.TextColor3 = config.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = container
        
        -- Toggle button
        local toggle = Instance.new("ImageButton")
        toggle.Name = "ToggleButton"
        toggle.Size = UDim2.new(0, 24, 0, 24)
        toggle.Position = UDim2.new(1, -34, 0.5, -12)
        toggle.BackgroundTransparency = 1
        toggle.Image = toggled and config.icons.toggle_on or config.icons.toggle_off
        toggle.ImageColor3 = toggled and config.colors.accent or config.colors.subText
        toggle.Parent = container
        
        -- Hover effect
        container.MouseEnter:Connect(function()
            container.BackgroundColor3 = config.colors.elementHover
        end)
        
        container.MouseLeave:Connect(function()
            container.BackgroundColor3 = config.colors.elementBg
        end)
        
        -- Toggle function
        local function updateToggle()
            toggled = not toggled
            toggle.Image = toggled and config.icons.toggle_on or config.icons.toggle_off
            toggle.ImageColor3 = toggled and config.colors.accent or config.colors.subText
            if callback then callback(toggled) end
        end
        
        -- Click events
        toggle.MouseButton1Click:Connect(updateToggle)
        container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateToggle()
            end
        end)
        
        container.Parent = section.container
        return {
            instance = container,
            setValue = function(value)
                if toggled ~= value then
                    toggled = not toggled
                    toggle.Image = toggled and config.icons.toggle_on or config.icons.toggle_off
                    toggle.ImageColor3 = toggled and config.colors.accent or config.colors.subText
                end
            end
        }
    end
    
    function section:AddSlider(text, min, max, default, callback)
        min = min or 0
        max = max or 100
        default = default or min
        
        -- Clamp default value
        default = math.clamp(default, min, max)
        
        -- Slider container
        local container = Instance.new("Frame")
        container.Name = text .. "Slider"
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundColor3 = config.colors.elementBg
        container.BorderSizePixel = 0
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = config.cornerRadius
        corner.Parent = container
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -50, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font[config.font]
        label.TextSize = config.textSize
        label.TextColor3 = config.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = container
        
        -- Value display
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(0, 40, 0, 20)
        valueLabel.Position = UDim2.new(1, -50, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Font = Enum.Font[config.font]
        valueLabel.TextSize = config.textSize
        valueLabel.TextColor3 = config.colors.accent
        valueLabel.Text = tostring(default)
        valueLabel.Parent = container
        
        -- Slider background
        local sliderBg = Instance.new("Frame")
        sliderBg.Name = "SliderBg"
        sliderBg.Size = UDim2.new(1, -20, 0, 6)
        sliderBg.Position = UDim2.new(0, 10, 0, 35)
        sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = container
        
        -- Slider background corner
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 3)
        sliderCorner.Parent = sliderBg
        
        -- Slider fill
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "SliderFill"
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = config.colors.accent
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        -- Slider fill corner
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = sliderFill
        
        -- Slider knob
        local sliderKnob = Instance.new("Frame")
        sliderKnob.Name = "SliderKnob"
        sliderKnob.Size = UDim2.new(0, 14, 0, 14)
        sliderKnob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
        sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderKnob.BorderSizePixel = 0
        sliderKnob.ZIndex = 2
        sliderKnob.Parent = sliderBg
        
        -- Slider knob corner
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(0.5, 0)
        knobCorner.Parent = sliderKnob
        
        -- Slider functionality
        local dragging = false
        
        local function updateSlider(input)
            local sizeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
            sliderKnob.Position = UDim2.new(sizeX, -7, 0.5, -7)
            
            local value = math.floor(min + ((max - min) * sizeX))
            valueLabel.Text = tostring(value)
            
            if callback then callback(value) end
        end
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        sliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        container.Parent = section.container
        return {
            instance = container,
            setValue = function(value)
                value = math.clamp(value, min, max)
                local sizeX = (value - min) / (max - min)
                sliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
                sliderKnob.Position = UDim2.new(sizeX, -7, 0.5, -7)
                valueLabel.Text = tostring(value)
            end
        }
    end
    
    function section:AddDropdown(text, options, default, callback)
        options = options or {}
        default = default or options[1] or ""
        
        -- Dropdown container
        local container = Instance.new("Frame")
        container.Name = text .. "Dropdown"
        container.Size = UDim2.new(1, 0, 0, 60)
        container.BackgroundColor3 = config.colors.elementBg
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = config.cornerRadius
        corner.Parent = container
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font[config.font]
        label.TextSize = config.textSize
        label.TextColor3 = config.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = container
        
        -- Selected option button
        local selected = Instance.new("TextButton")
        selected.Name = "Selected"
        selected.Size = UDim2.new(1, -20, 0, 30)
        selected.Position = UDim2.new(0, 10, 0, 25)
        selected.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        selected.BorderSizePixel = 0
        selected.Font = Enum.Font[config.font]
        selected.TextSize = config.textSize
        selected.TextColor3 = config.colors.text
        selected.Text = default
        selected.TextXAlignment = Enum.TextXAlignment.Left
        selected.TextTruncate = Enum.TextTruncate.AtEnd
        selected.AutoButtonColor = false
        
          -- Add padding to text
        local textPadding = Instance.new("UIPadding")
        textPadding.PaddingLeft = UDim.new(0, 10)
        textPadding.Parent = selected
        
        -- Selected corner
        local selectedCorner = Instance.new("UICorner")
        selectedCorner.CornerRadius = UDim.new(0, 4)
        selectedCorner.Parent = selected
        
        -- Dropdown arrow
        local arrow = Instance.new("ImageLabel")
        arrow.Name = "Arrow"
        arrow.Size = UDim2.new(0, 16, 0, 16)
        arrow.Position = UDim2.new(1, -26, 0.5, -8)
        arrow.BackgroundTransparency = 1
        arrow.Image = "rbxassetid://7072706318"
        arrow.ImageColor3 = config.colors.subText
        arrow.Rotation = 90
        arrow.Parent = selected
        
        -- Options container
        local optionsFrame = Instance.new("Frame")
        optionsFrame.Name = "Options"
        optionsFrame.Size = UDim2.new(1, -20, 0, #options * 30)
        optionsFrame.Position = UDim2.new(0, 10, 0, 60)
        optionsFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        optionsFrame.BorderSizePixel = 0
        optionsFrame.Visible = false
        optionsFrame.Parent = container
        
        -- Options corner
        local optionsCorner = Instance.new("UICorner")
        optionsCorner.CornerRadius = UDim.new(0, 4)
        optionsCorner.Parent = optionsFrame
        
        -- Create option buttons
        for i, option in ipairs(options) do
            local optionBtn = Instance.new("TextButton")
            optionBtn.Name = option
            optionBtn.Size = UDim2.new(1, 0, 0, 30)
            optionBtn.Position = UDim2.new(0, 0, 0, (i-1) * 30)
            optionBtn.BackgroundTransparency = 1
            optionBtn.Font = Enum.Font[config.font]
            optionBtn.TextSize = config.textSize
            optionBtn.TextColor3 = config.colors.text
            optionBtn.Text = option
            optionBtn.TextXAlignment = Enum.TextXAlignment.Left
            optionBtn.AutoButtonColor = false
            
            -- Add padding to text
            local btnPadding = Instance.new("UIPadding")
            btnPadding.PaddingLeft = UDim.new(0, 10)
            btnPadding.Parent = optionBtn
            
            -- Hover effect
            optionBtn.MouseEnter:Connect(function()
                optionBtn.BackgroundTransparency = 0.8
            end)
            
            optionBtn.MouseLeave:Connect(function()
                optionBtn.BackgroundTransparency = 1
            end)
            
            -- Click event
            optionBtn.MouseButton1Click:Connect(function()
                selected.Text = option
                optionsFrame.Visible = false
                container.Size = UDim2.new(1, 0, 0, 60)
                arrow.Rotation = 90
                if callback then callback(option) end
            end)
            
            optionBtn.Parent = optionsFrame
        end
        
        -- Toggle dropdown
        local dropdownOpen = false
        
        selected.MouseButton1Click:Connect(function()
            dropdownOpen = not dropdownOpen
            optionsFrame.Visible = dropdownOpen
            
            if dropdownOpen then
                container.Size = UDim2.new(1, 0, 0, 60 + optionsFrame.Size.Y.Offset)
                arrow.Rotation = -90
            else
                container.Size = UDim2.new(1, 0, 0, 60)
                arrow.Rotation = 90
            end
        end)
        
        -- Close dropdown when clicking elsewhere
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                if dropdownOpen and (
                    mousePos.X < container.AbsolutePosition.X or
                    mousePos.Y < container.AbsolutePosition.Y or
                    mousePos.X > container.AbsolutePosition.X + container.AbsoluteSize.X or
                    mousePos.Y > container.AbsolutePosition.Y + container.AbsoluteSize.Y
                ) then
                    dropdownOpen = false
                    optionsFrame.Visible = false
                    container.Size = UDim2.new(1, 0, 0, 60)
                    arrow.Rotation = 90
                end
            end
        end)
        
        container.Parent = section.container
        return {
            instance = container,
            setValue = function(value)
                if table.find(options, value) then
                    selected.Text = value
                end
            end
        }
    end
    
    function section:AddColorPicker(text, default, callback)
        default = default or Color3.fromRGB(255, 255, 255)
        
        -- Color picker container
        local container = Instance.new("Frame")
        container.Name = text .. "ColorPicker"
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundColor3 = config.colors.elementBg
        container.BorderSizePixel = 0
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = config.cornerRadius
        corner.Parent = container
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font[config.font]
        label.TextSize = config.textSize
        label.TextColor3 = config.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = container
        
        -- Color display
        local colorDisplay = Instance.new("Frame")
        colorDisplay.Name = "ColorDisplay"
        colorDisplay.Size = UDim2.new(0, 24, 0, 24)
        colorDisplay.Position = UDim2.new(1, -34, 0.5, -12)
        colorDisplay.BackgroundColor3 = default
        colorDisplay.BorderSizePixel = 0
        colorDisplay.Parent = container
        
        -- Color display corner
        local displayCorner = Instance.new("UICorner")
        displayCorner.CornerRadius = UDim.new(0, 4)
        displayCorner.Parent = colorDisplay
        
        -- Color picker UI (simplified for this example)
        local pickerOpen = false
        local pickerUI = Instance.new("Frame")
        pickerUI.Name = "ColorPickerUI"
        pickerUI.Size = UDim2.new(0, 200, 0, 220)
        pickerUI.Position = UDim2.new(1, 10, 0, 0)
        pickerUI.BackgroundColor3 = config.colors.background
        pickerUI.BorderSizePixel = 0
        pickerUI.Visible = false
        pickerUI.ZIndex = 10
        pickerUI.Parent = container
        
        -- Picker corner
        local pickerCorner = Instance.new("UICorner")
        pickerCorner.CornerRadius = config.cornerRadius
        pickerCorner.Parent = pickerUI
        
        -- Color palette (simplified)
        local palette = Instance.new("ImageLabel")
        palette.Name = "Palette"
        palette.Size = UDim2.new(1, -20, 0, 150)
        palette.Position = UDim2.new(0, 10, 0, 10)
        palette.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        palette.BorderSizePixel = 0
        palette.Image = "rbxassetid://6523286724"
        palette.ZIndex = 11
        palette.Parent = pickerUI
        
        -- Hue slider
        local hueSlider = Instance.new("ImageLabel")
        hueSlider.Name = "HueSlider"
        hueSlider.Size = UDim2.new(1, -20, 0, 20)
        hueSlider.Position = UDim2.new(0, 10, 0, 170)
        hueSlider.BackgroundTransparency = 1
        hueSlider.Image = "rbxassetid://6523291212"
        hueSlider.ZIndex = 11
        hueSlider.Parent = pickerUI
        
        -- Hover effect
        container.MouseEnter:Connect(function()
            container.BackgroundColor3 = config.colors.elementHover
        end)
        
        container.MouseLeave:Connect(function()
            container.BackgroundColor3 = config.colors.elementBg
        end)
        
        -- Toggle color picker
        colorDisplay.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                pickerOpen = not pickerOpen
                pickerUI.Visible = pickerOpen
            end
        end)
        
        -- Close picker when clicking elsewhere
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and pickerOpen then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                if not (
                    mousePos.X >= pickerUI.AbsolutePosition.X and
                    mousePos.Y >= pickerUI.AbsolutePosition.Y and
                    mousePos.X <= pickerUI.AbsolutePosition.X + pickerUI.AbsoluteSize.X and
                    mousePos.Y <= pickerUI.AbsolutePosition.Y + pickerUI.AbsoluteSize.Y
                ) and not (
                    mousePos.X >= colorDisplay.AbsolutePosition.X and
                    mousePos.Y >= colorDisplay.AbsolutePosition.Y and
                    mousePos.X <= colorDisplay.AbsolutePosition.X + colorDisplay.AbsoluteSize.X and
                    mousePos.Y <= colorDisplay.AbsolutePosition.Y + colorDisplay.AbsoluteSize.Y
                ) then
                    pickerOpen = false
                    pickerUI.Visible = false
                end
            end
        end)
        
        -- Simplified color selection
        palette.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local relativeX = math.clamp((input.Position.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X, 0, 1)
                local relativeY = math.clamp((input.Position.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y, 0, 1)
                
                -- Sample color from palette (simplified)
                local hue = 1 - (hueSlider.ImageColor3.R + hueSlider.ImageColor3.G + hueSlider.ImageColor3.B) / 3
                local saturation = relativeX
                local value = 1 - relativeY
                
                local color = Color3.fromHSV(hue, saturation, value)
                colorDisplay.BackgroundColor3 = color
                
                if callback then callback(color) end
            end
        end)
        
        hueSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local relativeX = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
                
                -- Set hue (simplified)
                local hue = relativeX
                palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                
                -- Update color
                local saturation = 0.5
                local value = 0.5
                local color = Color3.fromHSV(hue, saturation, value)
                colorDisplay.BackgroundColor3 = color
                
                if callback then callback(color) end
            end
        end)
        
        container.Parent = section.container
        return {
            instance = container,
            setValue = function(color)
                colorDisplay.BackgroundColor3 = color
            end
        }
    end
    
    function section:AddTextbox(text, placeholder, default, callback)
        placeholder = placeholder or ""
        default = default or ""
        
        -- Textbox container
        local container = Instance.new("Frame")
        container.Name = text .. "Textbox"
        container.Size = UDim2.new(1, 0, 0, 60)
        container.BackgroundColor3 = config.colors.elementBg
        container.BorderSizePixel = 0
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = config.cornerRadius
        corner.Parent = container
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font[config.font]
        label.TextSize = config.textSize
        label.TextColor3 = config.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = container
        
        -- Textbox
        local textbox = Instance.new("TextBox")
        textbox.Name = "Input"
        textbox.Size = UDim2.new(1, -20, 0, 30)
        textbox.Position = UDim2.new(0, 10, 0, 25)
        textbox.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        textbox.BorderSizePixel = 0
        textbox.Font = Enum.Font[config.font]
        textbox.TextSize = config.textSize
        textbox.TextColor3 = config.colors.text
        textbox.PlaceholderText = placeholder
        textbox.PlaceholderColor3 = config.colors.subText
        textbox.Text = default
        textbox.ClearTextOnFocus = false
        
        -- Add padding to text
        local textPadding = Instance.new("UIPadding")
        textPadding.PaddingLeft = UDim.new(0, 10)
        textPadding.Parent = textbox
        
        -- Textbox corner
        local textboxCorner = Instance.new("UICorner")
        textboxCorner.CornerRadius = UDim.new(0, 4)
        textboxCorner.Parent = textbox
        
        -- Callback on focus lost
        textbox.FocusLost:Connect(function(enterPressed)
            if callback then callback(textbox.Text, enterPressed) end
        end)
        
        container.Parent = section.container
        return {
            instance = container,
            setValue = function(value)
                textbox.Text = value
            }
        }
    end
    
    function section:AddKeybind(text, default, callback, changedCallback)
        default = default or Enum.KeyCode.Unknown
        
        -- Keybind container
        local container = Instance.new("Frame")
        container.Name = text .. "Keybind"
        container.Size = UDim2.new(1, 0, 0, 36)
        container.BackgroundColor3 = config.colors.elementBg
        container.BorderSizePixel = 0
        
        -- Add corner radius
        local corner = Instance.new("UICorner")
        corner.CornerRadius = config.cornerRadius
        corner.Parent = container
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font[config.font]
        label.TextSize = config.textSize
        label.TextColor3 = config.colors.text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = container
        
        -- Keybind button
        local keybindBtn = Instance.new("TextButton")
        keybindBtn.Name = "KeybindButton"
        keybindBtn.Size = UDim2.new(0, 70, 0, 24)
        keybindBtn.Position = UDim2.new(1, -80, 0.5, -12)
        keybindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
        keybindBtn.BorderSizePixel = 0
        keybindBtn.Font = Enum.Font[config.font]
        keybindBtn.TextSize = config.textSize
        keybindBtn.TextColor3 = config.colors.text
        keybindBtn.Text = default ~= Enum.KeyCode.Unknown and default.Name or "None"
        keybindBtn.AutoButtonColor = false
        
        -- Keybind button corner
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = keybindBtn
        
        -- Listening for key indicator
        local listening = false
        
        -- Hover effect
        container.MouseEnter:Connect(function()
            container.BackgroundColor3 = config.colors.elementHover
        end)
        
        container.MouseLeave:Connect(function()
            container.BackgroundColor3 = config.colors.elementBg
        end)
        
        -- Button click to start listening
        keybindBtn.MouseButton1Click:Connect(function()
            listening = true
            keybindBtn.Text = "..."
        end)
        
        -- Key detection
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                
                local key = input.KeyCode
                keybindBtn.Text = key.Name
                
                if changedCallback then changedCallback(key) end
            elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode.Name == keybindBtn.Text then
                    if callback then callback() end
                end
            end
        end)
        
        container.Parent = section.container
        return {
            instance = container,
            setValue = function(key)
                keybindBtn.Text = key.Name
            }
        }
    end
    
    function section:AddLabel(text)
        -- Label container
        local container = Instance.new("Frame")
        container.Name = "Label"
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        
        -- Label
        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font[config.font]
        label.TextSize = config.textSize
        label.TextColor3 = config.colors.subText
        label.Text = text
        label.TextWrapped = true
        label.Parent = container
        
        container.Parent = section.container
        return {
            instance = container,
            setText = function(newText)
                label.Text = newText
            end
        }
    end
    
    return section
end

-- Add notification system
function MinimalUI:CreateNotification(title, message, duration, type)
    title = title or "Notification"
    message = message or ""
    duration = duration or 3
    type = type or "info" -- info, success, warning, error
    
    -- Determine color based on type
    local typeColor
    if type == "success" then
        typeColor = config.colors.success
    elseif type == "warning" then
        typeColor = config.colors.warning
    elseif type == "error" then
        typeColor = config.colors.error
    else
        typeColor = config.colors.accent
    end
    
    -- Create notification container
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 260, 0, 80)
    notification.Position = UDim2.new(1, 20, 0.5, -40)
    notification.BackgroundColor3 = config.colors.background
    notification.BorderSizePixel = 0
    notification.AnchorPoint = Vector2.new(0, 0.5)
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = config.cornerRadius
    corner.Parent = notification
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = -1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Parent = notification
    
    -- Colored bar
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = typeColor
    bar.BorderSizePixel = 0
    bar.Parent = notification
    
    -- Bar corner
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = bar
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 14, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font[config.font]
    titleLabel.TextSize = config.titleSize - 2
    titleLabel.TextColor3 = config.colors.text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = notification
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 1, -35)
    messageLabel.Position = UDim2.new(0, 14, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font[config.font]
    messageLabel.TextSize = config.textSize
    messageLabel.TextColor3 = config.colors.subText
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Text = message
    messageLabel.Parent = notification
    
    -- Add to screen
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "Notification"
    notifGui.ResetOnSpawn = false
    notifGui.Parent = game:GetService("CoreGui")
    notification.Parent = notifGui
    
    -- Animation
    notification:TweenPosition(UDim2.new(1, -280, 0.5, -40), "Out", "Quad", 0.4, true)
    
    -- Remove after duration
    spawn(function()
        wait(duration)
        notification:TweenPosition(UDim2.new(1, 20, 0.5, -40), "Out", "Quad", 0.4, true, function()
            notifGui:Destroy()
        end)
    end)
end

-- Return the library
return MinimalUI
