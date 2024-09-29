local category = Menu.Create("Scripts", "Main", "Misc")
category:Icon("")

local JSON = require('assets.JSON')
local personalName = Steam:GetPersonaName()
local scriptVersion = "1.0.0"

local CurrentMMR = Engine:GetMMRV2()
local IsInLobby = Engine:IsInLobby()
local getbluid = Engine:GetBuildVersion()
local getuistate = Engine:GetUIState()
local menu_main = category:Create("Main")
local getchannels = Chat:GetChannels()
local getlocalid = GC:GetSteamID()


local Info = menu_main:Create("Info")
local versionLabel = Info:Label("Script version: " .. scriptVersion, "")
local cheatVersionLabel = Info:Label("Cheat version: " .. getbluid, "")

local SomeInfo = menu_main:Create("Some Info")
local steamNameLabel = SomeInfo:Label("Steam name: " .. personalName, "")
local mmrLabel = SomeInfo:Label("MMR: " .. CurrentMMR, "")


local debugCategory = menu_main:Create("Open Stratz/dotabuff")
local debugCategorylabel = debugCategory:Label("Open user profile and click")
local parseIDButton = debugCategory:Button("Parse Friends ID")
parseIDButton:ToolTip("Click to parse the Friends ID.")

local lastIDLabel = nil 

local function parseFriendsID()
    local parentPanel = Panorama.GetPanelByName("SteamFriends")
    if parentPanel then
        local friendsIDPanel = parentPanel:FindChild("FriendsID")
        if friendsIDPanel then
            local friendsIDText = friendsIDPanel:GetText()

           
            if lastIDLabel then lastIDLabel:Visible(false) end
            if dotabuffButton then dotabuffButton:Visible(false) end
            if stratzButton then stratzButton:Visible(false) end

            
            lastIDLabel = debugCategory:Label("Friends ID: " .. friendsIDText)

           
            dotabuffButton = debugCategory:Button("Open Dotabuff")
            dotabuffButton:SetCallback(function()
                Engine.RunScript("$.DispatchEvent('ExternalBrowserGoToURL', 'https://www.dotabuff.com/players/" .. friendsIDText .. "');")
            end)

            stratzButton = debugCategory:Button("Open Stratz")
            stratzButton:SetCallback(function()
                Engine.RunScript("$.DispatchEvent('ExternalBrowserGoToURL', 'https://stratz.com/players/" .. friendsIDText .. "');")
            end)
        end
    end
end

parseIDButton:SetCallback(parseFriendsID)


local function checkSteamIDAgainstGithub()
    local url = "https://raw.githubusercontent.com/nkplka/scripts/refs/heads/main/userdata"
    local headers = {
        ["User-Agent"] = "Umbrella/1.0",
        ["Connection"] = "Keep-Alive"
    }

    local callback = function(response)
        if tonumber(response.code) == 200 then
            local ids = {}
            for id in response.response:gmatch("[^\r\n]+") do
                table.insert(ids, id)
            end

            local role = "user" 
            for _, id in ipairs(ids) do
                if id == tostring(getlocalid) then
                    role = "dev" 
                    
                    break
                end
            end

            Info:Label("Role: " .. role, "")
            if role == "user" then
                
            end
        else
            
        end
    end

    HTTP.Request("GET", url, { headers = headers }, callback, "fetch_ids")
end

checkSteamIDAgainstGithub()

local function fetchScriptVersion()
    local url = "https://raw.githubusercontent.com/nkplka/scripts/refs/heads/main/version.txt"
    local headers = {
        ["User-Agent"] = "Umbrella/1.0",
        ["Connection"] = "Keep-Alive"
    }

    local callback = function(response)
        if tonumber(response.code) == 200 then
            local newVersion = response.response:match("^%s*(.-)%s*$")

            if newVersion ~= scriptVersion then
                if newVersion > scriptVersion then
                    local color = Color(0, 0, 255)
                    Info:Label("Update available: " .. newVersion, "")
                    UpdateButton = Info:Button("Update")
                    UpdateButton:SetCallback(function()
                        Engine.RunScript("$.DispatchEvent('ExternalBrowserGoToURL', 'https://github.com/nkplka/scripts/blob/main/script.lua');")
                    end)
                end
            end
        end
    end

    HTTP.Request("GET", url, { headers = headers }, callback, "fetch_version")
end

fetchScriptVersion()


local settingsCategory = category:Create("Dota Settings")


local DotaSettings = settingsCategory:Create("Settings")

local fps_max_convar = ConVar.Find("fps_max")
local cl_showfps_convar = ConVar.Find("cl_showfps")
local dota_activate_window_on_unpause_convar = ConVar.Find("dota_activate_window_on_unpause")
local dota_activate_window_on_ready_check_convar = ConVar.Find("dota_activate_window_on_ready_check")
local dota_activate_window_on_match_found_convar = ConVar.Find("dota_activate_window_on_match_found")
local dota_activate_window_on_hero_picking_start_convar = ConVar.Find("dota_activate_window_on_hero_picking_start")

