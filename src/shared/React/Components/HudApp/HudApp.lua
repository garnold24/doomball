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
			}),
			GameState = active and React.createElement(GameState, {
				state = gameState,
			}),
			Timer = (active and gameState == "InProgress") and React.createElement(Timer, {
				expireTime = timer,
			}),
			PlayerList = active and React.createElement(PlayerList, {
				players = players,
			}),
		}),

		Countdown = (active and gameState == "Starting") and React.createElement(Countdown, {
			expireTime = timer,
		}),
	})
end

return HudApp
