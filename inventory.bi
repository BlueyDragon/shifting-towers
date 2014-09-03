/'****************************************************************************
* inventory.bi
* Functions and declarations for the game inventory system.
* by Stephen Gatten
* Last update: August 13, 2014
*****************************************************************************'/

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

'Gold item IDs and type definition. The only difference between Coin and Bag is 
'the amount of gold held within. The no gold ID is important because it is used
'to reset the ID of the type.
enum goldIDs
    goldNone    'No gold.
    goldCoin    'Gold coins.
    goldBag     'Bag of gold.
end enum

type goldType
    id as goldIDs       'Type of gold item.
    amount as integer   'Number of gold coins.
end type

'Supply item IDs and type definition.
enum supplyIDs
    supplyNone          'No supply ID.
    supplyGreenHerb     'Heals 50% max HP.
    supplyMeat          'Heals 25% max HP.
    supplyBread         'Heals 10% max HP.
end enum

type supplyType
    id as supplyIDs         'This indicates what type of supply item is in the type.
    idDR as integer         'Identify difficulty. Used to evaluate magical effects. 0 = non magic.
    ided as integer         'True if item has been identified.
    effect as effectsIDs    'The type of magical effect.
    sDesc as string * 30    'Secret name/description for magical items, revealed when successfully evaluated.
    noise as integer        'The amount of noise the item generates.
    use as itemUse          'How the item is used.
end type

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

'This helper function clears the inventory type instance, returning everything
'to an empty, default state. 
Sub clearInventory(inv As inventoryType)
   
    'If the classID is None, then no further action is needed.
    if inv.classID <> iNone then
        'Clear the GOLD type.
        if inv.classID = iGold then
            inv.gold.id = goldNone
            inv.gold.amount = 0
        endif
        
        'Clear the SUPPLY type.
        if inv.classID = iSupply then
            inv.supply.id = supplyNone
            inv.supply.idDR = 0
            inv.supply.ided = false
            inv.supply.effect = effectNone
            inv.supply.sDesc = ""
            inv.supply.noise = 0
            endif
            
        'Clear the common variables of the inventory item, such as the name,
        'description, class ID, glyph, and color.
        inv.desc = ""
        inv.classID = iNone
        inv.glyph = ""
        inv.glyphColor = cBlack
    endif
end sub

'This helper function returns true if the item in question is magical.
function itemIsMagic(currentLevel as integer) as integer
    dim as integer roll
    
    'Get a random number from 1 to 100.
    roll = randomRange(1, maxLevel * 2)
    
    'If the number matches or is less than the current level, the item is magic.
    if roll <= currentLevel then
        return true
    else
        return false
    endif
    
end function

'Generate new gold item.
sub generateGold(inv as inventoryType)
    dim as integer rng = randomRange(1,10)
    
    'Set the gold item ID.
    if rng = 1 then
        inv.gold.ID = goldBag
    else
        inv.gold.ID = goldCoin
    endif
    
    select case inv.gold.ID
    case goldCoin
        inv.desc = "Gold Coins"
        inv.gold.amount = randomRange(1,10)
        inv.glyph = Chr(147)
        inv.glyphColor = cGold
    case goldBag
        inv.desc = "Bag of Gold"
        inv.gold.amount = randomRange(10,100)
        inv.glyph = Chr(147)
        inv.glyphColor = cGold
    end select
end sub

