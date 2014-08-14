/'****************************************************************************
* inventory.bi
* Functions and declarations for the game inventory system.
* by Stephen Gatten
* Last update: August 13, 2014
*****************************************************************************'/

'Inventory type. This will be a composite data type to hold different data items
'utilizing type defs and a union. A union is a segment of memory that can hold
'different values, depending on what is put into the union.
type inventoryType
    classID as classIDs         'This indicates what class is in the union.
    desc as string * 30         'Plain text description.
    glyph as string * 1         'The item glyph.
    glyphColor as uinteger      'The item's glyph color.
    
    Union                       'Union of item types.
        gold as goldType        'Gold coins.
        supply as supplyType    'Supplies.
    end union
end type

'Item class IDs. This enumeration defines the different item class types that
'exist in the game.
enum classIDs
    iNone
    iGold
    iSupply
    iPotion
    iWand
    iWeapon
    iArmor
    iLight
    iAmmo
    iShield
    iScroll
    iSpellbook
end enum

'Gold item IDs. The only difference between Coin and Bag is the amount of gold
'held within. The no gold ID is important because it is used to reset the ID of
'the type.
enum goldIDs
    goldNone    'No gold.
    goldCoin    'Gold coins.
    goldBag     'Bag of gold.
end enum

'Effects IDs.
enum effectsIDs
    effectNone
    effectMaxHeal
    effectStrength
    effectCurePoison
    effectSeeAll
end enum

'Item use ID.
enum itemUse
    useNone
    useDrinkEat
    useEquip
end enum

'Supply item IDs.
enum supplyIDs
    supplyNone          'No supply ID.
    supplyGreenHerb     'Heals 50% max HP.
    supplyMeat          'Heals 25% max HP.
    supplyBread         'Heals 10% max HP.
end enum

    