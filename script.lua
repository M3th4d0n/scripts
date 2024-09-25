local category = Menu.Create("Scripts", "Main", "Misc")
category:Icon("")
print("script init")

local personalName = Steam:GetPersonaName()
local scriptVersion = "1.0.0"
local CurrentMMR = Engine:GetMMRV2()
local IsInLobby = Engine:IsInLobby()
local getbluid = Engine:GetBuildVersion()
local getuistate = Engine:GetUIState()
local menu_main = category:Create("Main")

local Info = menu_main:Create("Info")
Info:Label("Script version: " .. scriptVersion, "")
Info:Label("Steam name: " .. personalName, "")
Info:Label("MMR: " .. CurrentMMR, "")
Info:Label("Is in lobby: " .. tostring(IsInLobby), "")
Info:Label("Cheat version: " .. getbluid, "")
Info:Label("UI state: " .. getuistate, "")

local debugCategory = menu_main:Create("Friends ID")
local parseIDButton = debugCategory:Button("Parse Friends ID")
parseIDButton:ToolTip("Click to parse the Friends ID.")

local lastIDLabel = nil 

local function parseFriendsID()
    print("try parse friend id...")
    local parentPanel = Panorama.GetPanelByName("SteamFriends")
    if parentPanel then
        local friendsIDPanel = parentPanel:FindChild("FriendsID")
        if friendsIDPanel then
            local friendsIDText = friendsIDPanel:GetText()
            
            if lastIDLabel then
                lastIDLabel:Visible(false)
            end
            
            lastIDLabel = debugCategory:Label("Friends ID: " .. friendsIDText)
            print("Parsed Friends ID: " .. friendsIDText)
        else
            print("Friends ID panel not found.")
        end
    else
        print("Parent panel not found.")
    end
end

parseIDButton:SetCallback(parseFriendsID)

local pingCategory = menu_main:Create("Ping")

print("script init complete")

return {}
