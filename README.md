# Tag

This class allows you to create a CollectionService tag and quickly add/remove
it on instances. It also allows you to enforce types for what each tag is
applied to.

```lua
local tags = {
	-- Using t, we enforce that a Character is a model.
	Character = Tag.new("Character", t.instanceOf("Model")),

    IsAlive = Tag.new("IsAlive"),
}

-- You can apply the Character tag to anything, even NPCs, and they will all be
-- handled here. This makes it easy to write code around different entities.
tags.Character:onAdded(function(character)
    print(character, "added")
end)

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        tags.Character:add(character)
        tags.IsAlive:add(character)

        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            tags.IsAlive:remove(character)
        end)
    end)
end)
```

Each Tag instance has methods that wrap around the CollectionService API, so you
can quickly reference a tag and then perform operations with the context of the
tag, instead of having to pass in a string constant to CollectionService.

## Constructors

**`Tag.new(name: string, instanceCheck?: function): Tag`**

Creates a new tag instance. The `name` is the exact tag name that will be used
by CollectionService. This is so level designers can easily parse the tags and
add them to instances in-game.

## Properties

**`Tag.name: string`**

The name supplied when constructing the tag.

**`Tag.instanceCheck: function | nil`**

Typically this will be a [t](https://github.com/osyrisrblx/t) typechecker.
Optional function that will be used to check if the instances that get passed
into methods of this class are correct.

## Methods

**`Tag:has(instance: Instance): boolean`**

Returns true if the tag is applied to the instance. False otherwise. Same as
CollectionService:HasTag().

**`Tag:add(instance: Instance): void`**

Adds the tag to the instance. Same as `CollectionService:AddTag()`.

**`Tag:remove(instance: Instance): void`**

Removes the tag from the instance. Same as `CollectionService:RemoveTag()`.

**`Tag:toggle(instance: Instance): void`**

Toggles the tag on the instance. If the tag is added, it will be removed, and
vice versa.

**`Tag:getInstances(): Instance[]`**

Gets all of the instances with this tag. Samne as `CollectionService:GetTagged()`.

**`onAdded(callback: function): RBXScriptConnection`**

Runs `callback` any time an instance is added with this tag. This is the same as
`GetInstanceAddedSignal`.

Also, this will catch up existing instances by running `callback` on all
instances that are already in the game with the tag.

Returns the connection to `GetInstanceAddedSignal`.

**`onRemoved(callback: function): RBXScriptConnection`**

Runs `callback` any time the tag is removed from an instance. This is the same
as `GetInstanceRemovedSignal`.

Returns the connection to `GetInstanceRemovedSignal`.
