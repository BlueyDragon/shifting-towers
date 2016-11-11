/'****************************************************************************
* inventory.bi
* Functions and declarations for the game inventory system.
* by Stephen Gatten
* Last update: November 8, 2016
*****************************************************************************'/

'Item class IDs. This enumeration defines the different item class types that
'exist in the game.
enum classIDs
    iNone
    iGold
    iSupply
    iArmor
    iShield
    iPotion
    iWand
    iWeapon
    iLight
    iAmmo
    iScroll
    iSpellbook
end enum

'Equipment slots in character inventory.
enum equipSlots
    slotNone
    slotMain
    slotOffhand
    slotArmor
    slotNeck
    slotRingR
    slotRingL
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

'Armor item IDs and type definition.
enum armorIDs
    armorNone
    armorCloth          'Cloth Tunic (1% resistance)
    armorLeather        'Leather Tunic (5% resistance)
end enum

type armorType
    id as armorIDs
    idDR as integer
    ided as integer
    effect as integer
    sDesc as string * 30
    noise as integer
    use as itemUse
    resist as single
    enRequired as integer
    slot(1 to 2) as equipSlots
end type

'Shield item IDs and type definition.
enum shieldIDs
    shieldNone
    shieldBuckler
    shieldLeather
end enum

type shieldType
    id as shieldIDs
    idDR as integer
    ided as integer
    effect as integer
    sDesc as string * 30
    noise as integer
    use as itemUse
    resist as single
    enRequired as integer
    slot(1 to 2) as equipSlots
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
        supply as supplyType    'Supplies, tools, consumables.
        armor as armorType      'Armor.
        shield as shieldType    'Shields.
    end union
end type

'This helper function clears the inventory type instance, returning everything
'to an empty, default state. 
Sub clearInventory(inv As inventoryType)
   
    'If the classID is None, then no further action is needed.
    if inv.classID <> iNone then
        select case inv.classID
        case iGold
            inv.gold.id = goldNone
            inv.gold.amount = 0
        
        case iSupply
            inv.supply.id = supplyNone
            inv.supply.idDR = 0
            inv.supply.ided = false
            inv.supply.effect = effectNone
            inv.supply.sDesc = ""
            inv.supply.noise = 0
        
        case iArmor
            inv.armor.id = armorNone
            inv.armor.idDR = 0
            inv.armor.ided = FALSE
            inv.armor.effect = 0
            inv.armor.sDesc = ""
            inv.armor.noise = 0
            inv.armor.use = useNone
            inv.armor.resist = 0
            inv.armor.enRequired = 0
            inv.armor.slot(1) = slotNone
            inv.armor.slot(2) = slotNone
        
        case iShield
            inv.shield.id = shieldNone
            inv.shield.idDR = 0
            inv.shield.ided = FALSE
            inv.shield.effect = 0
            inv.shield.sDesc = ""
            inv.shield.noise = 0
            inv.shield.use = useNone
            inv.shield.resist = 0
            inv.shield.enRequired = 0
            inv.shield.slot(1) = slotNone
            inv.shield.slot(2) = slotNone
    
        end select
                        
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

'GENERATE ARMOR creates a new armor item.
sub generateArmor(inv as inventoryType, currentLevel as integer, id as armorIDs = armorNone)
    dim item as armorIDs
    dim as integer isMagic = itemIsMagic(currentLevel)
    
    'Common items
    if id = armorNone then
        item = randomRange(armorCloth, armorLeather)
        inv.armor.id = item
    else
        item = id
        inv.armor.id = id
    endif
    
    'Set the armor type and amount.
    select case item
    case armorCloth
        inv.desc = "Cloth Tunic"
        inv.armor.noise = 1
        inv.armor.resist = .01
        inv.armor.enRequired = 10
    case armorLeather
        inv.desc = "Leather Tunic"
        inv.armor.noise = 5
        inv.armor.resist = .05
        inv.armor.enRequired = 25
    end select
    
    inv.glyph = Chr(234)
    inv.glyphColor = cEmeraldGreen
    inv.armor.use = useEquip
    inv.armor.ided = FALSE
    inv.armor.slot(1) = slotArmor
    inv.armor.sDesc = inv.desc
    
    'Magic items
    if isMagic = TRUE then
        inv.armor.idDR = randomRange(currentLevel, currentLevel * 2)
        inv.armor.effect = 0
        inv.armor.sDesc = "Magic " & inv.desc
    endif
    
end sub

'GENERATE SHIELD creates a new shield item.
sub generateShield(inv as inventoryType, currentLevel as integer, id as shieldIDs = shieldNone)
    dim item as shieldIDs
    dim as integer isMagic = itemIsMagic(currentLevel)
    
    'Common items
    if id = shieldNone then
        item = randomRange(shieldBuckler, shieldLeather)
        inv.shield.id = item
    else
        item = id
        inv.shield.id = id
    endif
    
    'Set the armor type and amount.
    select case item
    case shieldBuckler
        inv.desc = "Buckler"
        inv.shield.noise = 1
        inv.shield.resist = .05
        inv.shield.enRequired = 10
    case armorLeather
        inv.desc = "Leather Shield"
        inv.shield.noise = 5
        inv.shield.resist = .10
        inv.shield.enRequired = 25
    end select
    
    inv.glyph = Chr(234)
    inv.glyphColor = cEmeraldGreen
    inv.shield.use = useEquip
    inv.shield.ided = FALSE
    inv.shield.slot(1) = slotOffhand
    inv.shield.sDesc = inv.desc
    
    'Magic items
    if isMagic = TRUE then
        inv.shield.idDR = randomRange(currentLevel, currentLevel * 2)
        inv.shield.effect = 0
        inv.shield.sDesc = "Magic " & inv.desc
    endif
    
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
    case iGold: generateGold inv
    case iSupply: generateSupply inv, currentLevel
    case iArmor: generateArmor inv, currentLevel
    case iShield: generateShield inv, currentLevel
    end select
