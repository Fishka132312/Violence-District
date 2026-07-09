local EmotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Emotes")
local EmoteRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EmoteHandler")

_G.EmoteScriptID = os.clock()
local currentSessionID = _G.EmoteScriptID

_G.EmoteList = {}
_G.SelectedEmote = nil
_G.EmoteLoopActive = false

local lastEmote = nil
local lastState = false

for _, emote in ipairs(EmotesFolder:GetChildren()) do
    if emote:IsA("Folder") or emote:IsA("Configuration") or emote:IsA("StringValue") then
        table.insert(_G.EmoteList, emote.Name)
    end
end

table.sort(_G.EmoteList)

local function playEmote()
    if _G.SelectedEmote and _G.SelectedEmote ~= "" then
        local args = { _G.SelectedEmote }
        EmoteRemote:FireServer(unpack(args))
        print("[Emote Core] Ремоут отправлен 1 раз для: " .. _G.SelectedEmote)
    end
end

task.spawn(function()
    while true do
        if _G.EmoteScriptID ~= currentSessionID then 
            break 
        end

        if _G.EmoteLoopActive and (_G.EmoteLoopActive ~= lastState or _G.SelectedEmote ~= lastEmote) then
            playEmote()
            lastEmote = _G.SelectedEmote
            lastState = _G.EmoteLoopActive
        elseif not _G.EmoteLoopActive and lastState then
            lastState = false
            lastEmote = nil
        end
        
        task.wait(0.05)
    end
end)

print("[Emote Core] Скрипт загружен. Найдено эмоций: " .. #_G.EmoteList)
