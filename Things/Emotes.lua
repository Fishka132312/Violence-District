-- Настройки путей
local EmotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Emotes")
local EmoteRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EmoteHandler")

-- Глобальные переменные для управления
_G.EmoteList = {}        -- Сюда сохранятся имена всех эмоций для Dropdown
_G.SelectedEmote = nil   -- Текущая выбранная эмоция
_G.EmoteLoopActive = false -- Состояние тумблера (вкл/выкл)

-- 1. Собираем все эмоции из папки
for _, emote in ipairs(EmotesFolder:GetChildren()) do
    if emote:IsA("Folder") or emote:IsA("Configuration") or emote:IsA("StringValue") then
        table.insert(_G.EmoteList, emote.Name)
    end
end

-- Сортируем по алфавиту для красоты в меню
table.sort(_G.EmoteList)

-- 2. Функция для проигрывания эмоции
local function playEmote()
    if _G.SelectedEmote and _G.SelectedEmote ~= "" then
        local args = { _G.SelectedEmote }
        EmoteRemote:FireServer(unpack(args))
    end
end

-- 3. Цикл, который ждет активации Toggle
task.spawn(function()
    while true do
        if _G.EmoteLoopActive and _G.SelectedEmote then
            playEmote()
            -- Задержка между спамом эмоции (подкрути под себя, если нужно реже/чаще)
            task.wait(0.5) 
        else
            task.wait(0.1) -- Отдых скрипта, если выключено
        end
    end
end)

print("[Emote Core] Скрипт загружен. Найдено эмоций: " .. #_G.EmoteList)
