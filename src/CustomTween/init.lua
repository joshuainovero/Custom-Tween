local module = {}

local RunService = game:GetService("RunService")
local Signal = require(script.Signal)

local SignalBaseName = {
	Completed = "Completed",
	Cancelled = "Cancelled",
	Started   = "Started"
}

function module:__index(index)
	local signalIndex = SignalBaseName[index]

	if signalIndex then
		return setmetatable({
			Connect = function(_, callback)
				return self._signals[SignalBaseName[signalIndex]]:Connect(callback)
			end
		}, {
			__index = function(ind)
				error(("%s is not a valid member/function. Use :Connect(func)!"):format(tostring(ind)))
			end
		})

	else
		return module[index]
	end

end


function module.new(instance, properties, runningTime, info)
	local startProperties = {}
	for property, _ in pairs(properties) do
		startProperties[property] = instance[property]
	end

	return setmetatable({
		_runningTime = runningTime,
		_running = false,
		_debugTime = false,

		_object = instance,
		_instance = instance,
		_info = info,
		_startProperties = startProperties,
		_targetProperties = properties,

		_signals = {
			[SignalBaseName.Completed] = Signal.new(),
			[SignalBaseName.Cancelled] = Signal.new(),
			[SignalBaseName.Started] = Signal.new(),
		}


	}, module)
end

function RunTween(tab)
	tab._running = true
	tab._signals[SignalBaseName.Started]:Fire()

	local currentProperties, subTargetProperty = {},{}
	for property, value in pairs(tab._targetProperties) do
		currentProperties[property] = tab._instance[property]
		subTargetProperty[property] = tab._startProperties[property]:Lerp(value, tab._info[2][2])
	end

	local alpha = 0
	local easingIndex = 1
	local targetData = tab._info[1]
	local subTime = (tab._info[2][1] * tab._runningTime) - (tab._info[1][1] * tab._runningTime)
	local easingTable = tab._info

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if tab._running then
			for property, value in pairs(tab._targetProperties) do
				alpha += dt/subTime
				if alpha > 1 then
					alpha = 1
				end

				tab._object[property] = currentProperties[property]:Lerp(subTargetProperty[property], alpha)

				if alpha >= 1 then
					easingIndex += 1
					alpha = 0
					if easingIndex == #easingTable then
						tab._running = false
						tab._signals[SignalBaseName.Completed]:Fire()
						connection:Disconnect()
						break
					else
						targetData = easingTable[easingIndex]
						subTime = (easingTable[easingIndex + 1][1] * tab._runningTime) - (targetData[1] * tab._runningTime)
						currentProperties[property] = tab._object[property]
						subTargetProperty[property] = tab._startProperties[property]:Lerp(value, easingTable[easingIndex + 1][2])
					end

				end
			end
		end
	end)
end

function SetStartingProperties(instance, properties)
	for property, value in pairs(properties) do
		instance[property] = value
	end
end

function module:Run()
	SetStartingProperties(self._object, self._startProperties)

	if self._debugTime then
		coroutine.wrap(function()
			local timeStart = tick()
			RunTween(self)
			while self._running 
				do RunService.Heartbeat:Wait()
			end
			warn("Tween lasted for: "..tostring(tick() - timeStart))
		end)()
	else
		RunTween(self)
	end

end

function module:RunAsync()
	SetStartingProperties(self._object, self._startProperties)
	RunTween(self)
	while self._running do 
		RunService.Heartbeat:Wait()
	end
end


return module
