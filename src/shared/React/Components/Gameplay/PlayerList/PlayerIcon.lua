local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local usePlayerIcon = require(ReplicatedStorage.Shared.React.Hooks.usePlayerIcon)

export type PlayerIconProps = {
	anchorPoint: Vector2?,
	size: UDim2?,
	position: UDim2?,

	backgroundColor3: Color3?,
	backgroundTransparency: number?,

	layoutOrder: number?,

	player: number,
}

local PlayerIcon: React.FC<PlayerIconProps> = function(props: PlayerIconProps)
	local playerIcon = usePlayerIcon(props.player, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)

	return React.createElement("ImageLabel", {
		BackgroundTransparency = props.backgroundTransparency or 0,
		BackgroundColor3 = props.backgroundColor3 or Color3.fromRGB(255, 255, 255),

		Image = playerIcon,
		Size = props.size or UDim2.fromScale(1, 1),
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),
		Position = props.position or UDim2.fromScale(0.5, 0.5),
		LayoutOrder = props.layoutOrder,
	}, {
		Corner = React.createElement("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		Stroke = React.createElement("UIStroke", {
			Thickness = 3,
		}),
	})
end

return PlayerIcon
