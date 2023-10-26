local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

export type GameStateProps = {
	anchorPoint: Vector2?,
	position: UDim2?,
	size: UDim2?,
	layoutOrder: number?,

	state: string,
}

local GameState: React.FC<GameStateProps> = function(props: GameStateProps)
	return React.createElement("TextLabel", {
		AnchorPoint = props.anchorPoint,
		Size = props.size,
		Position = props.position,
		LayoutOrder = props.layoutOrder,

		BackgroundTransparency = 1,
		Font = Enum.Font.Bangers,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		Text = props.state or "...",
	}, {
		Stroke = React.createElement("UIStroke", {
			Thickness = 2,
		}),
	})
end

return GameState
