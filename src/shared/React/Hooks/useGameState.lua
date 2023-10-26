local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

return function()
	local active, setActive = React.useState(false)
	local gameState, setGameState = React.useState("Waiting")
	local timer, setTimer = React.useState(os.time())
	local players, setPlayers = React.useState({})

	React.useEffect(function()
		-- observe the game's state from an observer probably from a controller
	end, {})

	return active, gameState, timer, players
end
