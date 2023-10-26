local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Countdown = require(ReplicatedStorage.Shared.React.Components.Gameplay.Countdown.Countdown)
local GameState = require(ReplicatedStorage.Shared.React.Components.Gameplay.GameState.GameState)
local PlayerList = require(ReplicatedStorage.Shared.React.Components.Gameplay.PlayerList.PlayerList)
local React = require(ReplicatedStorage.Packages.React)
local Timer = require(ReplicatedStorage.Shared.React.Components.Gameplay.Timer.Timer)
local useGameState = require(ReplicatedStorage.Shared.React.Hooks.useGameState)

export type HudAppProps = {}

local HudApp: React.FC<HudAppProps> = function(props: HudAppProps)
	local active, gameState, timer, players = useGameState()

	return React.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, {
		GameHudFrame = React.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		}, {
			UIListLayout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Padding = UDim.new(0, 8),
			}),
			GameState = active and React.createElement(GameState, {
				size = UDim2.new(0, 64 * 4, 0, 64),
				state = gameState,
				layoutOrder = 1,
			}),
			Timer = (active and gameState == "InProgress") and React.createElement(Timer, {
				size = UDim2.new(0, 128, 0, 64),
				expireTime = timer,
				layoutOrder = 2,
			}),
			PlayerList = active and React.createElement(PlayerList, {
				playerIds = players,
				layoutOrder = 3,
			}),
		}),

		Countdown = (active and gameState == "Starting") and React.createElement(Countdown, {
			expireTime = timer,
		}),
	})
end

return HudApp
