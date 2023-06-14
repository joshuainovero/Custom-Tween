

local CustomTween = require(game:GetService("ReplicatedStorage").CustomTween)

local info = {
    {0,0},
    {0.9, 0.5},
    {1,1}
}

local Part1 = workspace.Part1
local Part2 = workspace.Part2

local tween = CustomTween.new(Part1, {CFrame = Part2.CFrame}, 4, info)

local function ended()
  print("Finished")
end

tween.Completed:Connect(ended)

task.wait(3)
tween:RunAsync()
print("This is now running")



-- task.wait(2)
-- print(getfenv(1))
--   local Signal = require(game.ReplicatedStorage.CustomTween.Signal)                                      
--   local sig = Signal.new()                                                 
--   local connection = sig:Connect(function()
--         print("HELLO SIGNAL")
--   end)
-- --   sig:Fire(arg1, arg2, ...)
-- while task.wait(3) do
--     sig:Fire()
-- end