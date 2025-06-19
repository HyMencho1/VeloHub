local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Criação do GUI principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedControlGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Função para criar bordas arredondadas
local function createRoundedCorners(parent, cornerRadius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(cornerRadius, 0)
    uiCorner.Parent = parent
    return uiCorner
end

-- Aplicar bordas arredondadas ao frame principal
createRoundedCorners(mainFrame, 0.2)

-- Criação do header (para mover e compactar)
local header = Instance.new("TextButton")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 30)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
header.BackgroundTransparency = 0.2
header.Text = "Speed Control"
header.TextColor3 = Color3.new(1, 1, 1)
header.TextSize = 14
header.BorderSizePixel = 0
header.Parent = mainFrame

createRoundedCorners(header, 0.2)

-- Criação dos botões
local buttonContainer = Instance.new("Frame")
buttonContainer.Name = "ButtonContainer"
buttonContainer.Size = UDim2.new(1, -20, 1, -50)
buttonContainer.Position = UDim2.new(0, 10, 0, 40)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainFrame

local plusButton = Instance.new("TextButton")
plusButton.Name = "PlusButton"
plusButton.Size = UDim2.new(0.3, 0, 0, 30)
plusButton.Position = UDim2.new(0, 0, 0, 0)
plusButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
plusButton.BackgroundTransparency = 0.3
plusButton.Text = "+"
plusButton.TextColor3 = Color3.new(1, 1, 1)
plusButton.TextSize = 20
plusButton.BorderSizePixel = 1
plusButton.BorderColor3 = Color3.new(1, 1, 1)
plusButton.Parent = buttonContainer
createRoundedCorners(plusButton, 0.2)

local minusButton = Instance.new("TextButton")
minusButton.Name = "MinusButton"
minusButton.Size = UDim2.new(0.3, 0, 0, 30)
minusButton.Position = UDim2.new(0.35, 0, 0, 0)
minusButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minusButton.BackgroundTransparency = 0.3
minusButton.Text = "-"
minusButton.TextColor3 = Color3.new(1, 1, 1)
minusButton.TextSize = 20
minusButton.BorderSizePixel = 1
minusButton.BorderColor3 = Color3.new(1, 1, 1)
minusButton.Parent = buttonContainer
createRoundedCorners(minusButton, 0.2)

local defaultButton = Instance.new("TextButton")
defaultButton.Name = "DefaultButton"
defaultButton.Size = UDim2.new(0.3, 0, 0, 30)
defaultButton.Position = UDim2.new(0.7, 0, 0, 0)
defaultButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
defaultButton.BackgroundTransparency = 0.3
defaultButton.Text = "Default"
defaultButton.TextColor3 = Color3.new(1, 1, 1)
defaultButton.TextSize = 14
defaultButton.BorderSizePixel = 1
defaultButton.BorderColor3 = Color3.new(1, 1, 1)
defaultButton.Parent = buttonContainer
createRoundedCorners(defaultButton, 0.2)

-- Variável para controle de compactação
local isCompact = false
local originalSize = mainFrame.Size

-- Função de animação de clique
local function animateClick(button)
    local originalColor = button.BackgroundColor3
    local originalTransparency = button.BackgroundTransparency
    
    -- Animação de clique
    local tweenInfo = TweenInfo.new(
        0.1,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local darkenTween = TweenService:Create(
        button,
        tweenInfo,
        {
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.7
        }
    )
    
    local restoreTween = TweenService:Create(
        button,
        tweenInfo,
        {
            BackgroundColor3 = originalColor,
            BackgroundTransparency = originalTransparency
        }
    )
    
    darkenTween:Play()
    darkenTween.Completed:Connect(function()
        restoreTween:Play()
    end)
end

-- Controle de velocidade
local defaultWalkSpeed = humanoid.WalkSpeed

plusButton.MouseButton1Click:Connect(function()
    animateClick(plusButton)
    humanoid.WalkSpeed = humanoid.WalkSpeed * 2
end)

minusButton.MouseButton1Click:Connect(function()
    animateClick(minusButton)
    humanoid.WalkSpeed = humanoid.WalkSpeed / 2
end)

defaultButton.MouseButton1Click:Connect(function()
    animateClick(defaultButton)
    humanoid.WalkSpeed = defaultWalkSpeed
end)

-- Atualizar a velocidade padrão quando o personagem morre/respaw
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    defaultWalkSpeed = humanoid.WalkSpeed
end)

-- Funcionalidade de arrastar
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Funcionalidade de compactação
header.MouseButton1Click:Connect(function()
    if not dragging then -- Só compacta se não estiver arrastando
        isCompact = not isCompact
        
        if isCompact then
            -- Compactar
            mainFrame.Size = UDim2.new(0, 200, 0, 30)
            buttonContainer.Visible = false
        else
            -- Expandir
            mainFrame.Size = originalSize
            buttonContainer.Visible = true
        end
    end
end)