local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

return function(callback: (number) -> (), memoizer: any?)
	React.useEffect(function()
		local connection = RunService.Heartbeat:Connect(callback)
		return function()
			connection:Disconnect()
		end
	end, { memoizer })

	return nil
end
