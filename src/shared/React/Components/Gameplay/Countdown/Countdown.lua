local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useHeartbeat = require(ReplicatedStorage.Shared.React.Hooks.useHeartbeat)

export type CountdownProps = {
	expireTime: number,
}

local Countdown: React.FC<CountdownProps> = function(props: CountdownProps)
	local timeBinding, setTimeBinding = React.useBinding(props.expireTime - os.time())
	useHeartbeat(function(dt: number)
		setTimeBinding(math.max(props.expireTime - os.time(), 0))
	end, props.expireTime)

	return React.createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),

		Font = Enum.Font.Bangers,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Text = timeBinding:map(function(time: number)
			return time > 0 and math.floor(time) or "RUN!"
		end),
	}, {
		Stroke = React.createElement("UIStroke", {
			Thickness = 4,
		}),
	})
end

return Countdown
