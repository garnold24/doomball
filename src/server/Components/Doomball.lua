local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local ComponentService = require(ReplicatedStorage.Shared.Services.ComponentService)
local GameService = require(ServerScriptService.Server.Services.GameService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Trove = require(ReplicatedStorage.Packages.Trove)

local IMPULSE_TIME_STEP = 1
local IMPULSE_PERIOD = 2
local IMPULSE_DELTA_V = 175

local BALL_DAMAGE = 60
local HIT_RATE = 1 -- per second

local Doomball = {}
Doomball.__index = Doomball

local function getCharacterFromDescendant(obj: Instance?): Player?
	if not obj or obj == workspace then return end
	if obj:FindFirstChild("Humanoid") then return obj :: Player end
	return getCharacterFromDescendant(obj.Parent :: Instance)
end

function Doomball:_damagePlayer(player: Player)
	if self._taggedPlayers[player] then return end

	self._taggedPlayers[player] = true
	Promise.delay(HIT_RATE):andThen(function()
		self._taggedPlayers[player] = nil
	end)

	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then return end

	humanoid:TakeDamage(BALL_DAMAGE)
end

function Doomball:_shouldImpulse()
	if self._impulsing then return false end
	if tick() - self._lastImpulse < IMPULSE_PERIOD then return false end
	return true
end

function Doomball:_impulse(player: Player)
	local doomBall = self._instance
	local mass = doomBall:GetMass()

	local function impulseTowardsPlayer(deltaTime)
		local char = player.Character
		if not char then return end

		local targetPos = char.PrimaryPart and char.PrimaryPart.Position
		if not targetPos then return end

		local displacement = (targetPos - self._instance.Position)
		local directionXZ = Vector3.new(displacement.X, 0, displacement.Z).Unit

		local targetVelocity = directionXZ * IMPULSE_DELTA_V - self._instance.Velocity

		-- impulse: F = mv/Δt
		local impulseForce = (mass * targetVelocity) / IMPULSE_TIME_STEP
		doomBall:ApplyImpulse(impulseForce * deltaTime)
	end

	-- apply impulse over the course of the impulse period
	return self._trove:AddPromise(Promise.new(function(resolve, _reject)
		local stepConnection = self._trove:Add(RunService.Stepped:Connect(function(_gameTime: number, deltaTime: number)
			impulseTowardsPlayer(deltaTime)
		end))
		Promise.delay(IMPULSE_PERIOD):andThen(function()
			resolve(stepConnection)
		end)
	end):andThen(function(connection)
		connection:Disconnect()
	end))
end

function Doomball:_step()
	local activeGame = GameService:getActiveGame()
	if not activeGame then return end

	local gameState = activeGame:getGameState()
	if gameState ~= "InProgress" then return end

	if not self:_shouldImpulse() then return end

	local players = activeGame:getPlayers()
	if #players == 0 then return end

	-- move towards the nearest player
	local nearestPlayer = players[1]
	local nearestDistance = math.huge
	for _, player in players do
		local distance = (player.Character.HumanoidRootPart.Position - self._instance.Position).Magnitude
		if distance > nearestDistance then continue end
		nearestPlayer = player
		nearestDistance = distance
	end

	self._impulsing = true
	self:_impulse(nearestPlayer):finally(function()
		self._impulsing = false
		self._lastImpulse = tick()
	end)
end

function Doomball.new(instance: BasePart)
	local self = setmetatable({
		_instance = instance,
		_trove = Trove.new(),
		_lastImpulse = tick(),
		_taggedPlayers = {},
	}, Doomball)

	self._trove:Add(RunService.Stepped:Connect(function(_gameTime: number, _deltaTime: number)
		self:_step()
	end))

	self._trove:Add(instance.Touched:Connect(function(hit)
		local activeGame = GameService:getActiveGame()
		if not activeGame then return end

		local char = getCharacterFromDescendant(hit)
		local player = char and Players:GetPlayerFromCharacter(char)
		if not player then return end

		local players = activeGame:getPlayers()
		if not table.find(players, player) then return end

		self:_damagePlayer(player)
	end))
	return self
end

function Doomball:destroy()
	self._trove:Clean()
end

return ComponentService:registerComponentClass("Doomball", Doomball)
