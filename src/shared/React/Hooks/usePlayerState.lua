local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

return function(userId: number?)
	local ingame, setIngame = React.useState(false)
	local score, setScore = React.useState(0)

	React.useEffect(function()
		-- observe the player's state from an observer probably from a controller
	end, { userId })

	return ingame, score
end
