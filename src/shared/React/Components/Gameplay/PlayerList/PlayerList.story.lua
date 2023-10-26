local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerList = require(ReplicatedStorage.Shared.React.Components.Gameplay.PlayerList.PlayerList)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

return function(target)
	local element = React.createElement(PlayerList, {
		pixelHeight = 48,
		position = UDim2.new(0.5, 0, 0, 0),
		playerIds = { 324616, 4402987, 2359386, 7766698, 817067 },
	})

	local root = ReactRoblox.createRoot(target)
	root:render(element)

	return function()
		root:unmount()
	end
end
