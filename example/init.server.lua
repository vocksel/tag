local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage.Packages.t)
local Tag = require(ReplicatedStorage.Packages.Tag)

local tags = {
	Character = Tag.new("Character", t.instanceOf("Model")),
	IsAlive = Tag.new("IsAlive", t.instanceOf("Model")),
}

tags.Character:onAdded(function(character)
	print("Character added:", character:GetFullName())
end)

tags.IsAlive:onAdded(function(character)
	print("IsAlive added to", character)
end)

tags.IsAlive:onRemoved(function(character)
	print("IsAlive removed from", character)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		tags.Character:add(character)
		tags.IsAlive:add(character)

		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			tags.IsAlive:remove(character)
		end)
	end)
end)
