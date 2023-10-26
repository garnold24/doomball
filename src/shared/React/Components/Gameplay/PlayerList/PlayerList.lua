local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerIcon = require(ReplicatedStorage.Shared.React.Components.Gameplay.PlayerList.PlayerIcon)
local React = require(ReplicatedStorage.Packages.React)

export type PlayerListProps = {
	pixelHeight: number?,
	position: UDim2?,

	playerIds: { number },
}

local PlayerList: React.FC<PlayerListProps> = function(props: PlayerListProps)
	local children = {
		UIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,

			Padding = UDim.new(0, 12),
		}),
	}
	for i, player in props.playerIds do
		children[tostring(player)] = React.createElement(PlayerIcon, {
			size = UDim2.new(0, props.pixelHeight or 48, 0, props.pixelHeight or 48),

			layoutOrder = i,
			player = player,
		})
	end

	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = props.position,
		Size = UDim2.new(0.5, 0, 0, props.pixelHeight or 48),
	}, children)
end

return PlayerList
