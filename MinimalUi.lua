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
