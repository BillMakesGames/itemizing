# Itemizing
An item and inventory system plugin for the Godot game engine.


## Installing
Download this repostory and place the contents directly in your root project folder. Once you have done so, navigate to Project Settings and enable the plugin under the "Plugins" tab, then restart your editor. Once you have it installed, you should go to the new Itemizing section at the top of your editor, and change the working directory to where you want your item data to be stored in your project.


## Creating Items
You can create new items by clicking the "New Item" button at the top on the itemizing screen. The dialogue that appears has the following options:

Property | Description
--- | --- 
Name | The name of the item to be displayed in various UI elements.
Description | A short description of the item that is displayed below the item's name in some places.
Max Stacks | How many of an item can fit in a single slot.
2D Icon | The texture to use to represent this item in 2D space.
Mesh | The mesh resource to use to represent this item in 3D space.
Save Path | The path to save the resource file after creation. This is filled out automatically based on the name and root folder specified for itemizing assets.
Script Base | If you want to use an inherited version of the ItemData script, you can select it here.

Once you have things set how you want, hit the create button to save the item resource to disk. You can still change the values at any time in the future using the item editor under the Itemizing panel.

### Adding Functionality
You can add functionality to items by creating a new script that inherits from the ItemData class, and then overriding the on_use function to do what you want. Here is an example:
```python
extends ItemData

@export var heal_amount:int

func on_use(source_inventory:Inventory) -> bool :
	var parent = source_inventory.get_parent()
	if parent is ItemExamplePlayer :
		parent.adjust_health(heal_amount)
		return true
	else :
		return false
```
The return value of the on-use function determines if the item should be removed or not after being used. Extra exported properties (such as `heal_amount` in the above example) will automatically be added to the item editor.


## UI Elements
There are currently two custom UI elements you can use to display items:

#### ItemPanel
A panel that displays either the 2D or 3D representation of a given ItemData. You can change the display mode (2D or 3D) within it's properties, as well as set it's default item to display. You can also change the item it shows via code by changing the `current_item` property.

#### ItemSlotGrid
A panel that display the contents of an `Inventory` in a standard slot grid formation. The property `linked_inventory` can be set in the editor or via code to change the inventory being displayed.


## Example Templates
There are a few example template scenes located in the `addons/itemizing/template_scenes/` folder you can use as a starter point for your project. `3D_item_pickup` shows an item in 3D space and adds itself to a inventory when being touched by a body with an inventory child node.