local initialFpsMax = ConVar.GetFloat(fps_max_convar)
local initialShowFps = ConVar.GetInt(cl_showfps_convar)
local initialUnpause = ConVar.GetInt(dota_activate_window_on_unpause_convar)
local initialReadyCheck = ConVar.GetInt(dota_activate_window_on_ready_check_convar)
local initialMatchFound = ConVar.GetInt(dota_activate_window_on_match_found_convar)
local initialHeroPicking = ConVar.GetInt(dota_activate_window_on_hero_picking_start_convar)
local fpsSlider = DotaSettings:Slider("FPS Max", 10, 360, initialFpsMax)


fpsSlider:SetCallback(function()
    local sliderValue = fpsSlider:Get()
    ConVar.SetFloat(fps_max_convar, sliderValue)
end)

local showFpsCheckbox = DotaSettings:Switch("Show FPS", initialShowFps == 1)


showFpsCheckbox:SetCallback(function()
    local checkboxValue = showFpsCheckbox:Get()
    ConVar.SetInt(cl_showfps_convar, checkboxValue and 1 or 0)
end)

local unpauseSwitch = DotaSettings:Switch("Activate window on unpause", initialUnpause == 1)
local readyCheckSwitch = DotaSettings:Switch("Activate window on ready check", initialReadyCheck == 1)
local matchFoundSwitch = DotaSettings:Switch("Activate window on match found", initialMatchFound == 1)
local heroPickingSwitch = DotaSettings:Switch("Activate window on hero picking start", initialHeroPicking == 1)


unpauseSwitch:SetCallback(function()
    local switchValue = unpauseSwitch:Get()
    ConVar.SetInt(dota_activate_window_on_unpause_convar, switchValue and 1 or 0)
end)

readyCheckSwitch:SetCallback(function()
    local switchValue = readyCheckSwitch:Get()
    ConVar.SetInt(dota_activate_window_on_ready_check_convar, switchValue and 1 or 0)
end)

matchFoundSwitch:SetCallback(function()
    local switchValue = matchFoundSwitch:Get()
    ConVar.SetInt(dota_activate_window_on_match_found_convar, switchValue and 1 or 0)
end)

heroPickingSwitch:SetCallback(function()
    local switchValue = heroPickingSwitch:Get()
    ConVar.SetInt(dota_activate_window_on_hero_picking_start_convar, switchValue and 1 or 0)
end)

local lobbyCategory = category:Create("Lobby Settings")


local lobbyCategory = category:Create("Lobby Settings")
local LobbySettings = lobbyCategory:Create("Settings")


local dota_all_vision_convar = ConVar.Find("dota_all_vision")
local dota_disable_creep_spawning_convar = ConVar.Find("dota_disable_creep_spawning")
local dota_disable_allheroes_convar = ConVar.Find("dota_disable_allheroes")


local initialAllVision = ConVar.GetInt(dota_all_vision_convar)
local initialDisableCreepSpawning = ConVar.GetInt(dota_disable_creep_spawning_convar)
local initialDisableAllHeroes = ConVar.GetInt(dota_disable_allheroes_convar)


local allVisionSwitch = LobbySettings:Switch("Enable All Vision", initialAllVision == 1)



allVisionSwitch:SetCallback(function()
    local switchValue = allVisionSwitch:Get()
    ConVar.SetInt(dota_all_vision_convar, switchValue and 1 or 0)
end)


local chatCommandsCategory = lobbyCategory:Create("Chat Commands")


local goldButton = chatCommandsCategory:Button("Max Gold")
goldButton:SetCallback(function()
    Engine.ExecuteCommand('dota_dev player_givegold 99999')

end)

local lvlupButton = chatCommandsCategory:Button("Max LVL")
lvlupButton:SetCallback(function()
    Engine.ExecuteCommand('dota_dev hero_maxlevel')
end)
local refreshButton = chatCommandsCategory:Button("Refresh")
refreshButton:SetCallback(function()
    Engine.ExecuteCommand('dota_dev hero_refresh')
end)


local respawnButton = chatCommandsCategory:Button("Respawn")
respawnButton:SetCallback(function()
    Engine.ExecuteCommand('dota_dev hero_respawn')
    
end)

local winbutton = chatCommandsCategory:Button("Win))))")
respawnButton:SetCallback(function()
    Engine.ExecuteCommand('dota_dev hero_win')
end)


local Debugcategory = category:Create("Debug")

local DebugPanel = Debugcategory:Create("")
local versionLabel2 = DebugPanel:Label("Script version: " .. scriptVersion, "")


return {}
