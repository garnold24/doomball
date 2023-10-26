local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local React = require(ReplicatedStorage.Packages.React)

return function(initialValue)
	local motor = React.useRef(Flipper.SingleMotor.new(initialValue))
	local binding, setBinding = React.useBinding(initialValue)

	React.useEffect(function()
		motor.current:onStep(setBinding)

		return function()
			motor.current:destroy()
		end
	end, {})

	return binding, motor.current
end
