/*
Merge: Primer [1] + What's For Dinner [2] (included in Primal Needs [3])
[1] https://www.nexusmods.com/witcher3/mods/1318
[2] https://www.nexusmods.com/witcher3/mods/488
[3] https://www.nexusmods.com/witcher3/mods/2547
*/
/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3AlchemyManager
{
	private var recipes : array<SAlchemyRecipe>;
	private var isPlayerMounted  : bool;
	private var isPlayerInCombat : bool;
	private var alchemyext : AlchemyExtensions; //modPrimer


	public function Init(optional alchemyRecipes : array<name>)
	{	alchemyext = GetWitcherPlayer().al_extensions; //modPrimer
		if(alchemyRecipes.Size() > 0)
		{
			LoadRecipesCustomXMLData( alchemyRecipes );
		}
		else
		{
			LoadRecipesCustomXMLData( GetWitcherPlayer().GetAlchemyRecipes() );
		}

		isPlayerMounted = thePlayer.GetUsedVehicle();
		isPlayerInCombat = thePlayer.IsInCombat();
	}


	public function GetRecipe(recipeName : name, out ret : SAlchemyRecipe) : bool
	{
		var i : int;

		for(i=0; i<recipes.Size(); i+=1)
		{
			if(recipes[i].recipeName == recipeName)
			{
				ret = recipes[i];
				return true;
			}
		}

		return false;
	}

	//modPrimer
	public function modRecipe (recipe : SAlchemyRecipe) : void
	{	var i, j, ingredient_quantity : int;

		for (i = recipes.Size() - 1; i >= 0; i -= 1)
		{	if (recipes[i].recipeName != recipe.recipeName)
				continue ;
			recipes[i] = recipe;
			break;
		}
	}//modPrimer


	private function LoadRecipesCustomXMLData(recipesNames : array<name>)
	{
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var tmpBool : bool;
		var tmpName : name;
		var tmpString : string;
		var tmpInt : int;
		var ingredient_count : int = -1; //modPrimer
		var primary_substance_index : int = -1; //modPrimer
		var mutagen_index : int = -1; //modPrimer
		var rec : SAlchemyRecipe;
		var i, k, readRecipes : int;
		var ing : SItemParts;

		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('alchemy_recipes');
		readRecipes = 0;

		for(i=0; i<main.subNodes.Size(); i+=1)
		{

			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName) && IsNameValid(tmpName) && recipesNames.Contains(tmpName))
			{
				rec.recipeName = tmpName;

				if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', tmpName))
					rec.cookedItemName = tmpName;
				else
					rec.cookedItemName = '';

				if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
					rec.typeName = tmpName;
				else
					rec.typeName = '';

				if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
					rec.level = tmpInt;
				else
					rec.level = -1;

				if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'cookedItemType', tmpString)) //modPrimer
				{	rec.cookedItemType = AlchemyCookedItemTypeStringToEnum(tmpString);
					switch(rec.cookedItemType)
					{	case EACIT_MutagenPotion:
						case EACIT_Potion:
						case EACIT_Oil:
						case EACIT_Bomb:
							if (rec.level > 1)
								continue ;
					}
				}
				else
					rec.cookedItemType = EACIT_Undefined;

				if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'cookedItemQuantity', tmpInt))
					rec.cookedItemQuantity = tmpInt;
				else
					rec.cookedItemQuantity = -1;

				//modPrimer
				if (rec.recipeName == 'Recipe for Albedo' || rec.recipeName == 'Recipe for Rubedo' || rec.recipeName == 'Recipe for Nigredo')
					continue;
				ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');
				rec.requiredIngredients.Clear();
				ingredient_count = ingredients.subNodes.Size() - 1;

				if (alchemyext.mod_primary_substances)
				{	for (primary_substance_index = alchemyext.primary_substances.Size() - 1; primary_substance_index >= 0; primary_substance_index -= 1)
					{	if (alchemyext.primary_substances[primary_substance_index].recipeName == rec.recipeName)
						{	ingredient_count = alchemyext.primary_substances[primary_substance_index].requiredIngredients.Size() - 1;
							break;
						}
					}
				}
				if (alchemyext.mod_mutagens)
				{	for (mutagen_index = alchemyext.mutagens.Size() - 1; mutagen_index >= 0; mutagen_index -= 1)
					{	if (alchemyext.mutagens[mutagen_index].recipeName == rec.recipeName)
						{	ingredient_count = alchemyext.mutagens[mutagen_index].requiredIngredients.Size() - 1;
							break;
						}
					}
				}
				for(k = ingredient_count; k >= 0; k -= 1)
				{
					if (mutagen_index < 0 && primary_substance_index < 0)
					{	if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))
							ing.itemName = tmpName;
						else
							ing.itemName = '';

						if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
							ing.quantity = tmpInt;
						else
							ing.quantity = -1;
					}
					else if (primary_substance_index > -1)
					{	ing.itemName = alchemyext.primary_substances[primary_substance_index].requiredIngredients[k].itemName;
						ing.quantity = alchemyext.primary_substances[primary_substance_index].requiredIngredients[k].quantity;
					}
					else if (mutagen_index > -1)
					{	ing.itemName = alchemyext.mutagens[mutagen_index].requiredIngredients[k].itemName;
						ing.quantity = alchemyext.mutagens[mutagen_index].requiredIngredients[k].quantity;
					}
					else
						continue;

					rec.requiredIngredients.PushBack(ing);
				} //modPrimer



				rec.cookedItemIconPath			= dm.GetItemIconPath( rec.cookedItemName );


				rec.recipeIconPath				= dm.GetItemIconPath( rec.recipeName );

				recipes.PushBack(rec);


				readRecipes += 1;
				if(readRecipes >= recipesNames.Size())
					break;
			}
		}
	}

	private final function GetItemNameWithoutLevelAsString(itemName : name) : string
	{
		var itemStr : string;

		itemStr = NameToString(itemName);
		if(StrEndsWith(itemStr, " 1") || StrEndsWith(itemStr, " 2") || StrEndsWith(itemStr, " 3"))
			return StrLeft(itemStr, StrLen(itemStr)-2);

		return itemStr;
	}

	private var lacks_firesrc : bool;
	public function CanCookRecipe(recipeName : name, optional skip_fire_checks : bool) : EAlchemyExceptions //modPrimer []
	{
		var i, j, quantity : int;
		var recipe : SAlchemyRecipe;
		var itemName : name;
		var duplicates_quantity : array<int>;

		if(!GetRecipe(recipeName, recipe) )
			return EAE_NoRecipe;
		if (alchemyext.GetIsAmmoMaxed(recipe) )
			return EAE_CannotCookMore;
		lacks_firesrc = lacks_firesrc && skip_fire_checks;
		if (alchemyext.fire_source_type && thePlayer.GetCurrentStateName() != 'PlayerDialogScene' &&
		(lacks_firesrc || !alchemyext.GetNearbyFireSource() ) )
		{	lacks_firesrc == true;
			return EAE_CookNotAllowed;
		}
		duplicates_quantity.Resize(recipe.requiredIngredients.Size() );
		for (i = recipe.requiredIngredients.Size() - 1; i >= 0; i-= 1)
		{	for (j = i; j >= 0; j -= 1)
			{	if (recipe.requiredIngredients[i].itemName == recipe.requiredIngredients[j].itemName)
					duplicates_quantity[i] += recipe.requiredIngredients[j].quantity;
			}
		}
		for(i=0; i<recipe.requiredIngredients.Size(); i+=1)
		{	quantity = thePlayer.inv.GetItemQuantityByName(recipe.requiredIngredients[i].itemName);
			if (quantity < recipe.requiredIngredients[i].quantity || quantity < duplicates_quantity[i])
				return (EAE_NotEnoughIngredients);
		}
		return (EAE_NoException);
	}

	public function CookItem(ryanalchemymenu : name) : string {return "";} //Unused but required for compilation.
	public function create(optional recipe : SAlchemyRecipe, optional unused : name) : string //modPrimer [
	{
		var i, j, quantity, ing_quantity, removed, bottles : int;
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var min, max : SAbilityAttributeValue;
		var uiStateAlchemy : W3TutorialManagerUIHandlerStateAlchemy;
		var uiStateAlchemyMutagens : W3TutorialManagerUIHandlerStateAlchemyMutagens;
		var ids : array<SItemUniqueId>;
		var items, ingredients  : array<SItemUniqueId>;
		var isPotion, is_distilling : bool;
		var player : W3PlayerWitcher;
		var equippedOnSlot : EEquipmentSlots;
		var cook_bonus : string = ProcessSideEffects();
		var ingredient : name;
		var isIngredientUniqueMutagen : bool;
		var isDecoctionRecipe : bool;

		player = GetWitcherPlayer();
		quantity = alchemyext.cooked_quantity;
		switch(recipe.cookedItemType)
		{	case EACIT_Bomb:
				quantity += player.GetSkillLevel(S_Alchemy_s08);
			break ;
			case EACIT_Substance:
				is_distilling = alchemyext.GetIsDistillingPrimarySubstance(recipe.recipeName);
				if (is_distilling)
					quantity += CalculateDistillationYield();
			break ;
			case EACIT_Potion:
			case EACIT_Alcohol:
			case EACIT_MutagenPotion:
			case EACIT_Oil:
			break ;
			default:
				dm.GetItemAttributeValueNoRandom(recipe.cookedItemName, true, 'ammo', min, max);
				//WhatsForDinner
				//quantity = (int)CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				quantity = recipe.cookedItemQuantity;
				//WhatsForDinner
				cook_bonus = "";
			break ;
		}
		if (alchemyext.time_based_alchemy && thePlayer.GetCurrentStateName() == 'AlchemyBrewing')
			((W3PlayerWitcherStateAlchemyBrewing)thePlayer.GetCurrentState() ).addBrewTime((alchemyext.distillation_time *
				(int)is_distilling + (int)!is_distilling * alchemyext.alchemy_time_cost) );
		for (i = recipe.requiredIngredients.Size() - 1; i >= 0 ; i -= 1)
		{	ingredient = recipe.requiredIngredients[i].itemName;
			if(!dm.ItemHasTag(ingredient, theGame.params.TAG_ITEM_SINGLETON) )
			{	if (StrFindFirst(NameToString(recipe.cookedItemName), "White Gull") > -1 &&
					(ingredient == 'Alcohest' || ingredient == 'White Gull 1') )
						recipe.requiredIngredients[i].quantity *= (alchemyext.alcohol_uses + (int)(ingredient != 'Alcohest') );
				ing_quantity = alchemyext.GetIngredientUsage(ingredient, recipe.requiredIngredients[i].quantity);
				if (ingredient == 'Soltis Vodka' || !ing_quantity)
					continue;
				player.inv.RemoveItemByName(ingredient, ing_quantity);
				bottles += ((int)alchemyext.ingr_manager.IsSpirit(ingredient)  * ing_quantity);
			}
			else
			{	ing_quantity = recipe.requiredIngredients[i].quantity;
				ingredients = player.inv.GetItemsByName(ingredient);
				//WhatsForDinner
				//for (i = 0; i < ingredients.Size(); i += 1)
				for(i = 0; i < ing_quantity; i += 1)
				//WhatsForDinner
				{	player.inv.SingletonItemRemoveAmmo(ingredients[i], ing_quantity);
					if (!player.inv.GetItemModifierInt(ingredients[i], 'ammo_current') )
					{	if (player.GetItemSlot(ingredients[i]) != EES_InvalidSlot)
							player.UnequipItem(ingredients[i]);
						//WhatsForDinner
						//player.inv.RemoveItem(ingredients[i]);
						thePlayer.inv.RemoveItemByName(ingredient, 1);
						//WhatsForDinner
					}
				}
			}
		}
		if ((bottles || is_distilling) && alchemyext.bottle_recycling)
			thePlayer.inv.AddAnItem('Empty bottle', bottles + (int)is_distilling);
		if(dm.IsItemSingletonItem(recipe.cookedItemName) )
		{	items = thePlayer.inv.GetItemsByName(recipe.cookedItemName);
			if (items.Size() == 1 && thePlayer.inv.ItemHasTag(items[0], 'NoShow'))
				thePlayer.inv.RemoveItemTag(items[i], 'NoShow');
			ids = thePlayer.inv.GetItemsIds(recipe.cookedItemName);
			if (!ids.Size() )
				ids = thePlayer.inv.AddAnItem(recipe.cookedItemName, quantity);
			else
				quantity += thePlayer.inv.SingletonItemGetAmmo(ids[0]);
			for(i=0; i<ids.Size(); i+=1)
				thePlayer.inv.SetItemModifierInt(ids[i],'ammo_current', quantity);
			theGame.GetGlobalEventsManager().OnScriptedEvent(SEC_OnAmmoChanged);
		}
		else
			ids = thePlayer.inv.AddAnItem(recipe.cookedItemName, quantity);
		isPotion = (thePlayer.inv.IsItemPotion(ids[0]) || (items.Size() && thePlayer.inv.IsItemPotion(items[0]) ) );
		theTelemetry.LogWithLabelAndValue( TE_ITEM_COOKED, recipe.cookedItemName, (int)isPotion);
		//LogAlchemy("Item <<" + recipe.cookedItemName + ">> cooked x" + recipe.cookedItemQuantity);
		return cook_bonus;
	}//modPrimer ]

	//modPrimer [
	private function CalculateDistillationYield () : int //this added to the base global yield set in the options, so at least 1 + this.
	{
		var yield : float;

		yield = RandRangeF(1.4f, 0.f) * alchemyext.min_primary_ingredients / 1.618f;
		return ((int)(yield + 0.5f) ); //simple rounding
	}

	private function ProcessSideEffects () : string
	{	var mutagen_index	: int;
		var mutagen			: name;

		mutagen_index = RandRange(4, 1) * (int)(RandRange(100, 1) <= GetWitcherPlayer().GetSkillLevel(S_Alchemy_s04) * 10);
		switch(mutagen_index)
		{	case 1:
				mutagen = 'Lesser mutagen red';
			break;
			case 2:
				mutagen = 'Lesser mutagen green';
			break;
			case 3:
				mutagen = 'Lesser mutagen blue';
			break;
			default:
				return ("");
		}
		thePlayer.inv.AddAnItem(mutagen, 1);
		return (NameToString(mutagen) );
	}
	//modPrimer ]

	public function GetRecipes(forceAll : bool) : array<SAlchemyRecipe>
	{
		return (recipes);
	}

	public function GetRequiredIngredients(recipeName : name) : array<SItemParts>
	{
		var rec : SAlchemyRecipe;
		var null : array<SItemParts>;

		if(GetRecipe(recipeName, rec))
			return rec.requiredIngredients;

		return null;
	}
}

