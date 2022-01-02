return function()
	local CollectionService = game:GetService("CollectionService")

	local t = require(script.Parent.Parent.t)
	local Tag = require(script.Parent)

	describe("new()", function()
		it("should create a new Tag instance", function()
			local tag = Tag.new("Foo")

			expect(tag).to.be.a("table")
			expect(tag.name).to.equal("Foo")
		end)

		it("should return the name when coercing into a string", function()
			local tag = Tag.new("Foo")

			expect(tostring(tag)).to.equal("Foo")
		end)

		-- Skipping this idea for the time being. Nesting tags in this way seems
		-- like an anti-pattern at first glance,

		-- it("should allow nesting tags inside of it", function()
		-- 	local tag = Tag.new("Foo", {
		-- 		Bar = Tag.new("Foo:Bar"),
		-- 		Baz = Tag.new("Foo:Baz")
		-- 	})
		--
		-- 	expect(tag.Bar).to.be.ok()
		-- 	expect(tag.Baz).to.be.ok()
		-- end)
	end)

	describe("add()", function()
		it("should add the tag to an instance", function()
			local instance = Instance.new("Model")

			local tag = Tag.new("Foo")
			tag:add(instance)

			expect(CollectionService:HasTag(instance, "Foo")).to.equal(true)
		end)

		it("should error when given an incorrect instance", function()
			local tag = Tag.new("Foo", t.instanceOf("Model"))
			local part = Instance.new("Part")

			expect(function()
				tag:add(part)
			end).to.throw()
		end)
	end)

	describe("remove()", function()
		it("should remove the tag from an instance", function()
			local instance = Instance.new("Model")

			local tag = Tag.new("Foo")
			tag:add(instance)

			expect(CollectionService:HasTag(instance, "Foo")).to.equal(true)

			tag:remove(instance)

			expect(CollectionService:HasTag(instance, "Foo")).to.equal(false)
		end)
	end)

	describe("toggle()", function()
		it("should add the tag if it's not already applied", function()
			local instance = Instance.new("Model")
			local tag = Tag.new("Foo")

			expect(tag:has(instance)).to.equal(false)

			tag:toggle(instance)

			expect(tag:has(instance)).to.equal(true)
		end)

		it("should remove the tag if it's already applied", function()
			local instance = Instance.new("Model")
			local tag = Tag.new("Foo")

			tag:add(instance)

			expect(tag:has(instance)).to.equal(true)

			tag:toggle(instance)

			expect(tag:has(instance)).to.equal(false)
		end)

		it("should error when given an incorrect instance", function()
			local tag = Tag.new("Foo", t.instanceOf("Model"))
			local part = Instance.new("Part")

			expect(function()
				tag:toggle(part)
			end).to.throw()
		end)
	end)

	describe("has()", function()
		it("should return true if the tag is applied", function()
			local instance = Instance.new("Model")

			local tag = Tag.new("Foo")
			tag:add(instance)

			expect(tag:has(instance)).to.equal(true)
		end)

		it("should return false if the tag is not applied", function()
			local instance = Instance.new("Model")

			local tag = Tag.new("Foo")

			expect(tag:has(instance)).to.equal(false)
		end)
	end)

	describe("getTagged()", function()
		it("should get all the instances the tag is applied to", function()
			local tag = Tag.new("Foo")
			local instances = {}

			for _ = 1, 3 do
				local instance = Instance.new("Model")
				tag:add(instance)

				-- Need to parent to the DataModel for GetTagged to pick them up.
				instance.Parent = game

				table.insert(instances, instance)
			end

			expect(#tag:getTagged()).to.equal(3)

			for _, instance in ipairs(instances) do
				instance:Destroy()
			end
		end)
	end)

	describe("onAdded()", function()
		it("should run the callback on all existing tagged instances", function()
			local tag = Tag.new("Foo")
			local instance = Instance.new("Model")
			local wasAdded = false

			instance.Parent = game

			-- Add tag before listening
			tag:add(instance)

			local connection = tag:onAdded(function(other)
				wasAdded = instance == other
			end)

			expect(wasAdded).to.equal(true)

			connection:Disconnect()
			instance:Destroy()
		end)

		it("should run when an instance is tagged", function()
			local instance = Instance.new("Model")
			local tag = Tag.new("Foo")
			local wasAdded = false

			instance.Parent = game

			local connection = tag:onAdded(function(other)
				wasAdded = instance == other
			end)

			-- Add tag after listening
			tag:add(instance)

			expect(wasAdded).to.equal(true)

			connection:Disconnect()
			instance:Destroy()
		end)

		it("should error when an existing instance with the tag doesn't check", function()
			local tag = Tag.new("Foo", t.instanceOf("Model"))

			local part = Instance.new("Part")
			CollectionService:AddTag(part, "Foo")

			part.Parent = game

			expect(function()
				tag:onAdded(function() end)
			end).to.throw()

			part:Destroy()
		end)

		-- This is hard to test because we're dealing with an event. It would
		-- require mocking out _onAddedSignal so we could examine it, which is
		-- quite a bit of effort. For now we're relying on manual testing to
		-- make sure it works.
		itSKIP("should error when an instance added with the tag doesn't check", function() end)
	end)

	describe("onRemoved()", function()
		it("should run when the tag is removed from an instance", function()
			local instance = Instance.new("Model")
			local tag = Tag.new("Foo")
			local wasRemoved = false

			instance.Parent = game
			tag:add(instance)

			local connection = tag:onRemoved(function(other)
				wasRemoved = instance == other
			end)

			tag:remove(instance)

			expect(wasRemoved).to.equal(true)

			connection:Disconnect()
			instance:Destroy()
		end)

		it("should run when an instance is removed", function()
			local instance = Instance.new("Model")
			local tag = Tag.new("Foo")
			local wasRemoved = false

			tag:add(instance)

			instance.Parent = game

			local connection = tag:onRemoved(function(other)
				wasRemoved = instance == other
			end)

			instance:Destroy()

			expect(wasRemoved).to.equal(true)

			connection:Disconnect()
		end)
	end)
end
