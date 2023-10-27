local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local HudApp = require(ReplicatedStorage.Shared.React.Components.HudApp.HudApp)
local Loader = require(ReplicatedStorage.Shared.Loader)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local GameController = {}
GameController.className = "GameController"
GameController.priority = 0

function GameController:getGameStateReplicator(property)
	return self._comm:GetProperty(property)
end

function GameController:init() end

function GameController:start()
	self._comm = Comm.ClientComm.new(ReplicatedStorage, true, "GameService")

	-- mount hud
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal(React.createElement(HudApp), Players.LocalPlayer.PlayerGui, "HudApp"))
end

return Loader:registerSingleton(GameController)