function getAlchemyRecipeFromName(recipeName : name):SAlchemyRecipe
{
	var dm : CDefinitionsManagerAccessor;
	var main, ingredients : SCustomNode;
	var tmpBool : bool;
	var tmpName : name;
	var tmpString : string;
	var tmpInt : int;
	var ing : SItemParts;
	var i,k : int;
	var rec : SAlchemyRecipe;

	dm = theGame.GetDefinitionsManager();
	main = dm.GetCustomDefinition('alchemy_recipes');

	for(i=0; i<main.subNodes.Size(); i+=1)
	{
		dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);

		if (tmpName == recipeName)
		{
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'cookedItem_name', tmpName))
				rec.cookedItemName = tmpName;
			if(dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'type_name', tmpName))
				rec.typeName = tmpName;
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', tmpInt))
				rec.level = tmpInt;
			if(dm.GetCustomNodeAttributeValueString(main.subNodes[i], 'cookedItemType', tmpString))
				rec.cookedItemType = AlchemyCookedItemTypeStringToEnum(tmpString);
			if(dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'cookedItemQuantity', tmpInt))
				rec.cookedItemQuantity = tmpInt;


			ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');
			for(k=0; k<ingredients.subNodes.Size(); k+=1)
			{
				ing.itemName = '';
				ing.quantity = -1;

				if(dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName))
					ing.itemName = tmpName;
				if(dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt))
					ing.quantity = tmpInt;

				rec.requiredIngredients.PushBack(ing);
			}

			rec.recipeName = recipeName;


			rec.cookedItemIconPath			= dm.GetItemIconPath( rec.cookedItemName );
			rec.recipeIconPath				= dm.GetItemIconPath( rec.recipeName );
			break;
		}
	}

	return rec;
}
