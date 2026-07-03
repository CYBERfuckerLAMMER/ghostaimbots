-- [[ GHOST FACE - ULTIMATE EDITION ]] --



local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({Name = "Ghost Face | Ultimate", LoadingTitle = "Inicializando...", LoadingSubtitle = "Script Completo"})



-- SERVIÇOS

local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

local UserInputService = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer



-- CONFIGURAÇÕES GERAIS

local Config = {

    AimEnabled = false, AimFOV = 300, AimKey = Enum.UserInputType.MouseButton2,

    BoxEsp = false, SkeletonEsp = false,

    FlingEnabled = false, FlingTarget = ""

}



-- TAB COMBATE

local Tab = Window:CreateTab("Combate", 4483362458)



Tab:CreateSection("Aimlock")

Tab:CreateToggle({Name = "Ativar Aimlock", Callback = function(V) Config.AimEnabled = V end})

Tab:CreateSlider({Name = "Tamanho FOV", Range = {50, 800}, Increment = 10, CurrentValue = 300, Callback = function(V) Config.AimFOV = V end})

Tab:CreateDropdown({Name = "Botão de Ativação", Options = {"Direito", "Esquerdo"}, CurrentOption = "Direito", Callback = function(Option)

    Config.AimKey = (Option == "Direito") and Enum.UserInputType.MouseButton2 or Enum.UserInputType.MouseButton1

end})



-- TAB VISUAL

local TabVis = Window:CreateTab("Visual (ESP)", 4483362458)

TabVis:CreateToggle({Name = "ESP Caixa (RGB)", Callback = function(V) Config.BoxEsp = V end})

TabVis:CreateToggle({Name = "ESP Esqueleto (RGB)", Callback = function(V) Config.SkeletonEsp = V end})



-- TAB TROLL (FLING)

local TabTroll = Window:CreateTab("Troll", 4483362458)

TabTroll:CreateInput({Name = "Nome do Alvo", PlaceholderText = "Digite o nome exato...", Callback = function(Text) Config.FlingTarget = Text end})

TabTroll:CreateToggle({Name = "Ativar Fling", Callback = function(V) Config.FlingEnabled = V end})



-- SISTEMA DE DESENHO (ESP)

local Drawings = {}



local function CreateESP(player)

    local d = {Box = Drawing.new("Square"), Line = Drawing.new("Line")}

    d.Box.Visible = false; d.Box.Thickness = 2; d.Box.Filled = false

    d.Line.Visible = false; d.Line.Thickness = 2

    Drawings[player.Name] = d

end



local function RemoveESP(name)

    if Drawings[name] then

        Drawings[name].Box:Remove()

        Drawings[name].Line:Remove()

        Drawings[name] = nil

    end

end



-- LOOP PRINCIPAL (TUDO EM UM LUGAR PARA PERFORMANCE)

RunService.RenderStepped:Connect(function()

    local RGB = Color3.fromHSV(tick() % 5 / 5, 1, 1)



    -- 1. LIMPEZA E ESP

    for name, d in pairs(Drawings) do

        local p = Players:FindFirstChild(name)

        if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or p.Character.Humanoid.Health <= 0 then

            RemoveESP(name)

        end

    end



    for _, p in pairs(Players:GetPlayers()) do

        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then

            if not Drawings[p.Name] then CreateESP(p) end

            local d = Drawings[p.Name]

            local hrp = p.Character.HumanoidRootPart

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)



            if onScreen then

                if Config.BoxEsp then

                    d.Box.Visible = true; d.Box.Color = RGB

                    d.Box.Size = Vector2.new(50, 100); d.Box.Position = Vector2.new(pos.X - 25, pos.Y - 50)

                else d.Box.Visible = false end



                if Config.SkeletonEsp and p.Character:FindFirstChild("Head") then

                    local head = Camera:WorldToViewportPoint(p.Character.Head.Position)

                    d.Line.Visible = true; d.Line.Color = RGB

                    d.Line.From = Vector2.new(head.X, head.Y); d.Line.To = Vector2.new(pos.X, pos.Y)

                else d.Line.Visible = false end

            else d.Box.Visible = false; d.Line.Visible = false end

        end

    end



    -- 2. AIMLOCK

    if Config.AimEnabled and UserInputService:IsMouseButtonPressed(Config.AimKey) then

        local closest, dist = nil, Config.AimFOV

        for _, p in pairs(Players:GetPlayers()) do

            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then

                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)

                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude

                if onScreen and mag < dist then closest = p.Character.Head; dist = mag end

            end

        end

        if closest then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closest.Position) end

    end



    -- 3. FLING

    if Config.FlingEnabled and Config.FlingTarget ~= "" then

        local target = Players:FindFirstChild(Config.FlingTarget)

        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

            LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50000, 0)

            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame

        end

    end

end)
