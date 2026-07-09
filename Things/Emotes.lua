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

print("[Emote Core] Скрипт загружен. Найдено эмоций: " .. #_G.EmoteList)

local function playEmote()
    if _G.SelectedEmote and _G.SelectedEmote ~= "" and _G.SelectedEmote ~= "Эмоции не найдены" then
        local args = { _G.SelectedEmote }
        EmoteRemote:FireServer(unpack(args))
    end
end

task.spawn(function()
    while _G.EmoteScriptID == currentSessionID do
        if _G.EmoteLoopActive then
            if _G.SelectedEmote and (_G.SelectedEmote ~= lastEmote or _G.EmoteLoopActive ~= lastState) then
                playEmote()
                lastEmote = _G.SelectedEmote
                lastState = _G.EmoteLoopActive
            end
        else
            if lastState then
                lastState = false
                lastEmote = nil
            end
        end
        
        task.wait(0.05)
    end
    print("[Emote Core] Скрипт остановлен.")
end)
