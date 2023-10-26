local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local React = require(ReplicatedStorage.Packages.React)

return function(userId: number, thumbnailType: Enum.ThumbnailType, thumbnailSize: Enum.ThumbnailSize)
	local icon, setIcon = React.useState("")

	React.useEffect(function()
		local fetchPromise = Promise.new(function(resolve, _reject)
			setIcon(Players:GetUserThumbnailAsync(userId, thumbnailType, thumbnailSize))
		end):catch(function(err)
			warn("couldn't get player icon:", err)
		end)
		return function()
			fetchPromise:cancel()
		end
	end, { userId })

	return icon
end
