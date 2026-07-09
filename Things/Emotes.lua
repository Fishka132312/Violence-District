-- Настройки путей
local EmotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Emotes")
local EmoteRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("EmoteHandler")

-- Глобальные переменные для управления
_G.EmoteList = {}        -- Сюда сохранятся имена всех эмоций для Dropdown
_G.SelectedEmote = nil   -- Текущая выбранная эмоция
_G.EmoteLoopActive = false -- Состояние тумблера (вкл/выкл)

-- Переменные для отслеживания изменений (чтобы не спамить)
local lastEmote = nil
local lastState = false

-- 1. Собираем все эмоции из папки
for _, emote in ipairs(EmotesFolder:GetChildren()) do
    if emote:IsA("Folder") or emote:IsA("Configuration") or emote:IsA("StringValue") then
        table.insert(_G.EmoteList, emote.Name)
    end
end

-- Сортируем по алфавиту для красоты в меню
table.sort(_G.EmoteList)

-- 2. Функция для проигрывания эмоции (срабатывает 1 раз)
local function playEmote()
    if _G.SelectedEmote and _G.SelectedEmote ~= "" then
        local args = { _G.SelectedEmote }
        EmoteRemote:FireServer(unpack(args))
        print("[Emote Core] Ремоут отправлен 1 раз для: " .. _G.SelectedEmote)
    end
end

-- 3. Цикл, который следит за изменениями
task.spawn(function()
    while true do
        -- Если тумблер включили ИЛИ тумблер включен, но мы выбрали ДРУГУЮ эмоцию
        if _G.EmoteLoopActive and (_G.EmoteLoopActive ~= lastState or _G.SelectedEmote ~= lastEmote) then
            playEmote()
            
            -- Запоминаем текущее состояние, чтобы не отправлять повторно
            lastEmote = _G.SelectedEmote
            lastState = _G.EmoteLoopActive
        elseif not _G.EmoteLoopActive and lastState then
            -- Если тумблер выключили, просто обновляем старое состояние, чтобы при следующем включении сработало
            lastState = false
            lastEmote = nil -- Сбрасываем, чтобы можно было заново активировать ту же эмоцию
        end
        
        task.wait(0.05) -- Быстрая проверка изменений без нагрузки на процессор
    end
end)

print("[Emote Core] Скрипт загружен. Найдено эмоций: " .. #_G.EmoteList)