end sub

'Returns true if item has been evaluated.
function isIdentified(inv as inventoryType) as integer
    dim as integer ret
    
    select case inv.classID
    case iNone: ret = TRUE              'Null item
    case iGold: ret = TRUE              'Gold always identified
    case iSupply: ret = inv.supply.ided
    case iArmor: ret = inv.armor.ided
    case iShield: ret = inv.shield.ided
    end select
    
    return ret
end function

'GET INVENTORY ITEM DESCRIPTION returns the item description for the given item.
function getInventoryItemDescription(inv as inventoryType) as string
    dim as string ret = "None"
    
    'If classID is none, then nothing to do.
    if inv.classID <> iNone then
        select case inv.classID
        case iGold
            ret = inv.desc
        case iSupply
            if inv.supply.ided = FALSE then
                ret = inv.desc
            else
                ret = inv.supply.sDesc
            endif
        case iArmor
            if inv.armor.ided = FALSE then
                ret = inv.desc
            else
                ret = inv.armor.sDesc
            endif
        case iShield
            if inv.shield.ided = FALSE then
                ret = inv.desc
            else
                ret = inv.shield.sDesc
            endif
        end select
    endif
    
    return ret
end function

'Returns the identify difficulty rating.
function getIdentifyDifficulty(inv as inventoryType) as integer
    dim as integer ret
    
    select case inv.classID
    case iNone: ret = 0                     'Null item: difficulty zero
    case iGold: ret = 0                     'Gold always identified: zero
    case iSupply: ret = inv.supply.idDR
    case iArmor: ret = inv.armor.idDR
    case iShield: ret = inv.shield.idDR
    end select
    
    return ret
end function

'GET INVENTORY E SLOT returns an integer describing the slot where an equippable
'item can be placed, such as weapon hand, armor, neck, etc.
function getInventoryESlot(inv as inventoryType, slotNumber as integer) as integer
    dim as integer ret = slotNone
    
    if inv.classID = iArmor then
        if slotNumber >= lbound(inv.armor.slot) and slotNumber <= ubound(inv.armor.slot) then
            ret = inv.armor.slot(slotNumber)
        endif
    elseif inv.classID = iShield then
        if slotNumber >= lbound(inv.shield.slot) and slotNumber <= ubound(inv.shield.slot) then
            ret = inv.shield.slot(slotNumber)
        endif
    endif
    
    return ret
end function
    
function matchUse(inv as inventoryType, whatUse as itemUse) as integer
    dim as integer ret = FALSE
    
    'If nothing, then no use.
    if inv.classID <> iNone then
        select case inv.classID
        case iSupply
            if inv.supply.use = whatUse then
                ret = TRUE
            endif
        case iArmor
            if inv.armor.use = whatUse then
                ret = TRUE
            endif
        case iShield
            if inv.shield.use = whatUse then
                ret = TRUE
            endif
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
        case iArmor
            inv.armor.ided = state
        case iShield
            inv.shield.ided = state
        end select
    endif
end sub

'Returns an extended description of the item.
sub getFullDescription(lines() as string, inv as inventoryType)
    dim as integer index = 0
    
    'Reset the array.
    redim lines(0 to index) as string
    
    'Make sure we have something to describe.
    if inv.classID <> iNone then
        'Select the item.
        select case inv.classID
        case iSupply
            select case inv.supply.id
            case supplyGreenHerb
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "A small mint plant common in Aluran medicine."
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* Heals critical wounds"
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* Magic: Max Healing"
            case supplyMeat
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "A chop of red meat."
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* Heals moderate wounds"
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* Magic: Ferrum Bestia"
            case supplyBread
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "A loaf of flaky Aluran bread."
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* Heals slight wounds"
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* Magic: Cure Poison"
            end select
        case iArmor
            select case inv.armor.id
            case armorCloth
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "Light cloth garment."
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* 1% damage reduction"
            case armorLeather
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "Leather jerkin."
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* 5% damage reduction"
            end select
        case iShield
            select case inv.shield.id
            case shieldBuckler
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "Small shield."
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* 5% damage reduction"
            case shieldLeather
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "Leather shield."
                index += 1: redim preserve lines(0 to index) as string
                lines(index) = "* 10% damage reduction"
            end select
        end select
        index += 1: redim preserve lines(0 to index) as string
        'lines(index) = "index equals " & str(index)
        if isIdentified(inv) = TRUE then
            lines(index) = "* Item is identified."
        else
            lines(index) = "* Item is not identified."
        end if
    end if

end sub
