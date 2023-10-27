local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local useHeartbeat = require(ReplicatedStorage.Shared.React.Hooks.useHeartbeat)

local START_TIME = tick()

export type QueueZoneUIProps = {
	getCurrentPlayers: () -> number,
	getLaunchTime: () -> number,
	neededPlayers: number,
	target: BasePart, -- part to render the queue zone on
}

local function getCFrameFromTarget(target: BasePart): CFrame
	local size = target.Size
	local position = target.Position
	local cframe = CFrame.new(position.X, position.Y + size.X / 8, position.Z)

	return cframe * CFrame.Angles(0, (tick() - START_TIME) * math.pi / 4, 0)
end

local function zoneUI(props)
	local hasPlayers = props.currentPlayers >= props.neededPlayers
	return React.createElement("SurfaceGui", {
		Face = props.face,
		LightInfluence = 0,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		SizingMode = Enum.SurfaceGuiSizingMode.FixedSize,
		PixelsPerStud = 20,
	}, {
		Frame = React.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			TextLabel = React.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamBlack,
				Size = UDim2.fromScale(1, 1),
				Text = `{hasPlayers and `Launching in {props.launchTime} seconds!` or "Enter to play!"}\n\nPlayers:\n\n {props.currentPlayers} / {props.neededPlayers}`,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextWrapped = true,
			}),
		}),
	})
end

local QueueZoneUI: React.FC<QueueZoneUIProps> = function(props: QueueZoneUIProps)
	local cframeBinding, setCFrameBinding = React.useBinding(getCFrameFromTarget(props.target))
	local currentPlayers, setCurrentPlayers = React.useState(props.getCurrentPlayers())
	local launchTime, setLaunchTime = React.useState(props.getLaunchTime())

	useHeartbeat(function()
		local cf = getCFrameFromTarget(props.target)
		setCFrameBinding(cf)
		setCurrentPlayers(props.getCurrentPlayers())
		setLaunchTime(props.getLaunchTime() - os.time())
	end, props.target)

	return React.createElement("Part", {
		Anchored = true,
		CFrame = cframeBinding,
		Size = Vector3.new(24, 12, 0.2),
		Transparency = 1,
	}, {
		Front = zoneUI({
			face = Enum.NormalId.Front,
			launchTime = launchTime,
			currentPlayers = currentPlayers,

			neededPlayers = props.neededPlayers,
		}),
		Back = zoneUI({
			face = Enum.NormalId.Back,
			launchTime = launchTime,
			currentPlayers = currentPlayers,
			neededPlayers = props.neededPlayers,
		}),
	})
end

return QueueZoneUI
