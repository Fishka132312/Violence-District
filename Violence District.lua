local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Violence District", HidePremium = false, SaveConfig = true, ConfigFolder = "Violence District meowl"})

local scripts = {
    'Emotes.lua',
}

local baseUrl = 'https://raw.githubusercontent.com/Fishka132312/Violence-District/refs/heads/main/Things/'

-- Инициализируем переменные заранее, чтобы Orion Lib не выдавал ошибку, если загрузка задержится
_G.EmoteList = _G.EmoteList or {}
_G.SelectedEmote = _G.SelectedEmote or nil
_G.EmoteLoopActive = _G.EmoteLoopActive or false

-- Загружаем скрипты СИНХРОННО (без task.spawn), чтобы дождаться заполнения _G.EmoteList
for i, scriptName in ipairs(scripts) do
    local fullUrl = baseUrl .. scriptName
    
    local success, err = pcall(function()
        local code = game:HttpGet(fullUrl)
        if code then
            loadstring(code)()
        else
            warn("Не удалось получить код для: " .. scriptName)
        end
    end)
    
    if not success then
        warn("Ошибка при загрузке " .. scriptName .. ": " .. tostring(err))
    end
    
    task.wait(0.5) -- Небольшая задержка между скриптами, если их будет больше
end

-- Защита от краша Orion Lib: если папка пустая или скрипт не скачался, делаем дефолтный список
if #_G.EmoteList == 0 then
    _G.EmoteList = {"Эмоции не найдены"}
end

-------------------------Emotes---------------------------

local Tab = Window:MakeTab({
	Name = "Emotes",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Дропдаун
Tab:AddDropdown({
	Name = "Выбрать Эмоцию",
	Default = _G.EmoteList[1], 
	Options = _G.EmoteList, 
	Callback = function(Value)
		if Value ~= "Эмоции не найдены" then
			_G.SelectedEmote = Value
			print("Выбрана эмоция: " .. tostring(_G.SelectedEmote))
		end
	end    
})

-- Чекбокс (Toggle)
Tab:AddToggle({
	Name = "Воспроизводить эмоцию",
	Default = false,
	Callback = function(Value)
		_G.EmoteLoopActive = Value
		if Value then
			print("Цикл эмоции запущен для: " .. tostring(_G.SelectedEmote))
		else
			print("Цикл эмоции остановлен.")
		end
	end    
})

-------------------------Shader---------------------------

local Tab = Window:MakeTab({
	Name = "Shaders",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Shaders"
})

Tab:AddButton({
	Name = "Meowl Shaders",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/coolgui/refs/heads/main/Things/Shaders/MeowlShaders.lua'))()  
  	end    
})

--------------------------------MISC-----------------------------

local Tab = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Tools"
})

Tab:AddButton({
	Name = "Infinite Yield",
	Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Fishka132312/ignore-it/refs/heads/main/infiniteyield'))()
  	end    
})

Tab:AddButton({
	Name = "Destroy Gui",
	Callback = function()
    OrionLib:Destroy()
    end    
})

OrionLib:Init()
