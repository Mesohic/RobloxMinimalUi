-- UI Library (uilib.lua)
local UILibrary = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Constants
local COLORS = {
    BACKGROUND = Color3.fromRGB(40, 40, 45),
    SECTION = Color3.fromRGB(35, 35, 40),
    ELEMENT = Color3.fromRGB(45, 45, 50),
    TEXT = Color3.fromRGB(240, 240, 245),
    ACCENT = Color3.fromRGB(85, 170, 255),
    TOGGLE_OFF = Color3.fromRGB(80, 80, 85),
    TOGGLE_ON = Color3.fromRGB(85, 170, 255),
    MINIMIZE = Color3.fromRGB(255, 200, 50),
    CLOSE = Color3.fromRGB(255, 80, 80)
}

local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad)

-- Utility functions
local function tween(obj, props)
    local t = TweenService:Create(obj, TWEEN_INFO, props)
    t:Play()
    return t
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.SECTION
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Create a new window
function UILibrary:CreateWindow(title)
    local window = {}
    
    -- Create GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UILibrary"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 300, 0, 350)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = COLORS.BACKGROUND
    main.BorderSizePixel = 0
    main.Parent = screenGui
    createCorner(main, 8)
    
    -- Window state properties
    window.Minimized = false
    window.ExpandedSize = main.Size
    window.MinimizedSize = UDim2.new(0, main.Size.X.Offset, 0, 40)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = COLORS.SECTION
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    createCorner(titleBar, 8)
    
    -- Fix corner overlap
    local cornerFix = Instance.new("Frame")
    cornerFix.Size = UDim2.new(1, 0, 0.5, 0)
    cornerFix.Position = UDim2.new(0, 0, 0.5, 0)
    cornerFix.BackgroundColor3 = COLORS.SECTION
    cornerFix.BorderSizePixel = 0
    cornerFix.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -120, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextColor3 = COLORS.TEXT
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Text = title or "UI Library"
    titleText.Parent = titleBar
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -70, 0, 5)
    minimizeButton.BackgroundColor3 = COLORS.MINIMIZE
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "-"
    minimizeButton.TextSize = 18
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextColor3 = COLORS.TEXT
    minimizeButton.Parent = titleBar
    createCorner(minimizeButton, 6)
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = COLORS.CLOSE
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = COLORS.TEXT
    closeButton.Parent = titleBar
    createCorner(closeButton, 6)
    
    -- Content container with scrolling
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "Content"
    scrollFrame.Size = UDim2.new(1, -20, 1, -50)
    scrollFrame.Position = UDim2.new(0, 10, 0, 45)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = COLORS.ACCENT
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
    scrollFrame.Parent = main
    
    -- Auto layout for content
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = scrollFrame
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)
    padding.Parent = scrollFrame
    
    -- Auto-update canvas size and adjust UI height
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = contentLayout.AbsoluteContentSize.Y + 10
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        
        -- Auto adjust window height based on content
        local maxHeight = workspace.CurrentCamera.ViewportSize.Y * 0.8 -- 80% of screen height
        local desiredHeight = contentHeight + 55 -- content + titlebar + padding
        local newHeight = math.min(desiredHeight, maxHeight)
        
        if not window.Minimized then
            window.ExpandedSize = UDim2.new(0, main.Size.X.Offset, 0, newHeight)
            main.Size = window.ExpandedSize
        end
    end)
    
    -- Make window draggable
    local isDragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- Button event handlers
    minimizeButton.MouseButton1Click:Connect(function()
        window:Toggle()
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Section counter for ordering
    local sectionCount = 0

    -- Mobile-friendly dragging
local dragButton = Instance.new("ImageButton")
dragButton.Size = UDim2.new(0, 30, 0, 30)
dragButton.Position = UDim2.new(1, -105, 0, 5)
dragButton.BackgroundColor3 = COLORS.SECTION
dragButton.BorderSizePixel = 0
dragButton.Image = "rbxassetid://7733715400" -- Drag handle icon (you can replace with your own)
dragButton.ImageColor3 = COLORS.TEXT
dragButton.Transparency = 0.5
dragButton.Parent = titleBar
createCorner(dragButton, 6)

-- Mobile dragging functionality
local function updateDrag(input)
    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

dragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

dragButton.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateDrag(input)
    end
end)

dragButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Make sure dragging works with touch on the entire title bar too
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)
    
    -- Create sections
    function window:Section(name)
        sectionCount = sectionCount + 1
        local section = {}
        
        -- Create section container
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Name = "Section_" .. name
        sectionFrame.Size = UDim2.new(1, -10, 0, 40) -- Initial height, will grow
        sectionFrame.BackgroundColor3 = COLORS.SECTION
        sectionFrame.BorderSizePixel = 0
        sectionFrame.LayoutOrder = sectionCount
        sectionFrame.Parent = scrollFrame
        createCorner(sectionFrame, 6)
        
        -- Section title
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Size = UDim2.new(1, -20, 0, 30)
        sectionTitle.Position = UDim2.new(0, 10, 0, 5)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Font = Enum.Font.GothamMedium
        sectionTitle.TextSize = 14
        sectionTitle.TextColor3 = COLORS.ACCENT
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Text = name or "Section"
        sectionTitle.Parent = sectionFrame
        
        -- Content layout
        local sectionLayout = Instance.new("UIListLayout")
        sectionLayout.Padding = UDim.new(0, 8)
        sectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
        sectionLayout.Parent = sectionFrame
        
        -- Padding
        local sectionPadding = Instance.new("UIPadding")
        sectionPadding.PaddingTop = UDim.new(0, 35) -- Space for title
        sectionPadding.PaddingBottom = UDim.new(0, 8)
        sectionPadding.PaddingLeft = UDim.new(0, 8)
        sectionPadding.PaddingRight = UDim.new(0, 8)
        sectionPadding.Parent = sectionFrame
        
        -- Auto-resize section based on content
        sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sectionFrame.Size = UDim2.new(1, -10, 0, sectionLayout.AbsoluteContentSize.Y + 43)
        end)
        
        -- Element counter for ordering
        local elementCount = 0
        
        -- Add toggle function
        function section:Toggle(name, default, callback)
            elementCount = elementCount + 1
            local toggle = {Value = default or false}
            
            -- Create toggle container
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = "Toggle_" .. name
            toggleFrame.Size = UDim2.new(1, 0, 0, 36)
            toggleFrame.BackgroundColor3 = COLORS.ELEMENT
            toggleFrame.BorderSizePixel = 0
            toggleFrame.LayoutOrder = elementCount
            toggleFrame.Parent = sectionFrame
            createCorner(toggleFrame, 6)
            
            -- Toggle label
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -60, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Font = Enum.Font.GothamMedium
            toggleLabel.TextSize = 14
            toggleLabel.TextColor3 = COLORS.TEXT
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Text = name or "Toggle"
            toggleLabel.Parent = toggleFrame
            
            -- Toggle button
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 36, 0, 20)
            toggleButton.Position = UDim2.new(1, -46, 0.5, 0)
            toggleButton.AnchorPoint = Vector2.new(0, 0.5)
            toggleButton.BackgroundColor3 = toggle.Value and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame
            createCorner(toggleButton, 10)
            
            -- Toggle indicator
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
            toggleIndicator.Position = toggle.Value 
                and UDim2.new(1, -18, 0.5, 0) 
                or UDim2.new(0, 2, 0.5, 0)
            toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
            toggleIndicator.BackgroundColor3 = COLORS.TEXT
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Parent = toggleButton
            createCorner(toggleIndicator, 8)
            
            -- Toggle functionality
            function toggle:Set(value)
                toggle.Value = value
                tween(toggleButton, {BackgroundColor3 = value and COLORS.TOGGLE_ON or COLORS.TOGGLE_OFF})
                tween(toggleIndicator, {Position = value 
                    and UDim2.new(1, -18, 0.5, 0) 
                    or UDim2.new(0, 2, 0.5, 0)})
                
                if callback then
                    callback(value)
                end
                return toggle
            end
            
            toggleButton.MouseButton1Click:Connect(function()
                toggle:Set(not toggle.Value)
            end)
            
            -- Initialize with default value
            if default then
                toggle:Set(default)
            end
            
            return toggle
        end
        
        -- Add button function
        function section:Button(name, callback)
            elementCount = elementCount + 1
            local button = {}
            
            -- Create button
            local buttonInstance = Instance.new("TextButton")
            buttonInstance.Name = "Button_" .. name
            buttonInstance.Size = UDim2.new(1, 0, 0, 36)
            buttonInstance.BackgroundColor3 = COLORS.ELEMENT
            buttonInstance.BorderSizePixel = 0
            buttonInstance.Text = name or "Button"
            buttonInstance.Font = Enum.Font.GothamMedium
            buttonInstance.TextSize = 14
            buttonInstance.TextColor3 = COLORS.TEXT
            buttonInstance.LayoutOrder = elementCount
            buttonInstance.Parent = sectionFrame
            createCorner(buttonInstance, 6)
            
            -- Button effects
            buttonInstance.MouseEnter:Connect(function()
                tween(buttonInstance, {BackgroundColor3 = COLORS.ACCENT})
            end)
            
            buttonInstance.MouseLeave:Connect(function()
                tween(buttonInstance, {BackgroundColor3 = COLORS.ELEMENT})
            end)
            
            buttonInstance.MouseButton1Click:Connect(function()
                tween(buttonInstance, {BackgroundColor3 = Color3.fromRGB(70, 140, 210)})
                task.delay(0.1, function()
                    if buttonInstance.Parent then -- Check if still exists
                        tween(buttonInstance, {BackgroundColor3 = COLORS.ELEMENT})
                    end
                end)
                
                if callback then
                    callback()
                end
            end)
            
            -- Button functionality
            function button:Fire()
                if callback then
                    callback()
                end
                return button
            end
            
            return button
        end
        
        -- Add slider function
        function section:Slider(name, min, max, default, callback)
            elementCount = elementCount + 1
            local slider = {Value = default or min}
            min = min or 0
            max = max or 100
            default = default or min
            
            -- Create slider container
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = "Slider_" .. name
            sliderFrame.Size = UDim2.new(1, 0, 0, 50)
            sliderFrame.BackgroundColor3 = COLORS.ELEMENT
            sliderFrame.BorderSizePixel = 0
            sliderFrame.LayoutOrder = elementCount
            sliderFrame.Parent = sectionFrame
            createCorner(sliderFrame, 6)
            
            -- Slider label
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Size = UDim2.new(1, -10, 0, 20)
            sliderLabel.Position = UDim2.new(0, 10, 0, 5)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Font = Enum.Font.GothamMedium
            sliderLabel.TextSize = 14
            sliderLabel.TextColor3 = COLORS.TEXT
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Text = name or "Slider"
            sliderLabel.Parent = sliderFrame
            
            -- Value display
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 40, 0, 20)
            valueLabel.Position = UDim2.new(1, -50, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Font = Enum.Font.GothamMedium
            valueLabel.TextSize = 14
            valueLabel.TextColor3 = COLORS.ACCENT
            valueLabel.Text = tostring(slider.Value)
            valueLabel.Parent = sliderFrame
            
            -- Slider background
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, -20, 0, 6)
            sliderBg.Position = UDim2.new(0, 10, 0, 35)
            sliderBg.BackgroundColor3 = COLORS.BACKGROUND
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = sliderFrame
            createCorner(sliderBg, 3)
            
            -- Slider fill
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = COLORS.ACCENT
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBg
            createCorner(sliderFill, 3)
            
            -- Slider functionality
            local isDragging = false
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = true
                    slider:UpdateValue(input.Position)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    slider:UpdateValue(input.Position)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDragging = false
                end
            end)
            
            function slider:UpdateValue(inputPosition)
                local bgAbsPos = sliderBg.AbsolutePosition
                local bgAbsSize = sliderBg.AbsoluteSize
                
                local relativeX = math.clamp(inputPosition.X - bgAbsPos.X, 0, bgAbsSize.X)
                local percent = relativeX / bgAbsSize.X
                
                self:Set(min + (max - min) * percent)
            end
            
            function slider:Set(value)
                self.Value = math.clamp(value, min, max)
                local percent = (self.Value - min) / (max - min)
                
                tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)})
                valueLabel.Text = tostring(math.floor(self.Value * 10) / 10)
                
                if callback then
                    callback(self.Value)
                end
                return slider
            end
            
            -- Initialize with default value
            slider:Set(default)
            
            return slider
        end
        
        -- Add dropdown function
        function section:Dropdown(name, options, callback)
            elementCount = elementCount + 1
            local dropdown = {Value = nil, Options = options or {}}
            
            -- Create dropdown container
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "Dropdown_" .. name
            dropdownFrame.Size = UDim2.new(1, 0, 0, 36)
            dropdownFrame.BackgroundColor3 = COLORS.ELEMENT
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.LayoutOrder = elementCount
            dropdownFrame.Parent = sectionFrame
            createCorner(dropdownFrame, 6)
            
            -- Dropdown label
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Size = UDim2.new(0.5, -10, 1, 0)
            dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Font = Enum.Font.GothamMedium
            dropdownLabel.TextSize = 14
            dropdownLabel.TextColor3 = COLORS.TEXT
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            dropdownLabel.Text = name or "Dropdown"
            dropdownLabel.Parent = dropdownFrame
            
            -- Dropdown selection display
            local selectionLabel = Instance.new("TextLabel")
            selectionLabel.Size = UDim2.new(0.5, -10, 1, 0)
            selectionLabel.Position = UDim2.new(0.5, 0, 0, 0)
            selectionLabel.BackgroundTransparency = 1
            selectionLabel.Font = Enum.Font.GothamMedium
            selectionLabel.TextSize = 14
            selectionLabel.TextColor3 = COLORS.ACCENT
            selectionLabel.TextXAlignment = Enum.TextXAlignment.Right
            selectionLabel.Text = "Select..."
            selectionLabel.Parent = dropdownFrame
            
            -- Dropdown button
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, 0, 1, 0)
            dropdownButton.BackgroundTransparency = 1
            dropdownButton.Text = ""
            dropdownButton.Parent = dropdownFrame
            
            -- Dropdown functionality
            function dropdown:Set(value)
                dropdown.Value = value
                selectionLabel.Text = tostring(value)
                
                if callback then
                    callback(value)
                end
                return dropdown
            end
            
            -- Dropdown menu
            local isOpen = false
            local optionsFrame = Instance.new("Frame")
            optionsFrame.Name = "Options"
            optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Will be resized
            optionsFrame.Position = UDim2.new(0, 0, 1, 2)
            optionsFrame.BackgroundColor3 = COLORS.ELEMENT
            optionsFrame.BorderSizePixel = 0
            optionsFrame.Visible = false
            optionsFrame.ZIndex = 10
            optionsFrame.Parent = dropdownFrame
            createCorner(optionsFrame, 6)
            
            -- Options layout
            local optionsLayout = Instance.new("UIListLayout")
            optionsLayout.Padding = UDim.new(0, 2)
            optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Parent = optionsFrame
            
            -- Populate options
            local function createOptions()
                -- Clear existing options
                for _, child in pairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add options
                for i, option in pairs(dropdown.Options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, -4, 0, 32)
                    optionButton.BackgroundColor3 = COLORS.BACKGROUND
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = tostring(option)
                    optionButton.Font = Enum.Font.GothamMedium
                    optionButton.TextSize = 14
                    optionButton.TextColor3 = COLORS.TEXT
                    optionButton.ZIndex = 11
                    optionButton.LayoutOrder = i
                    optionButton.Parent = optionsFrame
                    createCorner(optionButton, 4)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        dropdown:Set(option)
                        isOpen = false
                        optionsFrame.Visible = false
                    end)
                end
                
                -- Update size
                optionsFrame.Size = UDim2.new(1, 0, 0, math.min(#dropdown.Options * 34, 150))
                optionsFrame.CanvasSize = UDim2.new(0, 0, 0, #dropdown.Options * 34)
            end
            
            -- Toggle dropdown
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    createOptions()
                    optionsFrame.Visible = true
                else
                    optionsFrame.Visible = false
                end
            end)
            
            -- Update options
            function dropdown:Refresh(newOptions)
                dropdown.Options = newOptions
                if isOpen then
                    createOptions()
                end
                return dropdown
            end
            
            return dropdown
        end
        
        return section
    end
    
    -- Toggle window minimize/maximize
    function window:Toggle()
        window.Minimized = not window.Minimized
        
        if window.Minimized then
            tween(main, {Size = window.MinimizedSize})
            scrollFrame.Visible = false
        else
            tween(main, {Size = window.ExpandedSize})
            scrollFrame.Visible = true
        end
        
        return window.Minimized
    end
    
    -- Resize window
    function window:Resize(width, height)
        window.ExpandedSize = UDim2.new(0, width, 0, height)
        if not window.Minimized then
            main.Size = window.ExpandedSize
        end
        return window
    end
    
    return window
end

return UILibrary
