local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
while not player do task.wait() player = Players.LocalPlayer end

local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local fovVisiblePreference = false
local fovRadius = 120
local autoShootEnabled = false
local autoShootAgresivoEnabled = false
local autoShootTargetPart = "Cabeza"
local silentAimManualEnabled = false
local silentAimFovEnabled = false
local silentAimTargetPart = "Cabeza"
local teamCheckEnabled = true
local espEnabled = false
local espColor = Color3.fromRGB(255, 255, 255)
local espSettings = { Glow = true }
local KillAllEnabled = false
local hitboxEnabled = false
local hitboxInvisible = false
local hitboxSize = 3.5
local hitboxColor = Color3.fromRGB(255, 0, 0)

local animacionActualActiva = nil
local misAnimacionesOriginales = nil
local UIElements = {}
local NotificationsEnabled = false

local Keybinds = { ToggleUI = "RightControl", ToggleKillAll = "K" }

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NexvyrHub_Overlays"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = player:WaitForChild("PlayerGui")

local espFolder = Instance.new("Folder")
espFolder.Name = "NexvyrESPFolder"
espFolder.Parent = screenGui

local function makeDraggable(guiObject, objectToMove, callback)
    local dragging, dragInput, dragStart, startPos, moved = false, nil, nil, nil, false
    local function isClickInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
    end
    guiObject.InputBegan:Connect(function(input)
        if not isClickInput(input) then return end
        dragging = true; moved = false; dragStart = input.Position; startPos = objectToMove.Position
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input ~= dragInput or not dragging then return end
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then moved = true end
        if moved then
            objectToMove.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not isClickInput(input) or not dragging then return end
        dragging = false
        if not moved and callback then callback() end
    end)
