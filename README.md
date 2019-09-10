# Tag

Wrapper around the concept of Tags that CollectionService uses.

CollectionService works purely off of strings, making it hard to keep track of
tags. It's common to create a table of constants and reference each tag that
way. This is a good approach, but when you need constants and inline checks your
conditions get unwieldy.

Each Tag instance has methods that wrap around the CollectionService API, so you
can quickly reference a tag and then perform operations with the context of the
tag, instead of having to pass in a constant to CollectionService.

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
