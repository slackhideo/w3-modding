# The Witcher 3 Modding

Experiments with modding The Witcher 3.

### Display HUD Message

```
GetWitcherPlayer().DisplayHudMessage("My HUD message");
```

### Display Notification Message

```
theGame.GetGuiManager().ShowNotification("My notification message");
```

### Access Inventory (Class [CInventoryComponent](https://witcher-games.fandom.com/wiki/W3Class_CInventoryComponent))

```
var inventory : CInventoryComponent;
inventory = thePlayer.GetInventory();
```

### Access Stash (Class [CInventoryComponent](https://witcher-games.fandom.com/wiki/W3Class_CInventoryComponent))

```
var stash : CInventoryComponent;
stash = GetWitcherPlayer().GetHorseManager().GetInventoryComponent();
```

### Witcher Script Documentation

[https://witcherscript.readthedocs.io/en/latest/index.html](https://witcherscript.readthedocs.io/en/latest/index.html)

### Witcher 3 Modding Documentation

[https://witcher-games.fandom.com/wiki/Witcher_3_Modding](https://witcher-games.fandom.com/wiki/Witcher_3_Modding)

### Pitfalls

* In items definitions XML, `localisation_key_name` must begin with `item_name_`,
and `localisation_key_description` must begin with `item_desc_`.
* DLC folder name **must** be all lowercase.
* DLC folder **must** include a REDDLC file with paths.

### Notes

```
enum EUsableItemType
{
    UI_Torch,
    UI_Horn,
    UI_Bell,
    UI_OilLamp,
    UI_Mask,
    UI_FiendLure,
    UI_Meteor,
    UI_None,
    UI_Censer,
    UI_Apple,
    UI_Cookie,
    UI_Basket
}
```