'Generate new supply item.
sub generateSupply(inv as inventoryType, currentLevel as integer)
    dim item as supplyIDs = randomRange(supplyGreenHerb, supplyBread)
    dim as integer isMagic = itemIsMagic(currentLevel)
    
    'Set the supply item ID.
    inv.supply.id = item
    
    select case item
    case supplyGreenHerb
        inv.desc = "Green Herb"
        inv.supply.noise = 1
        inv.glyph = Chr(157)
        inv.glyphColor = cGreen
        inv.supply.ided = false
        inv.supply.use = useDrinkEat
        
        'Set the magic properties.
        if isMagic = true then
            inv.supply.idDR = randomRange(currentLevel, currentLevel * 2)
            inv.supply.effect = effectMaxHeal
            inv.supply.sDesc = "Magic Herb"
        else
            'Set the secret description to the main description.
            inv.supply.sDesc = inv.desc
        endif
        
    case supplyMeat
        inv.desc = "Hunk of Meat"
        inv.supply.noise = 1
        inv.glyph = Chr(224)
        inv.glyphColor = cSalmon
        inv.supply.ided = false
        inv.supply.use = useDrinkEat
        
        'Set the magic properties.
        if isMagic = true then
            inv.supply.idDR = randomRange(currentLevel, currentLevel * 2)
            inv.supply.effect = effectStrength
            inv.supply.sDesc = "Magic Meat"
        else
            'Set the secret description to the main description.
            inv.supply.sDesc = inv.desc
        endif
        
    case supplyBread
        inv.desc = "Loaf of Bread"
        inv.supply.noise = 1
        inv.glyph = Chr(247)
        inv.glyphColor = cHoneydew
        inv.supply.ided = false
        inv.supply.use = useDrinkEat
        
        'Set the magic properties.
        if isMagic = true then
            inv.supply.idDR = randomRange(currentLevel, currentLevel * 2)
            inv.supply.effect = effectCurePoison
            inv.supply.sDesc = "Magic Bread"
        else
            'Set the secret description to the main description.
            inv.supply.sDesc = inv.desc
        endif
    end select
end sub

'Generates a new item and places it into the inventory slot.
sub generateItem(inv as inventoryType, currentLevel as integer)
    dim itemClass as classIDs = randomRange(iGold, iSupply)
        
    'Clear current item if not cleared.
    if inv.classID <> iNone then
        clearInventory inv
    endif
        
    'Set the item class.
    inv.classID = itemClass
    
    'Generate item based on class ID.
    select case itemClass
    case iGold
        generateGold inv
    case iSupply
        generateSupply inv, currentLevel
    end select
end sub

'Returns the description for the item at the x,y coordinate.
function getInvItemDesc(inv as inventoryType) as string
    dim as string ret = "None"
    
    'If class ID is none then nothing to do.
    if inv.classID <> iNone then
        'Get the gold description.
        if inv.classID = iGold then
            ret = inv.desc
        endif
    endif
    
    'Get the supply description.
    if inv.classID = iSupply then
        'If not evaluated, then return main description.
        if inv.supply.ided = false then
            ret = inv.desc
        else
            'If evaluated, then return the true description.
            ret = inv.supply.sDesc
        endif
    endif
    
    return ret
end function

'Returns true if item has been evaluated.
function isIdentified(inv as inventoryType) as integer
    dim as integer ret
    
    'If nothing then mark as identified.
    if inv.classID = iNone then
        ret = true
    else
        'Select the item type.
        select case inv.classID
        case iGold
            ret = true
        case iSupply
            ret = inv.supply.ided
        end select
    endif
    
    return ret
end function

'Returns the item description for the item at the given X,Y coordinate.
function getInventoryItemDescription(inv as inventoryType) as string
    dim as string ret = "None"
    
    'If classID is none, then nothing to do.
    if inv.classID <> iNone then
        'Get the gold description.
        if inv.classID = iGold then
            ret = inv.desc
        endif
    endif
    
    'Get the supply description.
    if inv.classID = iSupply then
        'If not identified, then return main description.
        if inv.supply.ided = false then
            ret = inv.desc
        else
            'Return secret description
            ret = inv.supply.sDesc
        endif
    endif
    
    return ret
end function

'Returns the identify difficulty rating.
function getIdentifyDifficulty(inv as inventoryType) as integer
    dim as integer ret
    
    'If nothing then the difficulty is zero.
    if inv.classID = iNone then
        ret = 0
    else
        'Select the item.
        select case inv.classID
        case iGold
            ret = 0
        case iSupply
            ret = inv.supply.idDR
        end select
    endif
    
    return ret
end function
    
'Sets identified state to passed type.
sub setItemIdentified(inv as inventoryType, state as integer)
    'If nothing, then no identification.
    if inv.classID <> iNone then
        'Select the item.
        select case inv.classID
        case iSupply
            inv.supply.ided = state
        end select
    endif
end sub
