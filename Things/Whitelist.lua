_G.WhitelistSystem = _G.WhitelistSystem or {}
_G.WhitelistSystem.List = _G.WhitelistSystem.List or {}

function _G.WhitelistSystem.Add(player)
	if player and player:IsA("Player") then
		_G.WhitelistSystem.List[player.UserId] = true
		print("[WL]", player.Name, "добавлен в вайтлист.")
	end
end

function _G.WhitelistSystem.Remove(player)
	if player and player:IsA("Player") then
		_G.WhitelistSystem.List[player.UserId] = nil
		print("[WL]", player.Name, "удален из вайтлиста.")
	end
end

function _G.WhitelistSystem.IsWhitelisted(player)
	if not player or not player:IsA("Player") then return false end
	return _G.WhitelistSystem.List[player.UserId] == true
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	_G.WhitelistSystem.List[player.UserId] = nil
end)