end

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NexvyrMinimalNotifs"
NotifContainer.Size = UDim2.new(0, 300, 0.5, 0)
NotifContainer.AnchorPoint = Vector2.new(1, 1)
NotifContainer.Position = UDim2.new(1, -20, 1, -20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = screenGui

local layout = Instance.new("UIListLayout", NotifContainer)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

local function showBottomMessage(text)
    if not NotificationsEnabled then return end
end

local WindUI
local _version = "1.6.66"
local uiFileName = "WindUI_Cache_v" .. _version .. ".txt"
local timeFileName = "WindUI_Cache_v" .. _version .. "_Time.txt"

local ok, result = pcall(function()
    local cacheValido = false
    if isfile and isfile(timeFileName) and readfile then
        local savedTime = tonumber(readfile(timeFileName))
        if savedTime and (os.time() - savedTime) < 86400 then
            cacheValido = true
        end
    end
    if cacheValido and isfile and isfile(uiFileName) then
        local code = readfile(uiFileName)
        local fn = loadstring(code)
        if fn then
            return fn()
        else
            if delfile then
                pcall(delfile, uiFileName)
                pcall(delfile, timeFileName)
            end
        end
    end
    local codigoUi = game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua")
    if writefile then
        writefile(uiFileName, codigoUi)
        writefile(timeFileName, tostring(os.time()))
    end
    return loadstring(codigoUi)()
end)

if ok and result and type(result) == "table" then
    WindUI = result
else
    warn("Error al cargar WindUI: " .. tostring(result))
    return
end

local Window = WindUI:CreateWindow({
    Title = "NEXVYRHUB | DUELS <font color='#FFD700'>[v2.8] </font>",
    Author = "By 7.dui🇲🇽",
    Folder = "Nexvyr_WindUI",
    Acrylic = false,
    Transparent = false,
    NewElements = true,
    HideSearchBar = false,
    Background = "rbxthumb://type=Asset&id=14653905878&w=420&h=420",
    BackgroundImageTransparency = 0.35,
    OpenButton = {
        Title = "Open HUB",
        Icon = "rbxthumb://type=Asset&id=118232139384203&w=420&h=420",
        IconSize = 9,
        CornerRadius = UDim.new(1),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        Scale = 0.9,
        Color = ColorSequence.new(Color3.fromHex("#110070"), Color3.fromHex("#300364"))
    },
    Topbar = { Height = 44, ButtonsType = "Default" }
})

local ExtrasScriptsSection = Window:Section({ Title = "Extras scripts", Icon = "solar:code-square-bold", Opened = true })
local MainSection = Window:Section({ Title = "Funciones Principales", Icon = "solar:star-bold", Opened = true })
local TrollSection = Window:Section({ Title = "Configs & Extra", Icon = "solar:widget-bold", Opened = true })
local OwnersSection = Window:Section({ Title = "Owners", Icon = "solar:crown-bold", Opened = true })

local Tabs = {
    ExtrasScripts = ExtrasScriptsSection:Tab({ Title = "Extras scripts", Icon = "solar:code-square-bold" }),
    Inicio = MainSection:Tab({ Title = "Inicio", Icon = "solar:home-bold" }),
    Aim = MainSection:Tab({ Title = "Aimbot", Icon = "solar:target-bold" }),
    Vis = MainSection:Tab({ Title = "Visuales", Icon = "solar:eye-bold" }),
    Farm = MainSection:Tab({ Title = "AutoFarm", Icon = "solar:dollar-bold" }),
    KillAll = MainSection:Tab({ Title = "Kill All", Icon = "solar:danger-triangle-bold" }),
    RachaFarm = MainSection:Tab({ Title = "Racha Farm", Icon = "solar:flame-bold" }),
    Animaciones = MainSection:Tab({ Title = "Animaciones", Icon = "solar:smile-circle-bold" }),
    Sonidos = TrollSection:Tab({ Title = "Sonidos", Icon = "solar:speaker-bold" }),
    Guardado = TrollSection:Tab({ Title = "Guardado", Icon = "solar:diskette-bold" }),
    Music = TrollSection:Tab({ Title = "Música", Icon = "solar:music-note-2-bold" }),
    Fondos = TrollSection:Tab({ Title = "Fondos", Icon = "solar:gallery-bold" }),
    Emotes = TrollSection:Tab({ Title = "Emotes", Icon = "solar:emoji-funny-circle-bold" }),
    Items = TrollSection:Tab({ Title = "Items", Icon = "solar:crown-star-bold" }),
    Com = TrollSection:Tab({ Title = "Comunidad", Icon = "solar:chat-line-bold" }),
    Owners = OwnersSection:Tab({ Title = "Owners", Icon = "solar:crown-bold" }),
    Avisos = OwnersSection:Tab({ Title = "Avisos", Icon = "solar:shield-warning-bold" }),
    Update = OwnersSection:Tab({ Title = "Update", Icon = "solar:cloud-download-bold" })
}

local COLORES_NEUTROS = {
    ["White"] = true,
    ["Medium stone grey"] = true,
    ["Medium Stone Grey"] = true,
    ["Really black"] = true,
    ["Really Black"] = true,
    ["Institutional white"] = true,
    ["Institutional White"] = true,
    ["Ghost grey"] = true,
    ["Ghost Grey"] = true,
}

local function esColorVerde(c)
    if typeof(c) ~= "Color3" then return false end
    return c.G >= 0.55 and c.G > c.R and c.G > c.B and (c.G - c.R) >= 0.15 and (c.G - c.B) >= 0.15
end

local function guiTieneVerde(obj)
    if not obj then return false end
    local okBg, bg = pcall(function() return obj.BackgroundColor3 end)
    if okBg and bg and esColorVerde(bg) then return true end
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        local okT, tc = pcall(function() return obj.TextColor3 end)
        if okT and tc and esColorVerde(tc) then return true end
    end
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        local okI, ic = pcall(function() return obj.ImageColor3 end)
        if okI and ic and esColorVerde(ic) then return true end
    end
    return false
end

local function contenedorTieneVerde(container)
    if not container then return false end
    for _, desc in ipairs(container:GetDescendants()) do
        if desc:IsA("GuiObject") and guiTieneVerde(desc) then
            return true
        end
        if desc:IsA("Highlight") then
            if esColorVerde(desc.FillColor) or esColorVerde(desc.OutlineColor) then
                return true
            end
        end
        if desc:IsA("ParticleEmitter") then
            local ok, cs = pcall(function() return desc.Color end)
            if ok and cs then
                local c0 = cs.Keypoints and cs.Keypoints[1] and cs.Keypoints[1].Value
                if c0 and esColorVerde(c0) then return true end
            end
        end
        if desc:IsA("PointLight") or desc:IsA("SpotLight") then
            local ok, c = pcall(function() return desc.Color end)
            if ok and esColorVerde(c) then return true end
        end
        if desc:IsA("BillboardGui") then
            for _, sub in ipairs(desc:GetDescendants()) do
                if sub:IsA("GuiObject") and guiTieneVerde(sub) then return true end
            end
        end
    end
    return false
end

local marcaAliadoCache = {}
local MARCA_CACHE_TTL = 1.0

local function invalidarMarcaAliado(targetPlayer)
    if targetPlayer then marcaAliadoCache[targetPlayer] = nil end
end

local ATTRS_ALIADO = {
    "IsAlly","Ally","AllyMarker","isAlly","is_ally","ally",
    "Teammate","isTeammate","is_teammate","IsTeammate",
    "Friendly","isFriendly","IsFriendly","is_friendly"
}

local function tieneMarcaAliado(targetPlayer)
    if not targetPlayer then return false end
    local now = os.clock()
    local cached = marcaAliadoCache[targetPlayer]
    if cached and (now - cached.time) < MARCA_CACHE_TTL then
        return cached.value
    end

    local resultado = false
    local char = targetPlayer.Character

    for _, attrName in ipairs(ATTRS_ALIADO) do
        local v1 = targetPlayer:GetAttribute(attrName)
        if v1 == true or v1 == "true" or v1 == "Ally" or v1 == "ally" then
            resultado = true; break
        end
        if char then
            local v2 = char:GetAttribute(attrName)
            if v2 == true or v2 == "true" or v2 == "Ally" or v2 == "ally" then
                resultado = true; break
            end
        end
    end

    if not resultado then
        local myAttr = player:GetAttribute("Team") or player:GetAttribute("team")
        local otherAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")
        if myAttr ~= nil and otherAttr ~= nil and myAttr ~= "" and otherAttr ~= "" and myAttr == otherAttr then
            resultado = true
        end
    end

    if not resultado and char then
        local head = char:FindFirstChild("Head")
        if head then
            for _, child in ipairs(head:GetChildren()) do
                if child:IsA("BillboardGui") and contenedorTieneVerde(child) then resultado = true; break end
                if child:IsA("Highlight") and (esColorVerde(child.FillColor) or esColorVerde(child.OutlineColor)) then resultado = true; break end
                if child:IsA("Attachment") and contenedorTieneVerde(child) then resultado = true; break end
            end
        end
    end

    if not resultado and char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, child in ipairs(hrp:GetChildren()) do
                if child:IsA("BillboardGui") and contenedorTieneVerde(child) then resultado = true; break end
                if child:IsA("Attachment") and contenedorTieneVerde(child) then resultado = true; break end
                if child:IsA("Highlight") and (esColorVerde(child.FillColor) or esColorVerde(child.OutlineColor)) then resultado = true; break end
            end
        end
    end

    if not resultado and char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Highlight") then
                if esColorVerde(child.FillColor) or esColorVerde(child.OutlineColor) then resultado = true; break end
            end
        end
    end

    if not resultado and char then
        local head = char:FindFirstChild("Head")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if head and contenedorTieneVerde(head) then resultado = true end
        if not resultado and hrp and contenedorTieneVerde(hrp) then resultado = true end
    end

    marcaAliadoCache[targetPlayer] = { value = resultado, time = now }
    return resultado
end

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == player then return false end

    if tieneMarcaAliado(targetPlayer) then return false end

    if not teamCheckEnabled then return true end

    local myColorName = player.TeamColor and player.TeamColor.Name or "White"
    local otherColorName = targetPlayer.TeamColor and targetPlayer.TeamColor.Name or "White"
    local myColorNeutral = COLORES_NEUTROS[myColorName] == true
    local otherColorNeutral = COLORES_NEUTROS[otherColorName] == true
    if not myColorNeutral and not otherColorNeutral then
        if player.TeamColor == targetPlayer.TeamColor then
            return false
        else
            return true
        end
    end

    if player.Team ~= nil and targetPlayer.Team ~= nil then
        if player.Team == targetPlayer.Team then return false end
        return true
    end

    local myAttr = player:GetAttribute("Team") or player:GetAttribute("team")
    local otherAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")
    if myAttr ~= nil and otherAttr ~= nil and myAttr ~= "" and otherAttr ~= "" then
        return myAttr ~= otherAttr
    end

    return true
end

local function esCompaneroDeEquipo(targetPlayer)
    if not targetPlayer or targetPlayer == player then return true end

    local myColor = player.TeamColor
    local otherColor = targetPlayer.TeamColor
    if myColor and otherColor then
        local myName = myColor.Name
        local otherName = otherColor.Name
        local myNeutral = COLORES_NEUTROS[myName] == true
        local otherNeutral = COLORES_NEUTROS[otherName] == true
        if not myNeutral and not otherNeutral then
            return myColor == otherColor
        end
    end

    if player.Team and targetPlayer.Team then
        return player.Team == targetPlayer.Team
    end

    local myAttr = player:GetAttribute("Team") or player:GetAttribute("team")
    local otherAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("team")
    if myAttr and otherAttr and myAttr ~= "" and otherAttr ~= "" then
        return myAttr == otherAttr
    end

    return false
end

local function estaEnLobby()
    local char = player.Character
    if not char then return true end
    if char:FindFirstChildOfClass("ForceField") then return true end
    if player.Team then
        local tName = string.lower(player.Team.Name)
        if string.find(tName, "lobby") or string.find(tName, "spectat") or string.find(tName, "espectador") or string.find(tName, "menu") or string.find(tName, "dead") then
            return true
        end
    end
    return false
end

local function IsInMatchStrict()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return false end
    local main = gui:FindFirstChild("Main") or gui

    local gameFrame = main:FindFirstChild("MainGameFrame")
    if not gameFrame or not gameFrame.Visible then return false end

    local score = gameFrame:FindFirstChild("IngameScore")
    local timer = score and score:FindFirstChild("Timer")
    if not timer then return false end
    if not (timer:IsA("TextLabel") or timer:IsA("TextButton") or timer:IsA("TextBox")) then
        return false
    end

    local txt = tostring(timer.Text or ""):gsub("%s", "")
    if txt == "" then return false end
    if string.find(txt, "-") then return false end
    if txt == "0:00" or txt == "00:00" or txt == "0:0" then return false end

    return txt:match("^%d+:%d%d$") ~= nil
end

local function IsInMatchOrLoading()
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return false end
    local main = gui:FindFirstChild("Main") or gui
    local gameFrame = main:FindFirstChild("MainGameFrame")
    if not gameFrame or not gameFrame.Visible then return false end

    local gameAttr = player:GetAttribute("Game")
    if gameAttr == nil or gameAttr == "" then return false end

    return true
end

local function esEnemigoValido(targetPlayer)
    if not targetPlayer or targetPlayer == player then return false end
    if not isEnemy(targetPlayer) then return false end
    local char = targetPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if char:FindFirstChildOfClass("ForceField") then return false end
    if targetPlayer.Team then
        local tName = string.lower(targetPlayer.Team.Name)
        if string.find(tName, "lobby") or string.find(tName, "spectat") or string.find(tName, "espectador") or string.find(tName, "menu") or string.find(tName, "dead") then
            return false
        end
    end
    return true
end

local function esCuchillo(item)
    if not item or not item:IsA("Tool") then return false end
    if item:FindFirstChild("Slash") or item:FindFirstChild("SlashStart") then return true end
    local nombre = string.lower(item.Name)
    if string.find(nombre, "knife") or string.find(nombre, "cuchillo") or string.find(nombre, "dagger") then return true end
    return false
end

local function esPistola(item)
    if not item or not item:IsA("Tool") then return false end
    if item:FindFirstChild("Throw", true) or item:FindFirstChild("KnifeClient", true) or item:FindFirstChild("KnifeServer", true) then return false end
    if esCuchillo(item) then return false end
    local nombre = string.lower(item.Name)
    local ignorar = {"combat", "fist", "wallet", "phone", "punch", "boombox", "radio", "knife", "blade", "cuchillo", "dagger", "kunai", "sword", "toy", "juguete", "pizza", "burger", "teddy", "balloon", "drink", "food"}
    for _, palabra in ipairs(ignorar) do if string.find(nombre, palabra) then return false end end
    return true
end

local function obtenerPistola()
    local char = player.Character
    if not char then return nil end
    local backpack = player:FindFirstChildOfClass("Backpack")
    if char then for _, item in ipairs(char:GetChildren()) do if esPistola(item) then return item end end end
    if backpack then for _, item in ipairs(backpack:GetChildren()) do if esPistola(item) then return item end end end
    return nil
end

local function estaRecargando(arma)
    if not arma or not arma:IsA("Tool") then return false end

    for _, name in ipairs({"Reloading", "IsReloading", "reloading", "isReloading", "Reload", "reload"}) do
        local v = arma:GetAttribute(name)
        if v == true or v == "true" then return true end
    end

    for _, child in ipairs(arma:GetChildren()) do
        if child:IsA("BoolValue") and child.Value == true then
            local n = string.lower(child.Name)
            if string.find(n, "reload") or string.find(n, "recarg") then
                return true
            end
        end
    end

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            local animId = track.Animation and track.Animation.AnimationId or ""
            if string.find(string.lower(animId), "reload") then
                return true
            end
        end
    end

    for _, s in ipairs(arma:GetDescendants()) do
        if s:IsA("Sound") and s.Playing then
            local n = string.lower(s.Name)
            if string.find(n, "reload") or string.find(n, "recarg") then
                return true
            end
        end
    end

    return false
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then
        p.CharacterAdded:Connect(function() invalidarMarcaAliado(p) end)
    end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= player then
        p.CharacterAdded:Connect(function() invalidarMarcaAliado(p) end)
    end
end)
Players.PlayerRemoving:Connect(function(p) invalidarMarcaAliado(p) end)
player.CharacterAdded:Connect(function() for p in pairs(marcaAliadoCache) do marcaAliadoCache[p] = nil end end)

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new() return setmetatable({ Items = {} }, ConnectionManager) end
function ConnectionManager:Add(task) self.Items[#self.Items + 1] = task; return task end
function ConnectionManager:Cleanup()
    for i = #self.Items, 1, -1 do
        local item = self.Items[i]
        self.Items[i] = nil
        local t = typeof(item)
        if t == "RBXScriptConnection" then pcall(function() item:Disconnect() end)
        elseif t == "Instance" then pcall(function() item:Destroy() end)
        elseif t == "function" then pcall(item) end
    end
end

local function limpiarHitboxes()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        local character = targetPlayer.Character
        if character then
            local hitbox = character:FindFirstChild("GhostHitbox")
            if hitbox then hitbox:Destroy() end
        end
    end
end

task.spawn(function()
    while task.wait(0.2) do
        if not hitboxEnabled then continue end
        if not IsInMatchStrict() then
            limpiarHitboxes()
            continue
        end
        local tamanoObjetivo = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        local transObjetivo = hitboxInvisible and 1 or 0.6
        for _, targetPlayer in ipairs(Players:GetPlayers()) do
            if targetPlayer ~= player and not esCompaneroDeEquipo(targetPlayer) and isEnemy(targetPlayer) then
                local character = targetPlayer.Character
                if character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if rootPart and humanoid and humanoid.Health > 0 then
                        local hitbox = character:FindFirstChild("GhostHitbox")
                        if not hitbox then
                            hitbox = Instance.new("Part")
                            hitbox.Name = "GhostHitbox"
                            hitbox.Size = tamanoObjetivo
                            hitbox.Transparency = transObjetivo
                            hitbox.Color = hitboxColor
                            hitbox.CanCollide = false
                            hitbox.Massless = true
                            hitbox.CanQuery = true
                            hitbox.CFrame = rootPart.CFrame
                            hitbox.Parent = character
                            local weld = Instance.new("WeldConstraint")
                            weld.Part0 = rootPart
                            weld.Part1 = hitbox
                            weld.Parent = hitbox
                        else
                            if hitbox.Size ~= tamanoObjetivo then hitbox.Size = tamanoObjetivo end
                            if hitbox.Transparency ~= transObjetivo then hitbox.Transparency = transObjetivo end
                            if hitbox.Color ~= hitboxColor then hitbox.Color = hitboxColor end
                            if not hitbox.CanQuery then hitbox.CanQuery = true end
                        end
                    else
                        local hitbox = character:FindFirstChild("GhostHitbox")
                        if hitbox then hitbox:Destroy() end
                    end
                end
            else
                local char = targetPlayer.Character
                if char then
                    local hb = char:FindFirstChild("GhostHitbox")
                    if hb then hb:Destroy() end
                end
            end
        end
    end
end)

local PadZoneConfig = {
    ["Right Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone1", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone2", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone3", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone4", MainPad = "Pad1", AltPad = "Pad2" }
    },
    ["Left Platforms"] = {
        ["1v1"] = { ZoneName = "PadZone5", MainPad = "Pad1", AltPad = "Pad2" },
        ["2v2"] = { ZoneName = "PadZone6", MainPad = "Pad1", AltPad = "Pad2" },
        ["3v3"] = { ZoneName = "PadZone7", MainPad = "Pad1", AltPad = "Pad2" },
        ["4v4"] = { ZoneName = "PadZone8", MainPad = "Pad1", AltPad = "Pad2" }
    }
}

AutoTeleportMainAlt = {}
AutoTeleportMainAlt.__index = AutoTeleportMainAlt

function AutoTeleportMainAlt.new()
    return setmetatable({
        Running = false, Connections = ConnectionManager.new(), Acc = 0, TickInterval = 0.5,
        ActiveRole = nil, DuelType = "1v1", PlatformRow = "Right Platforms",
        LastTeleport = 0, LastVote = 0, LastCancel = 0,
        TeleportCooldown = 0.5, VoteCooldown = 1, CancelCooldown = 1,
        VotedMap = nil, HighlightedPad = nil, PadColors = {}, ManualHold = false,
    }, AutoTeleportMainAlt)
end

function AutoTeleportMainAlt:GetActiveRole()
    if self.ActiveRole == "Main" then return "Main" end
    if self.ActiveRole == "Alt" then return "Alt" end
    return nil
end

function AutoTeleportMainAlt:GetRoot()
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then return root end
    return nil
end

function AutoTeleportMainAlt:GetHumanoid()
    local char = player.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function AutoTeleportMainAlt:Attr(name)
    local v = player:GetAttribute(name)
    if typeof(v) == "string" and v ~= "" then return v end
    return nil
end

function AutoTeleportMainAlt:Snapshot()
    local gameAttr = self:Attr("Game")
    local mapAttr = self:Attr("Map")
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local alive = hum ~= nil and hum.Health > 0 and root ~= nil
    return { Game = gameAttr, Map = mapAttr, InGame = gameAttr ~= nil, InMap = gameAttr ~= nil and mapAttr ~= nil, Alive = alive }
end

function AutoTeleportMainAlt:IsOnMatch()
    local s = self:Snapshot()
    return s and s.InGame == true and s.InMap ~= true and s.Alive
end

function AutoTeleportMainAlt:IsQueued() return self:Snapshot().InGame == true end

function AutoTeleportMainAlt:ResolvePad(role)
    local rowConfig = PadZoneConfig[self.PlatformRow] or PadZoneConfig["Right Platforms"]
    local cfg = rowConfig[self.DuelType] or rowConfig["1v1"]
    local padZones = workspace:FindFirstChild("PadZones")
    if not padZones then return nil end
    local zone = padZones:FindFirstChild(cfg.ZoneName)
    if not zone then return nil end
    local padName = (role == "Alt") and cfg.AltPad or cfg.MainPad
    local holder = zone:FindFirstChild(padName)
    if not holder then return nil end
    local pad = holder:FindFirstChild("Pad")
    if pad and pad:IsA("BasePart") then return pad end
    return nil
end

function AutoTeleportMainAlt:IsOnPad(pad)
    if not pad then return false end
    local root = self:GetRoot()
    if not root then return false end
    local rel = pad.CFrame:PointToObjectSpace(root.Position)
    local half = pad.Size / 2
    return math.abs(rel.X) <= half.X + 0.5 and math.abs(rel.Z) <= half.Z + 0.5 and rel.Y >= -(half.Y + 6) and rel.Y <= half.Y + 14
end

function AutoTeleportMainAlt:MarkPad(pad, isAlt)
    if not pad then self:UnmarkPad(); return end
    if self.HighlightedPad == pad then return end
    self:UnmarkPad()
    self.HighlightedPad = pad
    self.PadColors[pad] = { Color = pad.Color, Transparency = pad.Transparency }
    pcall(function()
        pad.Color = isAlt and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(70, 145, 255)
        pad.Transparency = 0.5
    end)
end

function AutoTeleportMainAlt:UnmarkPad()
    if self.HighlightedPad and self.PadColors[self.HighlightedPad] then
        local pad = self.HighlightedPad
        local saved = self.PadColors[pad]
        pcall(function()
            if pad.Parent then
                pad.Color = saved.Color
                pad.Transparency = saved.Transparency
            end
        end)
    end
    self.HighlightedPad = nil
end

function AutoTeleportMainAlt:FindVoteRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net = pkgs and pkgs:FindFirstChild("Networking")
    local r = net and net:FindFirstChild("RF/Voting/Vote")
    if r and r:IsA("RemoteFunction") then return r end
    return nil
end

function AutoTeleportMainAlt:FindVisibleMapVote()
    local pg = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local mv = main and main:FindFirstChild("MapVoting")
    local holder = mv and mv:FindFirstChild("VotingHolder")
    if not holder then return nil end
    for _, b in ipairs(holder:GetChildren()) do
        if b:IsA("ImageButton") and b.Visible and b.Name ~= "" then return b.Name end
    end
    return nil
end

function AutoTeleportMainAlt:VoteMap()
    local s = self:Snapshot()
    if not self:IsOnMatch() then return end
    if self.VotedMap == s.Game then return end
    local now = os.clock()
    if now - (self.LastVote or 0) < self.VoteCooldown then return end
    self.LastVote = now
    local target = self:FindVisibleMapVote()
    local rf = self:FindVoteRemote()
    if not (target and rf) then return end
    self.VotedMap = s.Game
    pcall(function() rf:InvokeServer(target) end)
end

function AutoTeleportMainAlt:FindSetStateRemote()
    local pkgs = ReplicatedStorage:FindFirstChild("Packages")
    local net = pkgs and pkgs:FindFirstChild("Networking")
    local r = net and net:FindFirstChild("RE/Match/SetStatePlr")
    if r and r:IsA("RemoteEvent") then return r end
    return nil
end

function AutoTeleportMainAlt:CancelQueue()
    local now = os.clock()
    if now - (self.LastCancel or 0) < self.CancelCooldown then return end
    local ev = self:FindSetStateRemote()
    if not ev then return end
    self.LastCancel = now
    pcall(function() ev:FireServer("REMOVE") end)
end

function AutoTeleportMainAlt:HideGameFrame()
    local pg = player:FindFirstChild("PlayerGui")
    local main = pg and pg:FindFirstChild("Main")
    local mgf = main and main:FindFirstChild("MainGameFrame")
    if mgf and mgf:IsA("GuiObject") then pcall(function() mgf.Visible = false end) end
end

function AutoTeleportMainAlt:HoldCenter()
    local hum = self:GetHumanoid()
    local root = self:GetRoot()
    if hum and root then pcall(function() hum:MoveTo(root.Position) end) end
end

function AutoTeleportMainAlt:Teleport(pad)
    if not pad then return end
    local root = self:GetRoot()
    local hum = self:GetHumanoid()
    if not (root and hum) then return end
    pcall(function()
        root.AssemblyAngularVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        self:CancelQueue()
        self:HideGameFrame()
        hum:MoveTo(pad.Position)
    end)
end

function AutoTeleportMainAlt:Process()
    if not self.Running then return end
    local s = self:Snapshot()
    if s.InGame then
        self:UnmarkPad(); self:HoldCenter(); self:VoteMap(); return
    end
    local role = self:GetActiveRole()
    if not role then self:UnmarkPad(); return end
    local pad = self:ResolvePad(role)
    self:MarkPad(pad, role == "Alt")
    if not pad then return end
    if self:IsOnPad(pad) then return end
    local now = os.clock()
    if not self.ManualHold and now - (self.LastTeleport or 0) < self.TeleportCooldown then return end
    self.LastTeleport = now
    self:Teleport(pad)
end

function AutoTeleportMainAlt:Kick() if self.Running then self:Process() end end

function AutoTeleportMainAlt:Start()
    if self.Running then return end
    self.Running = true
    self.Acc = 0; self.LastTeleport = 0; self.LastVote = 0; self.LastCancel = 0
    self.Connections:Add(player:GetAttributeChangedSignal("Game"):Connect(function() task.defer(function() if self.Running then self:Process() end end) end))
    self.Connections:Add(player:GetAttributeChangedSignal("Map"):Connect(function() task.defer(function() if self.Running then self:Process() end end) end))
    self.Connections:Add(player:GetAttributeChangedSignal("Team"):Connect(function() task.defer(function() if self.Running then self:Process() end end) end))
    self.Connections:Add(RunService.Heartbeat:Connect(function(dt)
        if not self.Running then return end
        self.Acc = self.Acc + dt
        if self.Acc >= self.TickInterval then self.Acc = 0; self:Process() end
    end))
    self:Process()
end

function AutoTeleportMainAlt:Stop()
    if not self.Running then return end
    self.Running = false
    self.Connections:Cleanup()
    self.Connections = ConnectionManager.new()
    self:UnmarkPad()
    self.VotedMap = nil
end

AutoTeleportMainAltInstance = AutoTeleportMainAlt.new()

local KILLALL_MOVE_SPEED               = 39.9
local KILLALL_APPROACH_DISTANCE        = 2.5
local KILLALL_APPROACH_TOLERANCE       = 0.35
local KILLALL_SWING_INTERVAL           = 0.5
local KILLALL_SAFE_GROUND_THRESHOLD    = 3
local KILLALL_STICK_MAX_TIME           = 2.5
local KILLALL_STICK_MAX_DISTANCE       = 20
local KILLALL_VOID_PROTECTION          = 15
local KILLALL_HEALTH_STALL_TIME        = 1.5
local KILLALL_TARGET_GRACE_TIME        = 1.2
local KILLALL_PITCH_DEGREES            = 90
local KILLALL_HEIGHT_OFFSET            = 1.9
local KILLALL_HIDE_DEPTH               = 4
local KILLALL_HIDE_DURATION            = 0.5
local KILLALL_KNIFE_RANGE_Y            = 4.5
local KILLALL_PREDICTION_TIME          = 0.08

local KILLALL_JITTER_AMPLITUDE         = 0.8
local KILLALL_JITTER_SWITCH_MIN        = 0.05
local KILLALL_JITTER_SWITCH_MAX        = 0.12
local KILLALL_JITTER_LERP_SPEED        = 25

local KILLALL_UNDERGROUND_DEPTH        = 5
local KILLALL_UNDERGROUND_TOLERANCE    = 1.5

local KILLALL_TRIGGER_RADIUS           = 6.0
local KILLALL_VALIDATION_TOLERANCE     = 1.0
local KILLALL_VALIDATION_FRAMES        = 3

local KillAll = {}
KillAll.__index = KillAll

function KillAll.new()
    return setmetatable({
        running = false,
        connections = ConnectionManager.new(),
        savedCollisions = {},
        swingAccumulator = 0,
        safePosition = nil,
        sticking = false,
        stickingStartTime = 0,
        lastEnemyHealth = nil,
        lastHealthChangeTime = 0,
        lastTargetSeenTime = 0,
        currentTarget = nil,
        lockedTargetPlayer = nil,
        lastStickTarget = nil,
        lastStickTargetHum = nil,
        hiding = false,
        hidingUntil = 0,
        targetFloor = nil,
        targetFloorY = nil,
        lastFloorTarget = nil,
        inKnifeRangeNow = false,
        forceDescent = false,
        jitterSide = 1,
        jitterCurrent = 0,
        jitterNextSwitch = 0,
        lastSetCFrame = nil,
        validFrames = 0,
        killActivated = false,
    }, KillAll)
end

function KillAll:DisableCollisions()
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            if self.savedCollisions[part] == nil then
                self.savedCollisions[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end

function KillAll:RestoreCollisions()
    for part, value in pairs(self.savedCollisions) do
        if part.Parent then
            pcall(function() part.CanCollide = value end)
        end
    end
    table.clear(self.savedCollisions)
end

function KillAll:GetRoot(p)
    local char = p and p.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then return root end
    return nil
end

function KillAll:GetHumanoid(p)
    local char = p and p.Character
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function KillAll:GetFloorY(targetRoot)
    local hum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    local hip = hum and tonumber(hum.HipHeight) or 2
    return targetRoot.Position.Y - hip - targetRoot.Size.Y / 2
end

function KillAll:GetPlatformFloorY(targetRoot)
    if not targetRoot then return nil end
    if self.lastFloorTarget == targetRoot and self.targetFloorY then
        return self.targetFloorY
    end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { player.Character, targetRoot.Parent }
    local origin = targetRoot.Position + Vector3.new(0, 3, 0)
    local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)
    if result then
        self.targetFloorY = result.Position.Y
        self.lastFloorTarget = targetRoot
        return self.targetFloorY
    end
    self.targetFloorY = self:GetFloorY(targetRoot)
    self.lastFloorTarget = targetRoot
    return self.targetFloorY
end

function KillAll:IsInKnifeRange(myRoot, targetRoot)
    if not myRoot or not targetRoot then return false end
    local delta = targetRoot.Position - myRoot.Position
    local horizontal = Vector3.new(delta.X, 0, delta.Z).Magnitude
    local vertical = math.abs(delta.Y)
    return horizontal <= (KILLALL_APPROACH_DISTANCE + KILLALL_APPROACH_TOLERANCE) and vertical <= KILLALL_KNIFE_RANGE_Y
end

function KillAll:IsLockedTargetValid()
    local lp = self.lockedTargetPlayer
    if not lp then return false end
    if not lp.Parent then return false end
    if not esEnemigoValido(lp) then return false end
    local char = lp.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end
    if hum.Health <= 0 then return false end
    return root
end

function KillAll:GetPredictedPos(targetRoot)
    local vel = Vector3.zero
    if targetRoot:IsA("BasePart") then
        vel = targetRoot.AssemblyLinearVelocity
    end
    vel = Vector3.new(vel.X, 0, vel.Z)
    return targetRoot.Position + vel * KILLALL_PREDICTION_TIME
end

function KillAll:GetClosestEnemy()
    local myRoot = self:GetRoot(player)
    if not myRoot then return nil end

    local lockedRoot = self:IsLockedTargetValid()
    if lockedRoot then
        return lockedRoot
    end

    self.lockedTargetPlayer = nil
    self.currentTarget = nil

    local best, bestDist, bestPlayer = nil, nil, nil
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and esEnemigoValido(other) then
            local hum = self:GetHumanoid(other)
            local root = self:GetRoot(other)
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if not bestDist or dist < bestDist then
                    best, bestDist, bestPlayer = root, dist, other
                end
            end
        end
    end

    if bestPlayer then
        self.lockedTargetPlayer = bestPlayer
    end

    return best
end

function KillAll:IsInMatch()
    return IsInMatchStrict()
end

function KillAll:ResetState()
    self.sticking = false
    self.stickingStartTime = 0
    self.lastEnemyHealth = nil
    self.lastHealthChangeTime = 0
    self.targetFloor = nil
    self.inKnifeRangeNow = false
    self.forceDescent = false
    self.jitterSide = 1
    self.jitterCurrent = 0
    self.jitterNextSwitch = 0
    self.lastSetCFrame = nil
    self.validFrames = 0
    self.killActivated = false
    self:RestoreCollisions()
    local hum = self:GetHumanoid(player)
    if hum and hum.PlatformStand then
        pcall(function() hum.PlatformStand = false end)
    end
end

function KillAll:ReturnToSafePosition(myRoot)
    if not self.safePosition or not myRoot then return end
    local currentY = myRoot.Position.Y
    if currentY < (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD) then
        pcall(function()
            myRoot.CFrame = CFrame.new(self.safePosition)
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

function KillAll:ForceReturnToSafe(myRoot)
    if not self.safePosition or not myRoot then return end
    pcall(function()
        myRoot.CFrame = CFrame.new(self.safePosition)
        myRoot.AssemblyLinearVelocity  = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

function KillAll:IsFallingIntoVoid(myRoot)
    if not self.safePosition or not myRoot then return false end
    return myRoot.Position.Y < (self.safePosition.Y - KILLALL_VOID_PROTECTION)
end

function KillAll:HideBelowMap()
    local myRoot = self:GetRoot(player)
    if not myRoot then return end
    local baseY = self.safePosition and self.safePosition.Y or myRoot.Position.Y
    local hideY = baseY - KILLALL_HIDE_DEPTH
    local currentX, currentZ = myRoot.Position.X, myRoot.Position.Z
    pcall(function()
        myRoot.CFrame = CFrame.new(currentX, hideY, currentZ)
        myRoot.AssemblyLinearVelocity  = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
    self.hiding = true
    self.hidingUntil = os.clock() + KILLALL_HIDE_DURATION
end

function KillAll:IsKnife(tool)
    if not (tool and tool:IsA("Tool")) then return false end
    if tool:FindFirstChild("fire") or tool:FindFirstChild("showBeam") then return false end
    return tool:FindFirstChild("Slash") ~= nil or tool:FindFirstChild("SlashStart") ~= nil
end

function KillAll:FindKnife()
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if self:IsKnife(child) then return child, true end
        end
    end
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if self:IsKnife(child) then return child, false end
        end
    end
    return nil, false
end

function KillAll:SwingKnife(dt)
    self.swingAccumulator = self.swingAccumulator + dt
    if self.swingAccumulator < KILLALL_SWING_INTERVAL then return end
    self.swingAccumulator = 0

    local tool, equipped = self:FindKnife()
    if not tool then return end

    if not equipped then
        local hum = self:GetHumanoid(player)
        if not hum then return end
        pcall(function() hum:EquipTool(tool) end)
        if tool.Parent ~= player.Character then return end
    end
    pcall(function() tool:Activate() end)
end

function KillAll:UpdateJitter(dt)
    local now = os.clock()
    if now >= self.jitterNextSwitch then
        self.jitterSide = (math.random() < 0.5) and 1 or -1
        self.jitterNextSwitch = now + KILLALL_JITTER_SWITCH_MIN + math.random() * (KILLALL_JITTER_SWITCH_MAX - KILLALL_JITTER_SWITCH_MIN)
    end
    local targetOffset = self.jitterSide * KILLALL_JITTER_AMPLITUDE
    self.jitterCurrent = self.jitterCurrent + (targetOffset - self.jitterCurrent) * math.clamp(dt * KILLALL_JITTER_LERP_SPEED, 0, 1)
end

function KillAll:CheckServerValidation(myRoot)
    if self.killActivated then return true end
    if not self.lastSetCFrame then return false end
    local desiredPos = self.lastSetCFrame.Position
    local actualPos = myRoot.Position
    local diff = (actualPos - desiredPos).Magnitude

    if diff <= KILLALL_VALIDATION_TOLERANCE then
        self.validFrames = self.validFrames + 1
        if self.validFrames >= KILLALL_VALIDATION_FRAMES then
            self.killActivated = true
            self.swingAccumulator = KILLALL_SWING_INTERVAL
            return true
        end
    else
        self.validFrames = 0
    end
    return false
end

function KillAll:ForceUnderground(myRoot, targetRoot)
    if not myRoot or not targetRoot then return end
    local floorY = self:GetPlatformFloorY(targetRoot)
    if not floorY then return end
    local targetY = floorY - KILLALL_UNDERGROUND_DEPTH
    if myRoot.Position.Y > targetY + KILLALL_UNDERGROUND_TOLERANCE then
        pcall(function()
            myRoot.CFrame = CFrame.new(myRoot.Position.X, targetY, myRoot.Position.Z)
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end

function KillAll:ApproachTarget(myRoot, targetRoot, dt)
    dt = dt or 0
    local myPos = myRoot.Position
    local targetPos = targetRoot.Position

    local deltaXZ = Vector3.new(targetPos.X - myPos.X, 0, targetPos.Z - myPos.Z)
    local hDist = deltaXZ.Magnitude

    if hDist <= KILLALL_TRIGGER_RADIUS then
        if not self.sticking then
            local lookTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
            local targetCF = CFrame.lookAt(myPos, lookTarget)
            self.lastSetCFrame = targetCF
            pcall(function()
                myRoot.CFrame = targetCF
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)

            if self:CheckServerValidation(myRoot) then
                self.sticking = true
                self.stickingStartTime = os.clock()
                self.lastStickTarget = targetRoot
                self.targetFloor = nil
                self.forceDescent = true
                local hum = self:GetHumanoid(targetRoot.Parent)
                self.lastEnemyHealth = hum and hum.Health or nil
                self.lastHealthChangeTime = os.clock()
                self.lastStickTargetHum = hum
                self.jitterCurrent = 0
            end
        end
        return
    end

    self.lastSetCFrame = nil
    self.validFrames = 0

    local dir = deltaXZ.Unit
    local perp = Vector3.new(-dir.Z, 0, dir.X)

    self:UpdateJitter(dt)

    local step = KILLALL_MOVE_SPEED * dt
    local travel = math.min(step, math.max(0, hDist - KILLALL_TRIGGER_RADIUS))

    local maxJitterByDistance = math.sqrt(math.max(0, travel * (2 * hDist - travel))) * 0.85
    local jitterFactor = math.clamp((hDist - KILLALL_TRIGGER_RADIUS) / 8, 0, 1)
    local desiredJitter = self.jitterCurrent * jitterFactor
    local actualJitter = math.clamp(desiredJitter, -maxJitterByDistance, maxJitterByDistance)

    local baseX = myPos.X + dir.X * travel
    local baseZ = myPos.Z + dir.Z * travel
    local newX = baseX + perp.X * actualJitter
    local newZ = baseZ + perp.Z * actualJitter

    local floorY = self:GetPlatformFloorY(targetRoot)
    local newY
    if floorY then
        newY = floorY - KILLALL_UNDERGROUND_DEPTH
    else
        newY = myPos.Y
    end

    local newPos = Vector3.new(newX, newY, newZ)
    local lookTarget = Vector3.new(targetPos.X, newPos.Y, targetPos.Z)
    local newCFrame = CFrame.lookAt(newPos, lookTarget)

    pcall(function()
        myRoot.CFrame = newCFrame
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

function KillAll:CanStickToTarget(myRoot, targetRoot)
    if not targetRoot or not targetRoot.Parent then return false end

    local targetPlayer = Players:GetPlayerFromCharacter(targetRoot.Parent)
    if not targetPlayer or not esEnemigoValido(targetPlayer) then return false end

    local targetHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    if not targetHum or targetHum.Health <= 0 then return false end

    local distHorizontal = (Vector3.new(myRoot.Position.X, 0, myRoot.Position.Z) - Vector3.new(targetRoot.Position.X, 0, targetRoot.Position.Z)).Magnitude
    if distHorizontal > KILLALL_STICK_MAX_DISTANCE then return false end

    return true
end

function KillAll:StickToTarget(myRoot, targetRoot)
    local targetPos = targetRoot.Position
    local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    local onGround  = targetHum and targetHum.FloorMaterial ~= Enum.Material.Air

    if targetRoot ~= self.lastStickTarget then
        self.lastStickTarget = targetRoot
        self.targetFloor     = nil
    end

    if onGround or not self.targetFloor then
        self.targetFloor = self:GetFloorY(targetRoot)
    end

    local myPos = myRoot.Position
    local dir = Vector3.new(myPos.X - targetPos.X, 0, myPos.Z - targetPos.Z)
    if dir.Magnitude < 0.05 then
        dir = Vector3.new(0, 0, 1)
    else
        dir = dir.Unit
    end

    local x = targetPos.X + dir.X * KILLALL_APPROACH_DISTANCE
    local z = targetPos.Z + dir.Z * KILLALL_APPROACH_DISTANCE

    local inRange = self:IsInKnifeRange(myRoot, targetRoot)
    local y
    if inRange and not self.forceDescent then
        y = myPos.Y
    else
        y = self.targetFloor - KILLALL_HEIGHT_OFFSET
        if inRange then
            self.forceDescent = false
        end
    end

    pcall(function()
        myRoot.CFrame = CFrame.new(x, y, z) * CFrame.Angles(math.rad(KILLALL_PITCH_DEGREES), 0, 0)
        myRoot.AssemblyLinearVelocity  = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

function KillAll:CheckEnemyHealth(targetRoot)
    local targetHum = targetRoot.Parent and targetRoot.Parent:FindFirstChildOfClass("Humanoid")
    if not targetHum then return false end

    local currentHealth = targetHum.Health

    if self.lastEnemyHealth == nil then
        self.lastEnemyHealth = currentHealth
        self.lastHealthChangeTime = os.clock()
        return false
    end

    if currentHealth < self.lastEnemyHealth then
        self.lastEnemyHealth = currentHealth
        self.lastHealthChangeTime = os.clock()
        return false
    end

    if (os.clock() - self.lastHealthChangeTime) >= KILLALL_HEALTH_STALL_TIME then
        return true
    end

    return false
end

function KillAll:Update(dt)
    if not self:IsInMatch() then
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastFloorTarget = nil
        self.targetFloorY = nil
        return
    end

    local myRoot = self:GetRoot(player)
    if not myRoot then
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        return
    end

    if self.lastStickTargetHum then
        local hum = self.lastStickTargetHum
        if not hum.Parent or hum.Health <= 0 then
            self:HideBelowMap()
            self.inKnifeRangeNow      = false
            self.forceDescent         = false
            self.lastStickTargetHum   = nil
            self.lastStickTarget      = nil
            self.sticking             = false
            self.stickingStartTime    = 0
            self.lastEnemyHealth      = nil
            self.lastHealthChangeTime = 0
            self.targetFloor          = nil
            self.killActivated        = false
            self.validFrames          = 0
            self.lastSetCFrame        = nil
            return
        end
    end

    if self.hiding then
        if os.clock() >= self.hidingUntil then
            self.hiding = false
        else
            pcall(function()
                myRoot.AssemblyLinearVelocity  = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
            return
        end
    end

    if self:IsFallingIntoVoid(myRoot) then
        self:ForceReturnToSafe(myRoot)
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        local hum = self:GetHumanoid(player)
        if hum then
            pcall(function() hum.PlatformStand = false end)
        end
        return
    end

    local target = self:GetClosestEnemy()

    if target then
        self.currentTarget      = target
        self.lastTargetSeenTime = os.clock()
    end

    if not target then
        local justLostTarget = (os.clock() - (self.lastTargetSeenTime or 0)) < KILLALL_TARGET_GRACE_TIME
        local isUnderground  = self.safePosition and myRoot.Position.Y < (self.safePosition.Y - 2)

        if justLostTarget and isUnderground then
            pcall(function()
                myRoot.AssemblyLinearVelocity  = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end)
            return
        end

        self:ReturnToSafePosition(myRoot)
        self:ResetState()
        self.currentTarget = nil
        self.lockedTargetPlayer = nil
        self.lastStickTarget = nil
        self.lastFloorTarget = nil
        self.targetFloorY = nil
        if self.safePosition then
            local hum = self:GetHumanoid(player)
            if hum then
                pcall(function() hum.PlatformStand = false end)
            end
        end
        return
    end

    self:DisableCollisions()

    if self.lastStickTarget then
        local inRange = self:IsInKnifeRange(myRoot, self.lastStickTarget)
        if inRange and not self.inKnifeRangeNow then
            self.swingAccumulator = KILLALL_SWING_INTERVAL
            self.inKnifeRangeNow = true
        elseif not inRange then
            self.inKnifeRangeNow = false
        end
    end

    self:SwingKnife(dt or 0)

    local hum = self:GetHumanoid(player)
    if hum and not hum.PlatformStand then
        pcall(function() hum.PlatformStand = true end)
    end

    if self.safePosition and myRoot.Position.Y >= (self.safePosition.Y - KILLALL_SAFE_GROUND_THRESHOLD) then
        self.safePosition = Vector3.new(myRoot.Position.X, self.safePosition.Y, myRoot.Position.Z)
    end

    if not self.sticking then
        self:ForceUnderground(myRoot, target)
    end

    if self.sticking then
        local lostTarget  = (target ~= self.lastStickTarget)
        local timedOut    = (os.clock() - self.stickingStartTime) > KILLALL_STICK_MAX_TIME
        local cannotStick = not self:CanStickToTarget(myRoot, target)
        local cannotKill  = self:CheckEnemyHealth(target)

        if lostTarget or timedOut or cannotStick or cannotKill then
            self.sticking             = false
            self.stickingStartTime    = 0
            self.lastEnemyHealth      = nil
            self.lastHealthChangeTime = 0
            self.targetFloor          = nil
            self.inKnifeRangeNow      = false
            self.forceDescent         = false
            self.killActivated        = false
            self.validFrames          = 0
            self.lastSetCFrame        = nil

            if lostTarget then
                self.lastStickTarget = nil
            end
        else
            self:StickToTarget(myRoot, target)
            return
        end
    end

    self:ApproachTarget(myRoot, target, dt or 0)
end

function KillAll:Start()
    if self.running then return end
    self.running = true
    self.swingAccumulator      = 0
    self.sticking              = false
    self.stickingStartTime     = 0
    self.lastEnemyHealth       = nil
    self.lastHealthChangeTime  = 0
    self.lastTargetSeenTime    = 0
    self.currentTarget         = nil
    self.lockedTargetPlayer    = nil
    self.lastStickTarget       = nil
    self.lastStickTargetHum    = nil
    self.hiding                = false
    self.hidingUntil           = 0
    self.targetFloor           = nil
    self.targetFloorY          = nil
    self.lastFloorTarget       = nil
    self.inKnifeRangeNow       = false
    self.forceDescent          = false
    self.jitterSide = 1
    self.jitterCurrent = 0
    self.jitterNextSwitch = 0
    self.lastSetCFrame = nil
    self.validFrames = 0
    self.killActivated = false

    local myRoot = self:GetRoot(player)
    if myRoot then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { player.Character }

        local origin = myRoot.Position + Vector3.new(0, 5, 0)
        local result = workspace:Raycast(origin, Vector3.new(0, -500, 0), params)

        if result then
            self.safePosition = Vector3.new(myRoot.Position.X, result.Position.Y + 3, myRoot.Position.Z)
        else
            self.safePosition = myRoot.Position
        end
    else
        self.safePosition = nil
    end

    self.connections:Add(RunService.Heartbeat:Connect(function(dt)
        if not self.running then return end
        self:Update(dt)
    end))

    self.connections:Add(player.CharacterAdded:Connect(function()
        table.clear(self.savedCollisions)
        self.sticking              = false
        self.safePosition          = nil
        self.stickingStartTime     = 0
        self.lastEnemyHealth       = nil
        self.lastHealthChangeTime  = 0
        self.lastTargetSeenTime    = 0
        self.currentTarget         = nil
        self.lockedTargetPlayer    = nil
        self.lastStickTarget       = nil
        self.lastStickTargetHum    = nil
        self.hiding                = false
        self.hidingUntil           = 0
        self.targetFloor           = nil
        self.targetFloorY          = nil
        self.lastFloorTarget       = nil
        self.inKnifeRangeNow       = false
        self.forceDescent          = false
        self.jitterSide = 1
        self.jitterCurrent = 0
        self.jitterNextSwitch = 0
        self.lastSetCFrame = nil
        self.validFrames = 0
        self.killActivated = false
    end))
end

function KillAll:Stop()
    if not self.running then return end

    local myRoot = self:GetRoot(player)
    if myRoot and self.safePosition then
        pcall(function()
            myRoot.CFrame = CFrame.new(self.safePosition)
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    self.running = false
    self.connections:Cleanup()
    self.connections = ConnectionManager.new()
    self:ResetState()
    self.currentTarget      = nil
    self.lockedTargetPlayer = nil
    self.lastStickTarget    = nil
    self.lastStickTargetHum = nil
    self.hiding             = false
    self.hidingUntil        = 0
    self.inKnifeRangeNow    = false
    self.forceDescent       = false
    self.killActivated      = false
    self.targetFloorY       = nil
    self.lastFloorTarget    = nil
end

KillAllInstance = KillAll.new() 

Tabs.Inicio:Section({ Title = "Perfil del Jugador", Icon = "solar:user-bold" })

local execName = "Desconocido"
pcall(function() execName = identifyexecutor and identifyexecutor() or "Desconocido" end)

Tabs.Inicio:Paragraph({
    Title = "Usuario: " .. player.DisplayName,
    Desc = "Usuario: @" .. player.Name .. "\nID: " .. player.UserId .. "\nEdad de la cuenta: " .. player.AccountAge .. " días",
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=420&h=420",
    ImageSize = 48
})

Tabs.Inicio:Paragraph({ Title = "Sistema", Desc = "Ejecutor actual: " .. execName })

Tabs.Inicio:Paragraph({
    Title = "Comunidad",
    Desc = "Activos: 2038",
    Image = "rbxthumb://type=Asset&id=118232139384203&w=420&h=420",
    ImageSize = 32
})

Tabs.Inicio:Section({ Title = "Información del Servidor", Icon = "solar:server-bold" })

local gameNameStr = "Desconocido"
pcall(function() gameNameStr = MarketplaceService:GetProductInfo(game.PlaceId).Name end)

Tabs.Inicio:Paragraph({
    Title = "Juego Actual",
    Desc = gameNameStr .. "\nPlace ID: " .. game.PlaceId,
    Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
    ImageSize = 48
})

Tabs.ExtrasScripts:Section({ Title = "Scripts Extras", Icon = "solar:code-bold" })

Tabs.ExtrasScripts:Button({
    Title = "Copiar avatares",
    Desc = "Las animaciones ponlas desde Open HUB a tu gusto.",
    Icon = "solar:user-hand-up-bold",
    Variant = "Primary",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/5MA88wuB"))()
        end)
    end
})

task.wait()

Tabs.Aim:Section({ Title = "Auto Shoot", Icon = "solar:target-bold" })

UIElements.TogAutoShoot = Tabs.Aim:Toggle({
    Title = "Auto Shoot (Normal - Cabeza/Torso)",
    Desc = "Dispara automáticamente al torso o cabeza sin fallar.",
    Callback = function(Value)
        autoShootEnabled = Value
        if not Value and not autoShootAgresivoEnabled then getgenv().NexvyrTargetPart = nil end
    end
})

UIElements.TogAutoShootAgr = Tabs.Aim:Toggle({
    Title = "Auto Shoot (Agresivo - Hitbox Completa)",
    Desc = "Dispara a cualquier píxel visible del cuerpo del enemigo.",
    Callback = function(Value)
        autoShootAgresivoEnabled = Value
        if not Value and not autoShootEnabled then getgenv().NexvyrTargetPart = nil end
    end
})

UIElements.DropAutoShootPart = Tabs.Aim:Dropdown({
    Title = "Target: Parte del cuerpo",
    Values = { "Cabeza", "Torso", "Cuerpo Completo" },
    Value = "Cabeza",
    Callback = function(Value) autoShootTargetPart = Value end
})

local equipGunEnabled = false

UIElements.TogEquipGun = Tabs.Aim:Toggle({
    Title = "Equipar pistola",
    Desc = "Equipa rápidamente la pistola.",
    Value = false,
    Callback = function(Value)
        equipGunEnabled = Value
    end
})

task.spawn(function()
    local gunRayParams = RaycastParams.new()
    gunRayParams.FilterType = Enum.RaycastFilterType.Exclude

    while task.wait(0.1) do
        if not equipGunEnabled then continue end
        if not IsInMatchStrict() then continue end

        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then continue end
        if hum.Health <= 0 then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp then continue end
        local originPos = head and head.Position or hrp.Position

        local hayEnemigoVisible = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and esEnemigoValido(p) then
                local pChar = p.Character
                if pChar then
                    local targetPart = pChar:FindFirstChild("Head")
                        or pChar:FindFirstChild("UpperTorso")
                        or pChar:FindFirstChild("Torso")
                        or pChar:FindFirstChild("HumanoidRootPart")
                    if targetPart and targetPart:IsA("BasePart") then
                        gunRayParams.FilterDescendantsInstances = { char, pChar }
                        local result = workspace:Raycast(originPos, targetPart.Position - originPos, gunRayParams)
                        if not result and IsInMatchStrict() then
                            hayEnemigoVisible = true
                            break
                        end
                    end
                end
            end
        end

        if not hayEnemigoVisible then continue end

        local pistola = obtenerPistola()
        if not pistola then continue end

        char = player.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then continue end
        pistola = obtenerPistola()
        if not pistola then continue end

        if pistola.Parent ~= char then
            pcall(function() hum:EquipTool(pistola) end)
        end

        task.wait(0.35)

        char = player.Character
        hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hum then
            pcall(function() hum:UnequipTools() end)
        end

        task.wait(1.9)
    end
end)

Tabs.Aim:Space()
Tabs.Aim:Divider()
Tabs.Aim:Space()

Tabs.Aim:Section({ Title = "Silent Aim + Fov", Icon = "solar:radar-bold" })

UIElements.TogSilentAimManual = Tabs.Aim:Toggle({
    Title = "Silent Aim",
    Desc = "Redirige las balas al enemigo.",
    Callback = function(Value)
        silentAimManualEnabled = Value
        if not Value and not autoShootEnabled and not autoShootAgresivoEnabled then getgenv().NexvyrTargetPart = nil end
    end
})

UIElements.DropSilentAimPart = Tabs.Aim:Dropdown({
    Title = "Target: Parte del cuerpo",
    Values = { "Cabeza", "Torso", "Cuerpo Completo" },
    Value = "Cabeza",
    Callback = function(Value) silentAimTargetPart = Value end
})

UIElements.TogSilentAimFOV = Tabs.Aim:Toggle({
    Title = "Silent Aim (Con FOV)",
    Desc = "Igual que el Silent Aim, pero solo afecta a los enemigos dentro del círculo.",
    Callback = function(Value)
        silentAimFovEnabled = Value
        if not Value and not silentAimManualEnabled and not autoShootEnabled and not autoShootAgresivoEnabled then getgenv().NexvyrTargetPart = nil end
    end
})

UIElements.TogShowFOV = Tabs.Aim:Toggle({
    Title = "Mostrar Círculo FOV",
    Desc = "Dibuja un círculo en pantalla.",
    Callback = function(Value) fovVisiblePreference = Value end
})

UIElements.SliFOVSize = Tabs.Aim:Slider({
    Title = "Tamaño del FOV",
    Step = 1,
    Value = { Min = 10, Max = 800, Default = 120 },
    Callback = function(v) fovRadius = v end
})

getgenv().NexvyrTargetPart = nil

local oldNamecall
if hookmetamethod and getnamecallmethod and checkcaller then
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and getgenv().NexvyrTargetPart then
            if method == "Raycast" and self == workspace then
                local target = getgenv().NexvyrTargetPart
                if target and target.Parent then
                    local origin, direction, p3 = ...
                    if typeof(direction) == "Vector3" and direction.Magnitude > 20 then
                        local cameraOrigin = workspace.CurrentCamera.CFrame.Position
                        if (origin - cameraOrigin).Magnitude >= 1 then
                            local newDir = (target.Position - origin).Unit * 5000
                            return oldNamecall(self, origin, newDir, p3)
                        end
                    end
                else
                    getgenv().NexvyrTargetPart = nil
                end
            elseif self == workspace and typeof(method) == "string" and method:sub(1, 13) == "FindPartOnRay" then
                local target = getgenv().NexvyrTargetPart
                if target and target.Parent then
                    local ray, p2, p3, p4 = ...
                    if typeof(ray) == "Ray" and ray.Direction.Magnitude > 20 then
                        local cameraOrigin = workspace.CurrentCamera.CFrame.Position
                        if (ray.Origin - cameraOrigin).Magnitude >= 1 then
                            local newRay = Ray.new(ray.Origin, (target.Position - ray.Origin).Unit * 5000)
                            return oldNamecall(self, newRay, p2, p3, p4)
                        end
                    end
                else
                    getgenv().NexvyrTargetPart = nil
                end
            end
        end
        return oldNamecall(self, ...)
    end)
else
    warn("Hook de raycast no disponible en este entorno.")
end

task.spawn(function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    while task.wait(0.1) do
        if (autoShootEnabled or autoShootAgresivoEnabled) and not estaEnLobby() then
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local arma = char:FindFirstChildOfClass("Tool")
            if not arma or not arma:FindFirstChild("Handle") then
                getgenv().NexvyrTargetPart = nil
                continue
            end
            if esCuchillo(arma) then
                getgenv().NexvyrTargetPart = nil
                continue
            end
            local closestTargetPart = nil
            local shortestDistance = math.huge
            local myPos = char.HumanoidRootPart.Position
            local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and isEnemy(p) and p.Character then
                    local enemyHum = p.Character:FindFirstChild("Humanoid")
                    if enemyHum and enemyHum.Health > 0 then
                        params.FilterDescendantsInstances = { char, p.Character }
                        local function ProcesarParte(part)
                            local dist = (part.Position - myPos).Magnitude
                            if dist < shortestDistance then
                                local size = part.Size
                                local offsets = {
                                    Vector3.new(0, 0, 0),
                                    Vector3.new(0, size.Y / 2.1, 0),
                                    Vector3.new(0, -size.Y / 2.1, 0)
                                }
                                local isVisible = false
                                for _, offset in ipairs(offsets) do
                                    if not workspace:Raycast(headPos, (part.CFrame * offset) - headPos, params) then
                                        isVisible = true
                                        break
                                    end
                                end
                                if isVisible then
                                    shortestDistance = dist
                                    closestTargetPart = part
                                end
                            end
                        end
                        if autoShootAgresivoEnabled then
                            for _, part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    ProcesarParte(part)
                                end
                            end
                        elseif autoShootTargetPart == "Cabeza" then
                            local head = p.Character:FindFirstChild("Head")
                            if head and head:IsA("BasePart") then ProcesarParte(head) end
                        elseif autoShootTargetPart == "Torso" then
                            local partesClave = { "UpperTorso", "Torso", "HumanoidRootPart" }
                            for _, partName in ipairs(partesClave) do
                                local part = p.Character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then ProcesarParte(part) end
                            end
                        elseif autoShootTargetPart == "Cuerpo Completo" then
                            for _, part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    ProcesarParte(part)
                                end
                            end
                        end
                    end
                end
            end
            if closestTargetPart then
                getgenv().NexvyrTargetPart = closestTargetPart
                pcall(function()
                    arma:Activate()
                    task.delay(0.05, function()
                        if arma.Parent == char then arma:Deactivate() end
                    end)
                end)
                task.wait(0.2)
            else
                getgenv().NexvyrTargetPart = nil
            end
        end
    end
end)

task.spawn(function()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    while task.wait(0.1) do
        if (silentAimManualEnabled or silentAimFovEnabled) and not estaEnLobby() then
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local closestTargetPart = nil
            local shortestDistToCenter = math.huge
            local shortestDistanceFisica = math.huge
            local myPos = char.HumanoidRootPart.Position
            local headPos = char:FindFirstChild("Head") and char.Head.Position or myPos
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and isEnemy(p) and p.Character then
                    local enemyHum = p.Character:FindFirstChild("Humanoid")
                    if enemyHum and enemyHum.Health > 0 then
                        local partesAEscanear = {}
                        if silentAimTargetPart == "Cabeza" then
                            local head = p.Character:FindFirstChild("Head")
                            if head then table.insert(partesAEscanear, head) end
                        elseif silentAimTargetPart == "Torso" then
                            local partesClave = { "UpperTorso", "Torso", "HumanoidRootPart" }
                            for _, partName in ipairs(partesClave) do
                                local part = p.Character:FindFirstChild(partName)
                                if part and part:IsA("BasePart") then table.insert(partesAEscanear, part) end
                            end
                        elseif silentAimTargetPart == "Cuerpo Completo" then
                            for _, part in ipairs(p.Character:GetChildren()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then table.insert(partesAEscanear, part) end
                            end
                        end
                        params.FilterDescendantsInstances = { char, p.Character }
                        for _, part in ipairs(partesAEscanear) do
                            local distFisica = (part.Position - myPos).Magnitude
                            local pos2D, onScreen = camera:WorldToViewportPoint(part.Position)
                            local distToCenter = (Vector2.new(pos2D.X, pos2D.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
                            local pasaFiltro = false
                            if silentAimFovEnabled then
                                if onScreen and distToCenter <= fovRadius and distToCenter < shortestDistToCenter then pasaFiltro = true end
                            elseif silentAimManualEnabled then
                                if distFisica < shortestDistanceFisica then pasaFiltro = true end
                            end
                            if pasaFiltro then
                                local raycastResult = workspace:Raycast(headPos, part.Position - headPos, params)
                                if not raycastResult then
                                    if silentAimFovEnabled then
                                        shortestDistToCenter = distToCenter; closestTargetPart = part
                                    else
                                        shortestDistanceFisica = distFisica; closestTargetPart = part
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if closestTargetPart then
                getgenv().NexvyrTargetPart = closestTargetPart
            else
                if not autoShootEnabled and not autoShootAgresivoEnabled then
                    getgenv().NexvyrTargetPart = nil
                end
            end
        end
    end
end)

Tabs.KillAll:Section({ Title = "Kill All", Icon = "solar:danger-triangle-bold" })

UIElements.TogKillAll = Tabs.KillAll:Toggle({
    Title = "Kill All",
    Desc = "Fase beta",
    Value = false,
    Callback = function(Value)
        KillAllEnabled = Value
        if Value then
            KillAllInstance:Start()
        else
            KillAllInstance:Stop()
        end
    end
})

Tabs.KillAll:Keybind({
    Title = "Tecla Kill All",
    Desc = "Tecla para activar/desactivar Kill All",
    Value = Keybinds.ToggleKillAll,
    Callback = function(k)
        Keybinds.ToggleKillAll = k
    end
})

Tabs.KillAll:Slider({
    Title = "Vibración",
    Desc = "Vibración corta mientras se acerca",
    Step = 0.05,
    Value = { Min = 0.0, Max = 3.0, Default = 0.8 },
    Callback = function(v) KILLALL_JITTER_AMPLITUDE = v end
})

Tabs.KillAll:Slider({
    Title = "Radio de Activación",
    Desc = "Distancia en la que se activa",
    Step = 0.5,
    Value = { Min = 2.75, Max = 9.0, Default = 6.0 },
    Callback = function(v) KILLALL_TRIGGER_RADIUS = v end
})

Tabs.KillAll:Space()
Tabs.KillAll:Divider()
Tabs.KillAll:Space()
Tabs.KillAll:Section({ Title = "Hitbox Expander", Icon = "solar:box-bold" })

Tabs.KillAll:Toggle({
    Title = "Activar Hitbox",
    Desc = "Añade una hitbox cúbica a los enemigos.",
    Value = false,
    Callback = function(Value)
        hitboxEnabled = Value
        if not Value then limpiarHitboxes() end
    end
})

Tabs.KillAll:Toggle({
    Title = "Hitbox Invisible",
    Desc = "Hace la hitbox completamente transparente.",
    Value = false,
    Callback = function(Value) hitboxInvisible = Value end
})

Tabs.KillAll:Slider({
    Title = "Tamaño de la Hitbox",
    Step = 0.5,
    Value = { Min = 1.0, Max = 18.0, Default = 3.5 },
    Callback = function(v) hitboxSize = v end
})

Tabs.KillAll:Colorpicker({
    Title = "Color de la Hitbox",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c) hitboxColor = c end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Keybinds.ToggleKillAll] then
        KillAllEnabled = not KillAllEnabled
        if UIElements.TogKillAll then
            pcall(function() UIElements.TogKillAll:Set(KillAllEnabled) end)
        end
        if KillAllEnabled then
            KillAllInstance:Start()
        else
            KillAllInstance:Stop()
        end
    end
end)

Tabs.RachaFarm:Section({ Title = "Auto Teleport Main/Alt", Icon = "solar:map-arrow-square-bold" })

local autoTPMainToggle, autoTPAltToggle

autoTPMainToggle = Tabs.RachaFarm:Toggle({
    Title = "Auto Teleport (Main)",
    Desc = "Te teletransporta a la plataforma Main. Se desactiva si activás Alt.",
    Value = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Main"
            if autoTPAltToggle then pcall(function() autoTPAltToggle:Set(false) end) end
            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Main" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end
})

autoTPAltToggle = Tabs.RachaFarm:Toggle({
    Title = "Auto Teleport (Alt)",
    Desc = "Te teletransporta a la plataforma Alt. Se desactiva si activás Main.",
    Value = false,
    Callback = function(value)
        if value then
            AutoTeleportMainAltInstance.ActiveRole = "Alt"
            if autoTPMainToggle then pcall(function() autoTPMainToggle:Set(false) end) end
            AutoTeleportMainAltInstance:Stop()
            AutoTeleportMainAltInstance:Start()
        else
            if AutoTeleportMainAltInstance.ActiveRole == "Alt" then
                AutoTeleportMainAltInstance.ActiveRole = nil
                AutoTeleportMainAltInstance:Stop()
            end
        end
    end
})

Tabs.RachaFarm:Dropdown({
    Title = "Tipo de Duelo",
    Values = { "1v1", "2v2", "3v3", "4v4" },
    Value = "1v1",
    Callback = function(value)
        if PadZoneConfig["Right Platforms"][value] then AutoTeleportMainAltInstance.DuelType = value
        else AutoTeleportMainAltInstance.DuelType = "1v1" end
        AutoTeleportMainAltInstance:Kick()
    end
})

Tabs.RachaFarm:Dropdown({
    Title = "Fila de Plataformas",
    Values = { "Right Platforms", "Left Platforms" },
    Value = "Right Platforms",
    Callback = function(value)
        if PadZoneConfig[value] then AutoTeleportMainAltInstance.PlatformRow = value
        else AutoTeleportMainAltInstance.PlatformRow = "Right Platforms" end
        AutoTeleportMainAltInstance:Kick()
    end
})

Tabs.Vis:Section({ Title = "Configuración de ESP", Icon = "solar:eye-bold" })

UIElements.TogEsp = Tabs.Vis:Toggle({
    Title = "ESP Jugadores",
    Callback = function(s) espEnabled = s end
})

UIElements.ColEsp = Tabs.Vis:Colorpicker({
    Title = "Color del ESP",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(c) espColor = c end
})

Tabs.Vis:Space()
Tabs.Vis:Divider()
Tabs.Vis:Space()
Tabs.Vis:Section({ Title = "Filtros de ESP", Icon = "solar:filter-bold" })

UIElements.TogEspGl = Tabs.Vis:Toggle({
    Title = "Mostrar Resplandor",
    Value = true,
    Callback = function(s) espSettings.Glow = s end
})

local activeESPs = {}
local MAX_ESP_DISTANCE = 1500

local serverDeadCharacters = setmetatable({}, { __mode = "k" })

local function cleanESP(targetPlayer)
    if activeESPs[targetPlayer] then
        if activeESPs[targetPlayer].Highlight then activeESPs[targetPlayer].Highlight:Destroy() end
        activeESPs[targetPlayer] = nil
    end
end

local function WatchServerDeath(char)
    if not char then return end
    task.spawn(function()
        local hum = char:WaitForChild("Humanoid", 10)
        if not hum then return end

        if hum.Health <= 0 then
            serverDeadCharacters[char] = true
            local p = Players:GetPlayerFromCharacter(char)
            if p then cleanESP(p) end
            return
        end

        hum.Died:Connect(function()
            serverDeadCharacters[char] = true
            local p = Players:GetPlayerFromCharacter(char)
            if p then cleanESP(p) end
        end)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then
        if p.Character then WatchServerDeath(p.Character) end
        p.CharacterAdded:Connect(function(c) WatchServerDeath(c) end)
    end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= player then
        if p.Character then WatchServerDeath(p.Character) end
        p.CharacterAdded:Connect(function(c) WatchServerDeath(c) end)
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if espEnabled and IsInMatchStrict() then
            local myChar = player.Character
            local myHead = myChar and myChar:FindFirstChild("Head")
            local myPos = myHead and myHead.Position
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player then
                    local char = p.Character
                    local serverConfirmedDead = char and serverDeadCharacters[char] == true
                    if char and not serverConfirmedDead and char:FindFirstChild("Head") and isEnemy(p) then
                        local targetHead = char.Head
                        local dist = myPos and (targetHead.Position - myPos).Magnitude or 0
                        if dist <= MAX_ESP_DISTANCE then
                            if activeESPs[p] and activeESPs[p].Char ~= char then cleanESP(p) end
                            if not activeESPs[p] then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = p.Name .. "_Glow"
                                highlight.FillTransparency = 1
                                highlight.OutlineTransparency = 0
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Adornee = char
                                highlight.Parent = espFolder
                                activeESPs[p] = { Highlight = highlight, Char = char }
                            end
                            local espObj = activeESPs[p]
                            if espObj.Highlight.Enabled ~= espSettings.Glow then espObj.Highlight.Enabled = espSettings.Glow end
                            if espObj.Highlight.OutlineColor ~= espColor then espObj.Highlight.OutlineColor = espColor end
                        else
                            cleanESP(p)
                        end
                    else
                        cleanESP(p)
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do cleanESP(p) end
        end
    end
end)

local FOVCircle = nil
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVCircle.Radius = fovRadius
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = false
    FOVCircle.Thickness = 1
end

RunService.RenderStepped:Connect(function()
    if fovVisiblePreference and FOVCircle then
        FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        FOVCircle.Radius = fovRadius
        FOVCircle.Visible = true
        if silentAimFovEnabled and getgenv().NexvyrTargetPart then
            FOVCircle.Color = Color3.fromRGB(0, 255, 0)
        else
            FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        end
    elseif FOVCircle then
        FOVCircle.Visible = false
    end
end)

Players.PlayerRemoving:Connect(function(p)
    cleanESP(p)
end)

Tabs.Farm:Section({ Title = "Farmeo de Evento", Icon = "solar:gift-bold" })

getgenv().AutoEventFarm = false
local Networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
local RemoteFarm = Networking and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")

Tabs.Farm:Toggle({
    Title = "Auto Farmear Evento",
    Callback = function(s)
        getgenv().AutoEventFarm = s
        if s then
            task.spawn(function()
                while getgenv().AutoEventFarm do
                    pcall(function()
                        if RemoteFarm then RemoteFarm:FireServer()
                        else
                            Networking = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Networking")
                            RemoteFarm = Networking and Networking:FindFirstChild("RE/Events/CollectEventSpawnable")
                        end
                    end)
                    local char = player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local container = workspace:FindFirstChild("SpawnablesClient")
                        if container then
                            for _, obj in ipairs(container:GetChildren()) do
                                if not getgenv().AutoEventFarm then break end
                                local touchPart = obj:FindFirstChild("Touch")
                                if touchPart then
                                    pcall(function()
                                        firetouchinterest(hrp, touchPart, 0)
                                        firetouchinterest(hrp, touchPart, 1)
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

local animationData = {
    ["Old School"] = { Walk = 10921244891, Run = 10921240218, Jump = 10921242013, Fall = 10921241244, SwimIdle = 10921244018, Swim = 10921243048, Idle = 10921230744, Idle2 = 10921232093, Climb = 10921229866 },
    ["Adidas Sports"] = { Walk = 18537392113, Run = 18537384940, Jump = 18537380791, Fall = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Idle = 18537376492, Idle2 = 18537371272, Climb = 18537363391 },
    ["Adidas Community"] = { Walk = 122150855457006, Run = 82598234841035, Jump = 75290611992385, Fall = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266208, Idle = 122257458498464, Idle2 = 102357151005774, Climb = 88763136693023 },
    ["Adidas Aura"] = { Walk = 83842218823011, Run = 118320322718866, Jump = 109996626521204, Fall = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383903, Idle = 110211186840347, Idle2 = 114191137265065, Climb = 97824616490448 },
    ["Wicked Popular"] = { Walk = 92072849924640, Run = 72301599441680, Jump = 104325245285198, Fall = 121152442762481, Idle = 118832222982049, Idle2 = 76049494037641, SwimIdle = 113199415118199, Swim = 99384245425157, Climb = 131326830509784 },
    ["Elder"] = { Walk = 10921111375, Run = 10921104374, Jump = 10921107367, Fall = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, Idle = 10921101664, Idle2 = 10921102574, Climb = 10921100400 },
    ["Zombie"] = { Walk = 10921355261, Run = 616163682, Jump = 10921351278, Fall = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Idle = 10921344533, Idle2 = 10921345304, Climb = 10921343576 },
    ["Mage"] = { Walk = 10921152678, Run = 10921148209, Jump = 10921149743, Fall = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, Idle = 10921144709, Idle2 = 10921145797, Climb = 10921143404 },
    ["Catwalk Glam"] = { Walk = 109168724482748, Run = 81024476153754, Jump = 116936326516985, Fall = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181628, Idle = 133806214992291, Idle2 = 94970088341563, Climb = 119377220967554 },
    ["Astronaut"] = { Walk = 10921046031, Run = 10921039308, Jump = 10921042494, Fall = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, Idle = 10921034824, Idle2 = 10921036806, Climb = 10921032124 },
    ['Wicked "Dancing Through Life"'] = { Walk = 73718308412641, Run = 135515454877967, Jump = 78508480717326, Fall = 78147885297412, SwimIdle = 129183123083281, Swim = 110657013921774, Idle = 92849173543269, Idle2 = 132238900951109, Climb = 129447497744818 },
    ["Werewolf"] = { Walk = 10921342074, Run = 10921336997, Fall = 10921337907, SwimIdle = 10921341319, Swim = 10921340419, Idle = 10921330408, Idle2 = 10921333667, Climb = 10921329322 },
    ["Superhero"] = { Walk = 10921298616, Run = 10921291831, Jump = 10921294559, Fall = 10921293373, SwimIdle = 10921297391, Swim = 10921295495, Idle = 10921288909, Idle2 = 10921290167, Climb = 10921286911 },
    ["Toy"] = { Walk = 10921312010, Run = 10921306285, Jump = 10921308158, Fall = 10921307241, SwimIdle = 10921310341, Swim = 10921309319, Idle = 10921301576, Climb = 10921300839 },
    ["No Boundaries"] = { Walk = 18747074203, Run = 18747070484, Jump = 18747069148, Fall = 18747062535, SwimIdle = 18747071682, Swim = 18747073181, Idle = 18747067405, Idle2 = 18747063918, Climb = 18747060903 },
    ["NFL"] = { Walk = 110358958299415, Run = 117333533048078, Jump = 119846112151352, Fall = 129773241321032, SwimIdle = 79090109939093, Swim = 132697394189921, Idle = 92080889861410, Idle2 = 74451233229259, Climb = 134630013742019 },
    ["Amazon Unboxed"] = { Walk = 90478085024465, Run = 134824450619865, Jump = 121454505477205, Fall = 94788218468396, SwimIdle = 129126268464847, Swim = 105962919001086, Idle = 98281136301627, Climb = 121145883950231 },
    ["Vampire"] = { Walk = 10921326949, Run = 10921320299, Jump = 10921322186, Fall = 10921321317, SwimIdle = 10921325443, Swim = 10921324408, Idle = 10921315373, Climb = 10921314188 },
    ["Ninja"] = { Walk = 656121766, Run = 656118852, Jump = 656117878, Fall = 656115606, SwimIdle = 656121397, Swim = 656119721, Idle = 656117400, Idle2 = 656118341, Climb = 656114359 },
    ["Robot"] = { Walk = 616095330, Run = 616091570, Jump = 616090535, Fall = 616087089, SwimIdle = 616094091, Swim = 616092998, Idle = 616088211, Idle2 = 616089559, Climb = 616086039 },
    ["Levitation"] = { Walk = 616013216, Run = 616010382, Jump = 616008936, Fall = 616005863, SwimIdle = 616012453, Swim = 616011509, Idle = 616006778, Idle2 = 616008087, Climb = 616003713 },
    ["Stylish"] = { Walk = 616146177, Run = 616140816, Jump = 616139451, Fall = 616134815, SwimIdle = 616144772, Swim = 616143378, Idle = 616136790, Idle2 = 616138447, Climb = 616133594 },
    ["Bubbly"] = { Walk = 910034870, Run = 910025107, Jump = 910016857, Fall = 910001910, SwimIdle = 910030921, Swim = 910028158, Idle = 910004836, Idle2 = 910009958, Climb = 909997997 },
    ["Cartoon"] = { Walk = 742640026, Run = 742638842, Jump = 742637942, Fall = 742637151, SwimIdle = 742639812, Swim = 742639220, Idle = 742637544, Idle2 = 742638445, Climb = 742636889 }
}

local function clearAllAnimations()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop(0) track:Destroy() end
    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) track:Destroy() end
    end
    task.wait(0.1)
end

local function applyCustomAnims(customData)
    if not customData then return end
    local char = player.Character
    if not char then return end
    clearAllAnimations()
    local animate = char:FindFirstChild("Animate")
    if not animate then return end

    if not misAnimacionesOriginales then
        local function getAnim(folderName, animName)
            local folder = animate:FindFirstChild(folderName)
            if folder then
                local anim = folder:FindFirstChild(animName)
                if anim and anim:IsA("Animation") then
                    local idStr = anim.AnimationId:match("%d+")
                    if idStr then return tonumber(idStr) end
                end
            end
            return nil
        end
        misAnimacionesOriginales = {
            Idle = getAnim("idle", "Animation1") or 507766666,
            Idle2 = getAnim("idle", "Animation2") or 507766951,
            Walk = getAnim("walk", "WalkAnim") or 507777826,
            Run = getAnim("run", "RunAnim") or 507767714,
            Jump = getAnim("jump", "JumpAnim") or 507765000,
            Climb = getAnim("climb", "ClimbAnim") or 507765644,
            Fall = getAnim("fall", "FallAnim") or 507767968,
            Swim = getAnim("swim", "Swim") or 507784897,
            SwimIdle = getAnim("swimidle", "SwimIdle") or 507785072
        }
    end

    animate.Disabled = true
    task.wait(0.1)

    local function updateAnimation(folderName, animName, animId)
        if not animId then return end
        local folder = animate:FindFirstChild(folderName)
        if folder then
            local anim = folder:FindFirstChild(animName)
            if anim and anim:IsA("Animation") then
                anim.AnimationId = "rbxassetid://" .. tostring(animId)
            end
        end
    end

    updateAnimation("idle", "Animation1", customData.Idle)
    updateAnimation("idle", "Animation2", customData.Idle2 or customData.Idle)
    updateAnimation("walk", "WalkAnim", customData.Walk)
    updateAnimation("run", "RunAnim", customData.Run)
    updateAnimation("jump", "JumpAnim", customData.Jump)
    updateAnimation("climb", "ClimbAnim", customData.Climb)
    updateAnimation("fall", "FallAnim", customData.Fall)
    updateAnimation("swim", "Swim", customData.Swim)
    updateAnimation("swimidle", "SwimIdle", customData.SwimIdle or customData.Swim)

    task.wait(0.1)
    animate.Disabled = false

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Landed)
        task.wait(0.05)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

task.spawn(function()
    while task.wait(0.2) do
        local char = player.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then continue end
        if hum.Health <= 0 then continue end
        if hum.MoveDirection.Magnitude >= 0.1 then continue end

        local animate = char:FindFirstChild("Animate")
        if not animate then continue end

        local walkIds = {}
        local walkFolder = animate:FindFirstChild("walk")
        local runFolder = animate:FindFirstChild("run")
        if walkFolder then
            for _, anim in ipairs(walkFolder:GetChildren()) do
                if anim:IsA("Animation") then
                    table.insert(walkIds, anim.AnimationId)
                end
            end
        end
        if runFolder then
            for _, anim in ipairs(runFolder:GetChildren()) do
                if anim:IsA("Animation") then
                    table.insert(walkIds, anim.AnimationId)
                end
            end
        end

        if #walkIds == 0 then continue end

        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation and table.find(walkIds, track.Animation.AnimationId) then
                    track:Stop(0)
                end
            end
        end
    end
end)

player.CharacterAdded:Connect(function()
    if animacionActualActiva then
        task.spawn(function()
            task.wait(0.8)
            applyCustomAnims(animacionActualActiva)
        end)
    end
end)

local animList = {"Ninguno"}
for name, _ in pairs(animationData) do table.insert(animList, name) end
table.sort(animList)

Tabs.Animaciones:Section({Title = "Paquetes Completos", Icon = "solar:folder-with-files-bold"})

local selectedBundleCompleto = "Ninguno"
Tabs.Animaciones:Dropdown({ Title = "Elegir Paquete", Values = animList, Value = "Ninguno", Callback = function(Value) selectedBundleCompleto = Value end })

Tabs.Animaciones:Button({
    Title = "Aplicar Paquete Completo",
    Callback = function()
        if selectedBundleCompleto == "Ninguno" then return end
        task.spawn(function()
            animacionActualActiva = animationData[selectedBundleCompleto]
            applyCustomAnims(animacionActualActiva)
        end)
    end
})

Tabs.Animaciones:Button({
    Title = "Restaurar Default",
    Callback = function()
        task.spawn(function()
            local defaultAnims = misAnimacionesOriginales or {
                Idle = 507766666, Idle2 = 507766951, Walk = 507777826, Run = 507767714,
                Jump = 507765000, Climb = 507765644, Fall = 507767968, Swim = 507784897, SwimIdle = 507785072
            }
            animacionActualActiva = nil
            applyCustomAnims(defaultAnims)
        end)
    end
})

Tabs.Animaciones:Space()
Tabs.Animaciones:Divider()
Tabs.Animaciones:Space()
Tabs.Animaciones:Section({Title = "Mezclador de Animaciones", Icon = "solar:layers-bold"})

local mixParts = { Idle = "Ninguno", Walk = "Ninguno", Run = "Ninguno", Jump = "Ninguno", Fall = "Ninguno", Climb = "Ninguno", Swim = "Ninguno" }

Tabs.Animaciones:Dropdown({Title = "Reposo", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Idle = Value end})
Tabs.Animaciones:Dropdown({Title = "Caminar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Walk = Value end})
Tabs.Animaciones:Dropdown({Title = "Correr", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Run = Value end})
Tabs.Animaciones:Dropdown({Title = "Saltar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Jump = Value end})
Tabs.Animaciones:Dropdown({Title = "Caer", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Fall = Value end})
Tabs.Animaciones:Dropdown({Title = "Escalar", Values = animList, Value = "Ninguno", Callback = function(Value) mixParts.Climb = Value end})

Tabs.Animaciones:Button({
    Title = "Combinar y Aplicar",
    Callback = function()
        task.spawn(function()
            local customMix = {}
            if mixParts.Idle ~= "Ninguno" then
                customMix.Idle = animationData[mixParts.Idle].Idle
                customMix.Idle2 = animationData[mixParts.Idle].Idle2
            end
            if mixParts.Walk ~= "Ninguno" then customMix.Walk = animationData[mixParts.Walk].Walk end
            if mixParts.Run ~= "Ninguno" then customMix.Run = animationData[mixParts.Run].Run end
            if mixParts.Jump ~= "Ninguno" then customMix.Jump = animationData[mixParts.Jump].Jump end
            if mixParts.Fall ~= "Ninguno" then customMix.Fall = animationData[mixParts.Fall].Fall end
            if mixParts.Climb ~= "Ninguno" then customMix.Climb = animationData[mixParts.Climb].Climb end
            local hasValues = false
            for _, v in pairs(customMix) do if v then hasValues = true break end end
            if hasValues then
                animacionActualActiva = customMix
                applyCustomAnims(animacionActualActiva)
            end
        end)
    end
})

local KillSoundEnabled = false
local RecargaDisparoEnabled = false
local SelectedKillSound = "Onichaaan"
local KillSoundVolume = 1

local KillSounds = {
    { Name = "Onichaaan",       Id = "114361503583259" },
    { Name = "Omagaaa",         Id = "4496966777" },
    { Name = "korummm",         Id = "119896940405402" },
    { Name = "FAAAH XD",        Id = "92076037937225" },
    { Name = "Campana meme",    Id = "107378927201728" },
    { Name = "Enrique",         Id = "100688006999379" },
    { Name = "Magia de anime",  Id = "109296938403067" },
    { Name = "Risa anime",      Id = "93739527256723" },
    { Name = "Gemido",          Id = "94981264286350" },
    { Name = "Magic 2",         Id = "100507897550384" },
    { Name = "OwO",             Id = "71942674274967" },
    { Name = "SEMPAI >.<",      Id = "115498703521334" },
    { Name = "Ahhh:3",          Id = "83559496188823" },
    { Name = "ñyaa >//~//<",    Id = "78798011197804" },
}

local KillSoundPlayer = Instance.new("Sound")
KillSoundPlayer.Name = "NexvyrKillSound"
KillSoundPlayer.Volume = 1
KillSoundPlayer.Looped = false
KillSoundPlayer.Parent = SoundService

local ShootReloadOptions = {
    ["Revolver + Recarga"]     = { Shoot = "680140087",       Reload = "138084889" },
    ["Magia de Anime"]         = { Shoot = "109296938403067", Reload = nil },
    ["Láser + Recarga láser"]  = { Shoot = "4400449399",      Reload = "129456040607483" },
}
local SelectedShootReload = "Revolver + Recarga"

local SHOOT_SOUND_MAX_DURATION = 1.5
local shootSoundToken = 0
local lastShootSoundTime = 0
local SHOOT_SOUND_MIN_INTERVAL = 0.05

local ShootSoundPlayer = Instance.new("Sound")
ShootSoundPlayer.Name = "NexvyrShootSound"
ShootSoundPlayer.Volume = 1
ShootSoundPlayer.Looped = false
ShootSoundPlayer.Parent = SoundService

local ReloadSoundPlayer = Instance.new("Sound")
ReloadSoundPlayer.Name = "NexvyrReloadSound"
ReloadSoundPlayer.Volume = 1
ReloadSoundPlayer.Looped = false
ReloadSoundPlayer.Parent = SoundService

local function PlayShootSound()
    if not RecargaDisparoEnabled then return end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Shoot then return end
    local now = tick()
    if now - lastShootSoundTime < SHOOT_SOUND_MIN_INTERVAL then return end
    lastShootSoundTime = now
    shootSoundToken = shootSoundToken + 1
    local myToken = shootSoundToken
    ShootSoundPlayer:Stop()
    ShootSoundPlayer.SoundId = "rbxassetid://" .. cfg.Shoot
    ShootSoundPlayer.Volume = KillSoundVolume
    ShootSoundPlayer:Play()
    task.delay(SHOOT_SOUND_MAX_DURATION, function()
        if shootSoundToken == myToken and ShootSoundPlayer.Playing then
            ShootSoundPlayer:Stop()
        end
    end)
end

local function PlayReloadSound()
    if not RecargaDisparoEnabled then return end
    local cfg = ShootReloadOptions[SelectedShootReload]
    if not cfg or not cfg.Reload then return end
    ReloadSoundPlayer:Stop()
    ReloadSoundPlayer.SoundId = "rbxassetid://" .. cfg.Reload
    ReloadSoundPlayer.Volume = KillSoundVolume
    ReloadSoundPlayer:Play()
end

local FIRE_SOUND_KEYWORDS = {
    "fire","shoot","shot","gun","burst","shotgun","gunshot","muzzle","rifle","pistol","shooting","firing"
}

local function isFireSound(s)
    if not s:IsA("Sound") then return false end
    local n = string.lower(s.Name)
    for _, kw in ipairs(FIRE_SOUND_KEYWORDS) do
        if string.find(n, kw, 1, true) then return true end
    end
    return false
end

local function HookFireSound(s)
    if not s:IsA("Sound") then return end
    if not isFireSound(s) then return end
    if s:GetAttribute("NexvyrFireHooked") then return end
    s:SetAttribute("NexvyrFireHooked", true)
    s.Played:Connect(function()
        if not RecargaDisparoEnabled then return end
        local char = player.Character
        if not char then return end
        if s:IsDescendantOf(char) or s:IsDescendantOf(player:FindFirstChildOfClass("Backpack") or char) then
            PlayShootSound()
        end
    end)
end

local function HookShootOnTool(tool)
    if not tool or not tool:IsA("Tool") then return end
    for _, d in ipairs(tool:GetDescendants()) do HookFireSound(d) end
    if not tool:GetAttribute("NexvyrToolHooked") then
        tool:SetAttribute("NexvyrToolHooked", true)
        tool.DescendantAdded:Connect(HookFireSound)
    end
end

local function HookShootOnRoot(root)
    if not root then return end
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("Tool") then HookShootOnTool(child) end
    end
    root.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then HookShootOnTool(child) end
    end)
end

task.spawn(function()
    local lastReloadState = false
    while task.wait(0.05) do
        if not RecargaDisparoEnabled then lastReloadState = false continue end
        local char = player.Character
        if not char then lastReloadState = false continue end
        local arma = char:FindFirstChildOfClass("Tool")
        if not arma or esCuchillo(arma) then lastReloadState = false continue end
        local recargando = estaRecargando(arma)
        if recargando and not lastReloadState then PlayReloadSound() end
        lastReloadState = recargando
    end
end)

local function GetKillSoundIdByName(soundName)
    for _, s in ipairs(KillSounds) do
        if s.Name == soundName then return s.Id end
    end
    return KillSounds[1].Id
end

local function PlayKillSound()
    if not KillSoundEnabled then return end
    KillSoundPlayer:Stop()
    KillSoundPlayer.SoundId = "rbxassetid://" .. GetKillSoundIdByName(SelectedKillSound)
    KillSoundPlayer.Volume = KillSoundVolume
    KillSoundPlayer:Play()
end

local lastKillSoundTime = 0
local KILL_SOUND_COOLDOWN = 0.08
local function TryPlayKillSound()
    if not KillSoundEnabled then return end
    local now = tick()
    if now - lastKillSoundTime < KILL_SOUND_COOLDOWN then return end
    lastKillSoundTime = now
    PlayKillSound()
end

local KILL_STAT_NAMES = { kos = true, kills = true, kill = true, ko = true, killed = true, eliminations = true, kills_count = true }

local function HookStatValue(stat)
    if not stat then return end
    if not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then return end
    if not KILL_STAT_NAMES[string.lower(stat.Name)] then return end
    if stat:GetAttribute("NexvyrKOHooked") then return end
    stat:SetAttribute("NexvyrKOHooked", true)
    local lastVal = stat.Value
    stat:GetPropertyChangedSignal("Value"):Connect(function()
        if stat.Value > lastVal then TryPlayKillSound() end
        lastVal = stat.Value
    end)
end

local function HookLeaderstatsContainer(container)
    if not container then return end
    for _, stat in ipairs(container:GetChildren()) do HookStatValue(stat) end
    container.ChildAdded:Connect(HookStatValue)
end

local KILL_ATTR_NAMES = {"KOs","Kills","kos","kills","KO","killed","Eliminations"}
for _, attrName in ipairs(KILL_ATTR_NAMES) do
    local lastVal = tonumber(player:GetAttribute(attrName))
    player:GetAttributeChangedSignal(attrName):Connect(function()
        local newVal = tonumber(player:GetAttribute(attrName))
        if newVal ~= nil and lastVal ~= nil and newVal > lastVal then TryPlayKillSound() end
        lastVal = newVal
    end)
end

if player:FindFirstChild("leaderstats") then HookLeaderstatsContainer(player:FindFirstChild("leaderstats")) end
for _, containerName in ipairs({"Stats","stats","PlayerStats"}) do
    local cont = player:FindFirstChild(containerName)
    if cont then HookLeaderstatsContainer(cont) end
end
player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" then HookLeaderstatsContainer(child) end
    for _, containerName in ipairs({"Stats","stats","PlayerStats"}) do
        if child.Name == containerName then HookLeaderstatsContainer(child) end
    end
end)

local function HookKillOnCharacter(targetPlayer, character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    humanoid.Died:Connect(function()
        if not KillSoundEnabled then return end
        local tag = humanoid:FindFirstChild("creator")
        if tag and tag.Value == player then TryPlayKillSound() end
    end)
end

local function HookKillPlayer(targetPlayer)
    if targetPlayer == player then return end
    if targetPlayer.Character then task.spawn(HookKillOnCharacter, targetPlayer, targetPlayer.Character) end
    targetPlayer.CharacterAdded:Connect(function(c) HookKillOnCharacter(targetPlayer, c) end)
end

for _, p in ipairs(Players:GetPlayers()) do HookKillPlayer(p) end
Players.PlayerAdded:Connect(HookKillPlayer)

local OriginalGunVolumes = {}
local HookedGunSounds = setmetatable({}, { __mode = "k" })

local function MuteOwnSound(s)
    if not s:IsA("Sound") then return end
    if s.Name == "NexvyrKillSound" or s.Name == "WindUI_MusicPlayer" or s.Name == "NexvyrShootSound" or s.Name == "NexvyrReloadSound" then return end
    if OriginalGunVolumes[s] == nil and s.Volume > 0 then OriginalGunVolumes[s] = s.Volume end
    if RecargaDisparoEnabled then s.Volume = 0 end
    if not HookedGunSounds[s] then
        HookedGunSounds[s] = true
        s:GetPropertyChangedSignal("Volume"):Connect(function()
            if RecargaDisparoEnabled and s.Volume ~= 0 then
                OriginalGunVolumes[s] = s.Volume
                s.Volume = 0
            end
        end)
        s.Played:Connect(function()
            if RecargaDisparoEnabled then s.Volume = 0 end
        end)
    end
end

local function HookOwnRoot(root)
    if not root then return end
    for _, d in ipairs(root:GetDescendants()) do MuteOwnSound(d) end
    root.DescendantAdded:Connect(MuteOwnSound)
end

local function ApplyMuteState(state)
    if state then
        for s in pairs(OriginalGunVolumes) do
            if s.Parent then s.Volume = 0 end
        end
        if player.Character then
            for _, d in ipairs(player.Character:GetDescendants()) do MuteOwnSound(d) end
        end
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, d in ipairs(backpack:GetDescendants()) do MuteOwnSound(d) end
        end
    else
        for s, v in pairs(OriginalGunVolumes) do
            if s.Parent then s.Volume = v end
        end
    end
end

if player.Character then
    HookOwnRoot(player.Character)
    HookShootOnRoot(player.Character)
end
if player:FindFirstChildOfClass("Backpack") then
    HookOwnRoot(player:FindFirstChildOfClass("Backpack"))
    HookShootOnRoot(player:FindFirstChildOfClass("Backpack"))
end
player.CharacterAdded:Connect(function(c)
    HookOwnRoot(c)
    HookShootOnRoot(c)
    local bp = player:WaitForChild("Backpack", 5)
    if bp then
        HookOwnRoot(bp)
        HookShootOnRoot(bp)
    end
    task.wait(2)
    if RecargaDisparoEnabled then ApplyMuteState(true) end
end)

Tabs.Sonidos:Section({ Title = "Sonido de Muerte", Icon = "solar:speaker-bold" })

Tabs.Sonidos:Toggle({
    Title = "Sonido de Kill",
    Value = false,
    Callback = function(v)
        KillSoundEnabled = v
        if not v then KillSoundPlayer:Stop() end
    end
})

local KillSoundDropdownValues = {}
for _, s in ipairs(KillSounds) do table.insert(KillSoundDropdownValues, s.Name) end

Tabs.Sonidos:Dropdown({
    Title = "Sonido de muerte",
    Values = KillSoundDropdownValues,
    Value = "Onichaaan",
    Callback = function(selected) SelectedKillSound = selected end
})

Tabs.Sonidos:Section({ Title = "Disparo y Recarga", Icon = "solar:target-bold" })

Tabs.Sonidos:Toggle({
    Title = "Recarga + disparo",
    Value = false,
    Callback = function(v)
        RecargaDisparoEnabled = v
        if not v then
            ShootSoundPlayer:Stop()
            ReloadSoundPlayer:Stop()
        end
        ApplyMuteState(v)
    end
})

Tabs.Sonidos:Dropdown({
    Title = "Sonido de disparo",
    Values = { "Revolver + Recarga", "Magia de Anime", "Láser + Recarga láser" },
    Value = "Revolver + Recarga",
    Callback = function(selected) SelectedShootReload = selected end
})

Tabs.Sonidos:Slider({
    Title = "Volumen",
    Step = 0.1,
    Value = { Min = 1, Max = 3, Default = 1 },
    Callback = function(v)
        KillSoundVolume = v
        KillSoundPlayer.Volume = v
        ShootSoundPlayer.Volume = v
        ReloadSoundPlayer.Volume = v
    end
})

local MusicPlayer = Instance.new("Sound")
MusicPlayer.Name = "WindUI_MusicPlayer"
MusicPlayer.Looped = false
MusicPlayer.Volume = 0.5
MusicPlayer.Parent = SoundService

local SongList = {
    { Name = "Canción 1", Id = "84944985070181" },
    { Name = "Canción 2", Id = "87570666848900" },
    { Name = "Canción 3", Id = "82746224492420" },
    { Name = "Canción 4", Id = "71393805905055" },
    { Name = "Canción 5", Id = "75688616622595" },
    { Name = "Canción 6", Id = "135609653444873" },
    { Name = "Canción 7", Id = "93699644879957" },
    { Name = "Canción 8", Id = "110398343528156" },
    { Name = "Canción 9", Id = "138863509657081" },
    { Name = "Canción 10", Id = "115440201770223" },
    { Name = "Canción 11", Id = "128048502331483" },
    { Name = "Canción 12", Id = "135321902579514" },
    { Name = "Canción 13", Id = "131465489873214" },
}

local CurrentIndex = 1
local ShuffleOn = false
local NowPlayingParagraph

local function OptionLabel(song) return song.Name .. " (" .. song.Id .. ")" end

local function UpdateNowPlaying()
    local song = SongList[CurrentIndex]
    if song and NowPlayingParagraph then
        NowPlayingParagraph:SetDesc(("%s • ID: %s • %s"):format(song.Name, song.Id, MusicPlayer.Playing and "Reproduciendo" or "Pausado"))
    end
end

local function LoadSong(index)
    if not SongList[index] then return end
    CurrentIndex = index
    MusicPlayer:Stop()
    MusicPlayer.SoundId = "rbxassetid://" .. SongList[index].Id
    MusicPlayer:Play()
    UpdateNowPlaying()
end

local function PlaySong()
    if MusicPlayer.SoundId == "" then LoadSong(CurrentIndex)
    elseif not MusicPlayer.Playing then MusicPlayer:Resume() end
    UpdateNowPlaying()
end

local function PauseSong()
    if MusicPlayer.Playing then MusicPlayer:Pause() end
    UpdateNowPlaying()
end

local function StopSong()
    MusicPlayer:Stop()
    MusicPlayer.SoundId = ""
    UpdateNowPlaying()
end

local function NextSong()
    local nextIndex
    if ShuffleOn then nextIndex = math.random(1, #SongList)
    else
        nextIndex = CurrentIndex + 1
        if nextIndex > #SongList then nextIndex = 1 end
    end
    LoadSong(nextIndex)
end

local function PrevSong()
    local prevIndex
    if ShuffleOn then prevIndex = math.random(1, #SongList)
    else
        prevIndex = CurrentIndex - 1
        if prevIndex < 1 then prevIndex = #SongList end
    end
    LoadSong(prevIndex)
end

MusicPlayer.Ended:Connect(function() NextSong() end)

Tabs.Music:Section({ Title = "Ahora suena", Icon = "solar:music-note-bold" })
NowPlayingParagraph = Tabs.Music:Paragraph({ Title = "Sin canción seleccionada", Desc = "Presiona Reproducir para comenzar", Icon = "solar:music-note-2-bold" })

Tabs.Music:Section({ Title = "Controles", Icon = "solar:tuning-2-bold" })
Tabs.Music:Button({ Title = "Anterior", Desc = "Retrocede a la canción previa", Icon = "solar:skip-previous-bold", Variant = "Secondary", Callback = function() PrevSong() end })
Tabs.Music:Button({ Title = "Siguiente", Desc = "Avanza a la siguiente canción", Icon = "solar:skip-next-bold", Variant = "Secondary", Callback = function() NextSong() end })
Tabs.Music:Button({ Title = "Reproducir", Desc = "Inicia o reanuda la canción actual", Icon = "solar:play-circle-bold", Variant = "Primary", Callback = function() PlaySong() end })
Tabs.Music:Button({ Title = "Pausar", Desc = "Pausa la reproducción sin perder el avance", Icon = "solar:pause-circle-bold", Variant = "Secondary", Callback = function() PauseSong() end })
Tabs.Music:Button({ Title = "Detener", Desc = "Corta la música por completo", Icon = "solar:close-circle-bold", Variant = "Danger", Callback = function() StopSong() end })

Tabs.Music:Section({ Title = "Seleccionar música", Icon = "solar:playlist-bold" })
local SongDropdown
SongDropdown = Tabs.Music:Dropdown({
    Title = "Canción",
    Desc = "Elige una canción de la lista para reproducirla",
    Icon = "solar:music-note-bold",
    Values = (function()
        local options = {}
        for _, song in ipairs(SongList) do table.insert(options, OptionLabel(song)) end
        return options
    end)(),
    Callback = function(selected)
        for i, song in ipairs(SongList) do
            if selected == OptionLabel(song) then LoadSong(i); break end
        end
    end,
})

Tabs.Music:Section({ Title = "Preferencias de reproducción", Icon = "solar:settings-bold" })
Tabs.Music:Toggle({ Title = "Reproducción aleatoria", Desc = "Elige una canción al azar cada vez que avanza", Value = false, Callback = function(state) ShuffleOn = state end })
Tabs.Music:Toggle({ Title = "Repetir canción", Desc = "Vuelve a reproducir la misma canción al terminar", Value = false, Callback = function(state) MusicPlayer.Looped = state end })
Tabs.Music:Slider({ Title = "Volumen", Desc = "Ajusta qué tan fuerte suena la música", Icon = "solar:volume-loud-bold", Value = { Min = 0, Max = 100, Default = 50 }, Callback = function(value) MusicPlayer.Volume = value / 100 end })

Tabs.Music:Section({ Title = "IDs de música", Icon = "solar:playlist-bold" })
local NewName, NewId = "", ""
Tabs.Music:Input({ Title = "Nombre de la canción", Icon = "solar:text-field-bold", Placeholder = "Ej: Mi canción", Callback = function(value) NewName = value end })
Tabs.Music:Input({ Title = "ID de Roblox (rbxassetid)", Icon = "solar:hashtag-bold", Placeholder = "Ej: 1234567890", Callback = function(value) NewId = value end })

local function RefreshDropdownOptions()
    local options = {}
    for _, song in ipairs(SongList) do table.insert(options, OptionLabel(song)) end
    if SongDropdown and SongDropdown.Refresh then SongDropdown:Refresh(options) end
end

Tabs.Music:Button({
    Title = "Añadir canción",
    Desc = "Guarda el nombre e ID escritos arriba en la lista",
    Icon = "solar:add-circle-bold",
    Variant = "Primary",
    Callback = function()
        if NewName ~= "" and NewId ~= "" then
            for _, song in ipairs(SongList) do if song.Id == NewId then return end end
            table.insert(SongList, { Name = NewName, Id = NewId })
            RefreshDropdownOptions()
        end
    end,
})

local Backgrounds = {
    { Name = "Fondo 1", ID = "12687580616", Reference = "rbxthumb://type=Asset&id=12687580616&w=420&h=420" },
    { Name = "Fondo 2", ID = "17104722", Reference = "rbxthumb://type=Asset&id=17104722&w=420&h=420" },
    { Name = "Fondo 3", ID = "1941010929", Reference = "rbxthumb://type=Asset&id=1941010929&w=420&h=420" },
    { Name = "Fondo 4", ID = "134245569", Reference = "rbxthumb://type=Asset&id=134245569&w=420&h=420" },
    { Name = "Fondo 5", ID = "14653905878", Reference = "rbxthumb://type=Asset&id=14653905878&w=420&h=420" },
    { Name = "Fondo 6", ID = "14397445471", Reference = "rbxthumb://type=Asset&id=14397445471&w=420&h=420" }
}

local SelectedFondo = Backgrounds[1]
local SelectedTheme = "Dark"
local FondoNames = {}
for _, fondo in ipairs(Backgrounds) do table.insert(FondoNames, fondo.Name) end

Tabs.Fondos:Dropdown({
    Title = "Seleccionar fondo",
    Values = FondoNames,
    Value = SelectedFondo.Name,
    Callback = function(Value)
        for _, fondo in ipairs(Backgrounds) do
            if fondo.Name == Value then SelectedFondo = fondo; break end
        end
    end
})

local function FindBackground()
    local possibleRoots = { game:GetService("CoreGui"), game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui") }
    for _, root in ipairs(possibleRoots) do
        if root then
            for _, obj in ipairs(root:GetDescendants()) do
                if obj:IsA("ImageLabel") then
                    local image = obj.Image
                    if image and (image:find("12687580616") or image:find("17104722") or image:find("1941010929") or image:find("134245569") or image:find("14653905878") or image:find("14397445471")) then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function FixBackgroundLayer(Background)
    Background.ZIndex = 0
    Background.Active = false
    local Parent = Background.Parent
    if Parent then
        for _, obj in ipairs(Parent:GetDescendants()) do
            if obj:IsA("GuiObject") and obj ~= Background then
                if obj.ZIndex <= Background.ZIndex then obj.ZIndex = Background.ZIndex + 1 end
            end
        end
    end
end

local function ApplySelectedBackground()
    local Background = FindBackground()
    if Background then
        Background.Image = SelectedFondo.Reference
        FixBackgroundLayer(Background)
        return true
    end
    return false
end

Tabs.Fondos:Button({
    Title = "Aplicar",
    Callback = function()
        if not ApplySelectedBackground() then
            warn("No se encontró el fondo de WindUI.")
        end
    end
})

Tabs.Fondos:Section({ Title = "Tema de la Interfaz", Icon = "solar:palette-bold" })

Tabs.Fondos:Dropdown({
    Title = "Seleccionar Tema",
    Desc = "Cambia el tema de color de la WindUI",
    Icon = "solar:palette-bold",
    Values = { "Midnight", "Dark", "Red", "Indigo" },
    Value = "Dark",
    Callback = function(Value)
        SelectedTheme = Value
        pcall(function() WindUI:SetTheme(Value) end)
    end
})

local EmoteList = {
    { Name = "Wave", Id = "507770239", Loop = false },
    { Name = "Point", Id = "507770453", Loop = false },
    { Name = "Cheer", Id = "507770677", Loop = false },
    { Name = "Laugh", Id = "507770818", Loop = false },
    { Name = "Dance 1", Id = "507771019", Loop = true },
    { Name = "Dance 1 (B)", Id = "507771955", Loop = true },
    { Name = "Dance 1 (C)", Id = "507772104", Loop = true },
    { Name = "Dance 2", Id = "507776043", Loop = true },
    { Name = "Dance 2 (B)", Id = "507776720", Loop = true },
    { Name = "Dance 2 (C)", Id = "507776879", Loop = true },
    { Name = "Dance 3", Id = "507777268", Loop = true },
    { Name = "Dance 3 (B)", Id = "507777451", Loop = true },
    { Name = "Dance 3 (C)", Id = "507777623", Loop = true },
    { Name = "Hype Dance", Id = "3695333486", Loop = true },
    { Name = "Monkey", Id = "3333499508", Loop = true },
    { Name = "Around Town", Id = "3303391864", Loop = true },
    { Name = "Dorky", Id = "4212455378", Loop = true },
    { Name = "Line Dance", Id = "4049037604", Loop = true },
    { Name = "Side to Side", Id = "3333136415", Loop = true },
    { Name = "Baby Dance", Id = "4265725525", Loop = true },
    { Name = "Robot Dance", Id = "3338025566", Loop = true },
    { Name = "Celebrate", Id = "3994127840", Loop = true },
}

local HighestPriority = (Enum.AnimationPriority.Action4 and Enum.AnimationPriority.Action4) or Enum.AnimationPriority.Action
local CurrentEmoteTrack
local SelectedEmoteId
local SelectedEmoteLoop = true
local MovementConnections = {}

local function StopEmote()
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track.Animation and track.Animation.AnimationId ~= "" then track:Stop(0) end
        end
    end
    CurrentEmoteTrack = nil
end

local function ClearMovementConnections()
    for _, conn in ipairs(MovementConnections) do conn:Disconnect() end
    MovementConnections = {}
end

local function BindMovementDetection(humanoid)
    ClearMovementConnections()
    table.insert(MovementConnections, humanoid.Running:Connect(function(speed)
        if speed > 0.1 and CurrentEmoteTrack then StopEmote() end
    end))
    table.insert(MovementConnections, humanoid.Jumping:Connect(function()
        if CurrentEmoteTrack then StopEmote() end
    end))
    table.insert(MovementConnections, humanoid.StateChanged:Connect(function(_, newState)
        if not CurrentEmoteTrack then return end
        if newState == Enum.HumanoidStateType.Freefall or newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Swimming or newState == Enum.HumanoidStateType.Climbing then
            StopEmote()
        end
    end))
end

local function GetHumanoid()
    local character = player.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

local function OnCharacterAdded(character)
    CurrentEmoteTrack = nil
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then BindMovementDetection(humanoid) end
end

if player.Character then OnCharacterAdded(player.Character) end
player.CharacterAdded:Connect(OnCharacterAdded)

local function PlayEmote(id, loop)
    local humanoid = GetHumanoid()
    if not humanoid then return end
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then return end
    StopEmote()
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then animator = Instance.new("Animator"); animator.Parent = humanoid end
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. id
    local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
    if ok and track then
        track.Priority = HighestPriority
        track.Looped = loop
        CurrentEmoteTrack = track
        track:Play(0, 1, 1)
    end
end

local function EmoteLabel(emote) return emote.Name .. " (" .. emote.Id .. ")" end

Tabs.Emotes:Section({ Title = "Emotes disponibles", Icon = "solar:emoji-funny-circle-bold" })

local EmoteDropdown
EmoteDropdown = Tabs.Emotes:Dropdown({
    Title = "Emote",
    Desc = "Elige un emote para tu personaje (requiere avatar R15)",
    Icon = "solar:playlist-bold",
    Values = (function()
        local options = {}
        for _, emote in ipairs(EmoteList) do table.insert(options, EmoteLabel(emote)) end
        return options
    end)(),
    Callback = function(selected)
        for _, emote in ipairs(EmoteList) do
            if selected == EmoteLabel(emote) then
                SelectedEmoteId = emote.Id
                SelectedEmoteLoop = emote.Loop
                break
            end
        end
    end,
})

Tabs.Emotes:Section({ Title = "Controles", Icon = "solar:tuning-2-bold" })

Tabs.Emotes:Button({ Title = "Reproducir emote", Desc = "Reproduce el emote seleccionado en tu personaje", Icon = "solar:play-circle-bold", Variant = "Primary", Callback = function()
    if SelectedEmoteId then PlayEmote(SelectedEmoteId, SelectedEmoteLoop) end
end })
Tabs.Emotes:Button({ Title = "Detener emote", Desc = "Detiene el emote actual", Icon = "solar:close-circle-bold", Variant = "Danger", Callback = function() StopEmote() end })

Tabs.Emotes:Section({ Title = "IDs de emotes", Icon = "solar:playlist-bold" })
local NewEmoteName, NewEmoteId = "", ""
local NewEmoteLoop = true
Tabs.Emotes:Input({ Title = "Nombre del emote", Icon = "solar:text-field-bold", Placeholder = "Ej: Mi emote", Callback = function(value) NewEmoteName = value end })
Tabs.Emotes:Input({ Title = "ID de Roblox (rbxassetid)", Icon = "solar:hashtag-bold", Placeholder = "Ej: 1234567890", Callback = function(value) NewEmoteId = value end })
Tabs.Emotes:Toggle({ Title = "Repetir en bucle", Desc = "Actívalo solo si el emote es un baile hecho para loopearse", Value = true, Callback = function(state) NewEmoteLoop = state end })

local function RefreshEmoteDropdown()
    local options = {}
    for _, emote in ipairs(EmoteList) do table.insert(options, EmoteLabel(emote)) end
    if EmoteDropdown and EmoteDropdown.Refresh then EmoteDropdown:Refresh(options) end
end

Tabs.Emotes:Button({
    Title = "Añadir emote",
    Desc = "Guarda el nombre, ID y loop en la lista",
    Icon = "solar:add-circle-bold",
    Variant = "Primary",
    Callback = function()
        if NewEmoteName ~= "" and NewEmoteId ~= "" then
            for _, emote in ipairs(EmoteList) do if emote.Id == NewEmoteId then return end end
            table.insert(EmoteList, { Name = NewEmoteName, Id = NewEmoteId, Loop = NewEmoteLoop })
            RefreshEmoteDropdown()
        end
    end,
})

local KORBLOX_ASSETS = {
    ["Left Leg"] = {
        id = "rbxassetid://139607673", targetBodyPart = "LeftUpperLeg",
        partsToHide = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"},
        scale = Vector3.new(1.0, 1.0, 1.0), audio = "rbxassetid://87998522263554",
        offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
    },
    ["Right Leg"] = {
        id = "rbxassetid://139607718", targetBodyPart = "RightUpperLeg",
        partsToHide = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
        scale = Vector3.new(1.0, 1.0, 1.0), audio = "rbxassetid://135315310485417",
        offset = CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, 0),
    }
}

local KorbloxEnabled = false
local korbloxSavedTransparency = {}

local function attachKorbloxMesh(itemName, config)
    local character = player.Character
    if not character then return false end
    local targetPart = character:WaitForChild(config.targetBodyPart, 2)
    if not targetPart then return false end

    local oldAsset = character:FindFirstChild("Korblox_" .. itemName:gsub("%s+", ""))
    if oldAsset then oldAsset:Destroy() end

    for _, partName in ipairs(config.partsToHide) do
        local limb = character:FindFirstChild(partName)
        if limb and limb:IsA("BasePart") then
            if korbloxSavedTransparency[partName] == nil then
                korbloxSavedTransparency[partName] = limb.Transparency
            end
            limb.Transparency = 1
        end
    end

    local success, objects = pcall(function() return game:GetObjects(config.id) end)
    if not success or not objects or #objects == 0 then return false end
    local assetModel = objects[1]
    assetModel.Name = "Korblox_" .. itemName:gsub("%s+", "")
    local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
    if not mainMesh then return false end
    mainMesh.Size = mainMesh.Size * config.scale
    mainMesh.CanCollide = false
    mainMesh.CFrame = targetPart.CFrame * config.offset
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = targetPart
    weld.Part1 = mainMesh
    weld.Parent = mainMesh
    assetModel.Parent = character

    if config.audio then
        local sound = Instance.new("Sound")
        sound.SoundId = config.audio
        sound.Volume = 0.5
        sound.Parent = mainMesh
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end
    return true
end

local function applyKorblox()
    if not KorbloxEnabled then return end
    local config = KORBLOX_ASSETS["Right Leg"]
    local ok = attachKorbloxMesh("Right Leg", config)
    if not ok then
        task.wait(0.2)
        attachKorbloxMesh("Right Leg", config)
    end
end

local function removeKorblox()
    local character = player.Character
    if not character then return end
    local assetName = "Korblox_RightLeg"
    local asset = character:FindFirstChild(assetName)
    if asset then pcall(function() asset:Destroy() end) end
    for partName, orig in pairs(korbloxSavedTransparency) do
        local limb = character:FindFirstChild(partName)
        if limb and limb:IsA("BasePart") then pcall(function() limb.Transparency = orig end) end
    end
    korbloxSavedTransparency = {}
end

local HEADLESS_ASSET_ID = 134082579
local HeadlessEnabled = false
local insertedHeadlessAccessory = nil

local function setHeadlessTransparency(enabled)
    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if head then
        head.Transparency = enabled and 1 or 0
        local faceDecal = head:FindFirstChildOfClass("Decal")
        if faceDecal then
            faceDecal.Transparency = enabled and 1 or 0
        end
    end
end

local function setHeadless(enabled)
    local character = player.Character
    if not character then return end

    if enabled then
        character:WaitForChild("Head", 2)
        setHeadlessTransparency(true)

        if insertedHeadlessAccessory and insertedHeadlessAccessory.Parent ~= character then
            insertedHeadlessAccessory = nil
        end
        if insertedHeadlessAccessory then return end

        local success, result = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(HEADLESS_ASSET_ID))
        end)

        if success and result and #result > 0 then
            local rootModel = result[1]
            local model = nil
            if rootModel:IsA("Accessory") then
                model = rootModel
            else
                for _, descendant in ipairs(rootModel:GetDescendants()) do
                    if descendant:IsA("Accessory") then
                        model = descendant
                        break
                    end
                end
                model = model or (rootModel:IsA("Model") and rootModel or nil)
            end

            if model then
                if model:IsA("Accessory") then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local addSuccess = humanoid and pcall(function()
                        humanoid:AddAccessory(model)
                    end)
                    if not addSuccess then
                        model.Parent = character
                    end
                else
                    model.Parent = character
                end
                insertedHeadlessAccessory = model
            end
        else
            warn("[Headless] Failed to load headless asset: " .. tostring(result))
        end
    else
        setHeadlessTransparency(false)
        if insertedHeadlessAccessory then
            insertedHeadlessAccessory:Destroy()
            insertedHeadlessAccessory = nil
        end
    end
end

player.CharacterAdded:Connect(function(character)
    korbloxSavedTransparency = {}
    insertedHeadlessAccessory = nil

    if KorbloxEnabled then
        task.spawn(function()
            task.wait(0.1)
            applyKorblox()
        end)
    end
    if HeadlessEnabled then
        task.spawn(function()
            task.wait(0.1)
            setHeadless(true)
        end)
    end
end)

Tabs.Items:Section({ Title = "Items", Icon = "solar:crown-star-bold" })

Tabs.Items:Toggle({
    Title = "Aplicar Headless",
    Desc = "Headless visual",
    Value = false,
    Callback = function(v)
        HeadlessEnabled = v
        if v then
            setHeadless(true)
        else
            setHeadless(false)
        end
    end
})

Tabs.Items:Toggle({
    Title = "Aplicar Korblox",
    Desc = "Korblox visual",
    Value = false,
    Callback = function(v)
        KorbloxEnabled = v
        if v then applyKorblox() else removeKorblox() end
    end
})

Tabs.Com:Section({ Title = "Comunidad", Icon = "solar:chat-line-bold" })

Tabs.Com:Paragraph({
    Title = "Únete a los grupos para no perderte las novedades de Open HUB.",
    Desc = "",
})

Tabs.Com:Paragraph({
    Title = "Únete al servidor de Discord",
    Desc = "Haz clic en el botón de abajo para copiar el link de invitación de Discord.",
    Thumbnail = "rbxthumb://type=Asset&id=134340713001451&w=420&h=420",
    ThumbnailSize = 128,
    Buttons = {
        {
            Title = "Copiar invitación de Discord",
            Callback = function()
                pcall(function()
                    if setclipboard then
                        local _ds = "https://disc" .. "ord.gg/BpqrRVkhA"
                        setclipboard(_ds)
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "Link Copiado!",
                            Text = "Abre WhatsApp y pega el enlace para unirte al grupo.",
                            Duration = 4
                        })
                    end
                end)
            end,
        },
    },
})

Tabs.Avisos:Section({ Title = "Aviso", Icon = "solar:shield-warning-bold" })
Tabs.Avisos:Paragraph({ Title = "El kill all sigue en fase beta, no es recomendable en sv público.", Desc = "" })
Tabs.Avisos:Paragraph({ Title = "El equipo de nexvyr no se hace responsable si resultas baneado del juego, úsalo bajo tu propia responsabilidad.", Desc = "" })

Tabs.Avisos:Section({ Title = "Teclas", Icon = "solar:keyboard-bold" })

Tabs.Avisos:Keybind({
    Title = "Tecla para abrir UI",
    Value = Keybinds.ToggleUI,
    Callback = function(k)
        Keybinds.ToggleUI = k
        pcall(function() Window:SetToggleKey(Enum.KeyCode[k]) end)
    end
})

Tabs.Avisos:Button({
    Title = "Resetear Tecla UI",
    Desc = "Restablece esta tecla a su valor predeterminado.",
    Callback = function()
        Keybinds.ToggleUI = "RightControl"
        pcall(function() Window:SetToggleKey(Enum.KeyCode.RightControl) end)
    end
})

local ownersPara = nil
local notesPara = nil

Tabs.Owners:Section({ Title = "CREADOR OFICIAL", Icon = "solar:crown-bold" })

ownersPara = Tabs.Owners:Paragraph({
    Title = "<b>NEXVYR</b>",
    Desc = "<font color='#FFD700'><b>[FOUNDER]</b></font> <b>7.dui</b>\nFundador y creador del proyecto Open HUB",
    Image = "rbxthumb://type=Asset&id=14653905878&w=420&h=420",
    ImageSize = 72
})

Tabs.Owners:Section({ Title = "NOTAS", Icon = "solar:document-text-bold" })

notesPara = Tabs.Owners:Paragraph({
    Title = "MENSAJE DEL CREADOR",
    Desc = "Hola soy 7.dui, el creador de Open HUB y actualmente el script esta en su mejor fase, les agradecería que tuvieran paciencia para las futuras actualizaciones ya que solo soy yo quien hace todo el script.\n\nNo tengo a nadie quien me ayude en esto pero aun así no me detiene a seguir con esto.\n\nGRACIAS POR USAR NEXVYRHUB, SU APOYO ME SIGUE MOTIVANDO A SEGUIR CON ESTO!!"
})

Tabs.Guardado:Section({ Title = "Gestor de Configs", Icon = "solar:diskette-bold" })

local configFolder = "NexvyrHub_Configs_WindUI"
if isfolder and not isfolder(configFolder) then pcall(function() makefolder(configFolder) end) end

local availableConfigs = { "Ninguna" }
local selectedConfig = "Ninguna"
local customConfigName = ""

local configDropdown = Tabs.Guardado:Dropdown({
    Title = "Seleccionar Configuración",
    Values = availableConfigs,
    Value = "Ninguna",
    Callback = function(Value) selectedConfig = Value end
})

local function refreshConfigs()
    local list = {}
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(configFolder)) do
                if file:match("%.json$") then
                    local name = file:match("([^/\\]+)%.json$")
                    if name then table.insert(list, name) end
                end
            end
        end)
    end
    if #list == 0 then table.insert(list, "Ninguna") end
    pcall(function()
        configDropdown:Refresh(list)
        if selectedConfig == "Ninguna" or not table.find(list, selectedConfig) then
            configDropdown:Select(list[1])
            selectedConfig = list[1]
        end
    end)
end

Tabs.Guardado:Button({ Title = "Actualizar Lista", Icon = "solar:refresh-bold", Variant = "Secondary", Callback = function() refreshConfigs(); showBottomMessage("Lista de configuraciones actualizada.") end })
Tabs.Guardado:Input({ Title = "Nombre para Guardar", Placeholder = "Ej: Config 1, Config 2...", Icon = "solar:text-field-bold", Callback = function(Text) customConfigName = Text end })

local deleteConfirmPending = false
local deleteConfirmTime = 0

Tabs.Guardado:Button({
    Title = "Eliminar todos los guardados",
    Desc = "Borra TODAS las configuraciones guardadas permanentemente.",
    Icon = "solar:trash-bin-trash-bold",
    Variant = "Danger",
    Callback = function()
        local now = os.clock()
        if deleteConfirmPending and (now - deleteConfirmTime) < 4 then
            deleteConfirmPending = false
            if listfiles then
                pcall(function()
                    for _, file in ipairs(listfiles(configFolder)) do
                        if file:match("%.json$") then
                            pcall(function() delfile(file) end)
                        end
                    end
                end)
            end
            refreshConfigs()
            showBottomMessage("Todas las configuraciones fueron eliminadas.")
        else
            deleteConfirmPending = true
            deleteConfirmTime = now
            showBottomMessage("¿Seguro? Presiona de nuevo para confirmar.")
        end
    end
})

local function secureLoadToggle(element, val)
    if not element or val == nil then return end
    pcall(function() element:Set(val) end)
end

Tabs.Guardado:Button({
    Title = "Guardar Configuración",
    Icon = "solar:diskette-bold",
    Variant = "Primary",
    Callback = function()
        local finalName = customConfigName:gsub("[^%w%s%-]", "")
        if finalName == "" then finalName = selectedConfig end
        if finalName == "" or finalName == "Ninguna" then
            showBottomMessage("Escribe un nombre para guardar la configuración.")
            return
        end
        local path = configFolder .. "/" .. finalName .. ".json"
        local configData = {
            ConfigName = finalName,
            Toggles = {
                ["Auto Shoot"] = autoShootEnabled,
                ["Auto Shoot Agresivo"] = autoShootAgresivoEnabled,
                ["Equipar pistola"] = equipGunEnabled,
                ["Silent Aim (Manual)"] = silentAimManualEnabled,
                ["Silent Aim (FOV)"] = silentAimFovEnabled,
                ["Mostrar Círculo FOV"] = fovVisiblePreference,
                ["ESP Jugadores"] = espEnabled,
                ["ESP Glow"] = espSettings.Glow,
                ["Kill All"] = KillAllEnabled,
                ["Hitbox Activar"] = hitboxEnabled,
                ["Hitbox Invisible"] = hitboxInvisible,
                ["Team Check"] = teamCheckEnabled,
                ["Headless"] = HeadlessEnabled,
                ["Korblox"] = KorbloxEnabled
            },
            Sliders = {
                ["Tamaño del FOV"] = fovRadius,
                ["Tamaño de Hitbox"] = hitboxSize,
                ["Volumen Kill Sound"] = KillSoundVolume
            },
            Colors = {
                ["Color de Hitbox"] = {R = hitboxColor.R, G = hitboxColor.G, B = hitboxColor.B},
                ["Color del ESP"] = {R = espColor.R, G = espColor.G, B = espColor.B}
            },
            Extras = {
                ["Parte Silent Aim"] = silentAimTargetPart,
                ["Fondo"] = SelectedFondo.Name,
                ["Tema"] = SelectedTheme
            }
        }
        if writefile then
            local sEncode, encodedData = pcall(function() return HttpService:JSONEncode(configData) end)
            if sEncode then
                pcall(function() writefile(path, encodedData) end)
                showBottomMessage("Guardado como: " .. finalName)
                refreshConfigs()
                pcall(function() configDropdown:Select(finalName) end)
            else
                showBottomMessage("Error interno al procesar los datos.")
            end
        else
            showBottomMessage("Error: Tu ejecutor no soporta guardar archivos.")
        end
    end
})

Tabs.Guardado:Button({
    Title = "Cargar Configuración",
    Icon = "solar:folder-open-bold",
    Variant = "Primary",
    Callback = function()
        if selectedConfig == "Ninguna" or selectedConfig == "" then
            showBottomMessage("No hay ninguna configuración seleccionada.")
            return
        end
        local path = configFolder .. "/" .. selectedConfig .. ".json"
        if isfile and isfile(path) then
            local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
            if success and type(decoded) == "table" then
                if decoded.Toggles then
                    if decoded.Toggles["Auto Shoot"] ~= nil then autoShootEnabled = decoded.Toggles["Auto Shoot"] secureLoadToggle(UIElements.TogAutoShoot, autoShootEnabled) end
                    if decoded.Toggles["Auto Shoot Agresivo"] ~= nil then autoShootAgresivoEnabled = decoded.Toggles["Auto Shoot Agresivo"] secureLoadToggle(UIElements.TogAutoShootAgr, autoShootAgresivoEnabled) end
                    if decoded.Toggles["Equipar pistola"] ~= nil then equipGunEnabled = decoded.Toggles["Equipar pistola"] secureLoadToggle(UIElements.TogEquipGun, equipGunEnabled) end
                    if decoded.Toggles["Silent Aim (Manual)"] ~= nil then silentAimManualEnabled = decoded.Toggles["Silent Aim (Manual)"] secureLoadToggle(UIElements.TogSilentAimManual, silentAimManualEnabled) end
                    if decoded.Toggles["Silent Aim (FOV)"] ~= nil then silentAimFovEnabled = decoded.Toggles["Silent Aim (FOV)"] secureLoadToggle(UIElements.TogSilentAimFOV, silentAimFovEnabled) end
                    if decoded.Toggles["Mostrar Círculo FOV"] ~= nil then fovVisiblePreference = decoded.Toggles["Mostrar Círculo FOV"] secureLoadToggle(UIElements.TogShowFOV, fovVisiblePreference) end
                    if decoded.Toggles["ESP Jugadores"] ~= nil then espEnabled = decoded.Toggles["ESP Jugadores"] secureLoadToggle(UIElements.TogEsp, espEnabled) end
                    if decoded.Toggles["ESP Glow"] ~= nil then espSettings.Glow = decoded.Toggles["ESP Glow"] secureLoadToggle(UIElements.TogEspGl, espSettings.Glow) end
                    if decoded.Toggles["Kill All"] ~= nil then
                        KillAllEnabled = decoded.Toggles["Kill All"]
                        secureLoadToggle(UIElements.TogKillAll, KillAllEnabled)
                    end
                    if decoded.Toggles["Hitbox Activar"] ~= nil then hitboxEnabled = decoded.Toggles["Hitbox Activar"] end
                    if decoded.Toggles["Hitbox Invisible"] ~= nil then hitboxInvisible = decoded.Toggles["Hitbox Invisible"] end
                    if decoded.Toggles["Team Check"] ~= nil then teamCheckEnabled = decoded.Toggles["Team Check"] end
                    if decoded.Toggles["Headless"] ~= nil then
                        HeadlessEnabled = decoded.Toggles["Headless"]
                        if HeadlessEnabled then setHeadless(true) else setHeadless(false) end
                    end
                    if decoded.Toggles["Korblox"] ~= nil then
                        KorbloxEnabled = decoded.Toggles["Korblox"]
                        if KorbloxEnabled then applyKorblox() else removeKorblox() end
                    end
                end
                if decoded.Sliders then
                    if decoded.Sliders["Tamaño del FOV"] ~= nil then fovRadius = decoded.Sliders["Tamaño del FOV"] secureLoadToggle(UIElements.SliFOVSize, fovRadius) end
                    if decoded.Sliders["Tamaño de Hitbox"] ~= nil then hitboxSize = decoded.Sliders["Tamaño de Hitbox"] end
                    if decoded.Sliders["Volumen Kill Sound"] ~= nil then
                        KillSoundVolume = decoded.Sliders["Volumen Kill Sound"]
                        KillSoundPlayer.Volume = KillSoundVolume
                        ShootSoundPlayer.Volume = KillSoundVolume
                        ReloadSoundPlayer.Volume = KillSoundVolume
                    end
                end
                if decoded.Colors then
                    if decoded.Colors["Color de Hitbox"] then
                        hitboxColor = Color3.new(decoded.Colors["Color de Hitbox"].R, decoded.Colors["Color de Hitbox"].G, decoded.Colors["Color de Hitbox"].B)
                    end
                    if decoded.Colors["Color del ESP"] then
                        local cEsp = Color3.new(decoded.Colors["Color del ESP"].R, decoded.Colors["Color del ESP"].G, decoded.Colors["Color del ESP"].B)
                        espColor = cEsp
                        secureLoadToggle(UIElements.ColEsp, cEsp)
                    end
                end
                if decoded.Extras then
                    if decoded.Extras["Parte Silent Aim"] then
                        silentAimTargetPart = decoded.Extras["Parte Silent Aim"]
                        if UIElements.DropSilentAimPart then pcall(function() UIElements.DropSilentAimPart:Select(silentAimTargetPart) end) end
                    end
                    if decoded.Extras["Fondo"] then
                        for _, fondo in ipairs(Backgrounds) do
                            if fondo.Name == decoded.Extras["Fondo"] then
                                SelectedFondo = fondo
                                break
                            end
                        end
                        ApplySelectedBackground()
                    end
                    if decoded.Extras["Tema"] then
                        SelectedTheme = decoded.Extras["Tema"]
                        pcall(function() WindUI:SetTheme(SelectedTheme) end)
                    end
                end
                showBottomMessage("'" .. selectedConfig .. "' cargada con éxito.")
            else
                showBottomMessage("Error al leer el archivo.")
            end
        else
            showBottomMessage("La configuración no existe.")
        end
    end
})

task.spawn(function()
    task.wait(1)
    refreshConfigs()
end)

local fechaUpdate = "04/10/2026"
local cosasAgregadas = { "Detección de aliados mejorada", "Sistema optimizado", "Mejor rendimiento Jeje", "Kill All(Fase Beta)", "Auto Farm evento mejorado", "Equipar pistola automático" }
local cosasArregladas = { "Aimbot y Hitbox arreglados", "Autoshoot arreglado", "ESP arreglado", "Animaciones arregladas", "Sonido de kill instantáneo" }

local function buildUpdateText()
    local lineas = {}
    if #cosasAgregadas > 0 then
        table.insert(lineas, "<font color='#00ff80'><b>Nuevo:</b></font>")
        for _, texto in ipairs(cosasAgregadas) do table.insert(lineas, "<font color='#00ff80'>+ " .. texto .. "</font>") end
        if #cosasArregladas > 0 then table.insert(lineas, "") end
    end
    if #cosasArregladas > 0 then
        table.insert(lineas, "<font color='#f1c40f'><b>Arreglos:</b></font>")
        for _, texto in ipairs(cosasArregladas) do table.insert(lineas, "<font color='#f1c40f'>~ " .. texto .. "</font>") end
    end
    return table.concat(lineas, "\n")
end

Tabs.Update:Section({ Title = "Actualizaciones", Icon = "solar:cloud-download-bold" })

local updatePara = Tabs.Update:Paragraph({
    Title = "Última actualización: " .. fechaUpdate,
    Desc = buildUpdateText()
})
