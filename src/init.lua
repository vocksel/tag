local CollectionService = game:GetService("CollectionService")

local t = require(script.Parent.t)

local Tag = {}
Tag.__index = Tag

local newCheck = t.tuple(
	t.string,
	t.optional(t.callback) -- This can be a t typechecker
)
function Tag.new(name: string, instanceCheck: (Instance) -> boolean)
	assert(newCheck(name, instanceCheck))

	local self = {}

	self.name = name
	self.instanceCheck = instanceCheck
	self._onAddedSignal = CollectionService:GetInstanceAddedSignal(name)
	self._onRemovedSignal = CollectionService:GetInstanceRemovedSignal(name)

	return setmetatable(self, Tag)
end

function Tag:__tostring()
	return self.name
end

function Tag:_maybeCheck(instance: Instance)
	if self.instanceCheck then
		assert(self.instanceCheck(instance))
	end
end

function Tag:has(instance: Instance)
	return CollectionService:HasTag(instance, self.name)
end

function Tag:add(instance: Instance)
	self:_maybeCheck(instance)

	CollectionService:AddTag(instance, self.name)
end

function Tag:remove(instance: Instance)
	return CollectionService:RemoveTag(instance, self.name)
end

function Tag:toggle(instance: Instance)
	if self:has(instance) then
		self:remove(instance)
	else
		self:add(instance)
	end
end

function Tag:getTagged()
	return CollectionService:GetTagged(self.name)
end

function Tag:onAdded(callback: (Instance) -> nil): RBXScriptConnection
	assert(t.callback(callback))

	local function onAdded(instance)
		self:_maybeCheck(instance)

		callback(instance)
	end

	local onInstanceAddedConn = self._onAddedSignal:Connect(onAdded)

	for _, instance in ipairs(CollectionService:GetTagged(self.name)) do
		self:_maybeCheck(instance)
		coroutine.wrap(onAdded)(instance)
	end

	return onInstanceAddedConn
end

function Tag:onRemoved(callback: (Instance) -> nil): RBXScriptConnection
	assert(t.callback(callback))

	return self._onRemovedSignal:Connect(callback)
end

return Tag
