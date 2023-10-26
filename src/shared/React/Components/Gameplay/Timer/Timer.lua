local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useHeartbeat = require(ReplicatedStorage.Shared.React.Hooks.useHeartbeat)

export type TimerProps = {
	anchorPoint: Vector2?,
	position: UDim2?,
	size: UDim2?,

	expireTime: number,
	layoutOrder: number?,
}

local function formatTimer(time: number): string
	local minutes = math.floor(time / 60)
	local seconds = time % 60

	return string.format("%02d:%02d", minutes, seconds)
end

local Timer: React.FC<TimerProps> = function(props: TimerProps)
	local timeBinding, setTimeBinding = React.useBinding(props.expireTime - os.time())
	useHeartbeat(function(dt: number)
		setTimeBinding(math.max(props.expireTime - os.time(), 0))
	end, props.expireTime)

	return React.createElement("TextLabel", {
		AnchorPoint = props.anchorPoint,
		Size = props.size,
		Position = props.position,
		LayoutOrder = props.layoutOrder,

		BackgroundTransparency = 1,
		Font = Enum.Font.Code,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Text = timeBinding:map(function(time: number)
			return formatTimer(time)
		end),
	}, {
		Stroke = React.createElement("UIStroke", {
			Thickness = 2,
		}),
	})
end

return Timer
