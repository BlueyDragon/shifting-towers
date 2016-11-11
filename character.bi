/'****************************************************************************
* character.bi
* This file contains declarations and functions for generating and maintaining
* a character.
* by Stephen Gatten
* Last update: September 1, 2014
*****************************************************************************'/

'Character attribute type definition.
type characterInfo
    cName as string * 30 'Name of character, limited to 30 characters.
    fe(3) as integer 'Ferocity rating array. 0 - base, 1 - modifier, 2 - modifier timer
    en(3) as integer 'Endurance
    ra(3) as integer 'Radiance
    ag(3) as integer 'Agility
    iq(3) as integer 'Learning/Intellect
    cond as integer 'Current health.
    hits as integer 'Maximum health.
    aura as integer 'Current aura points.
    maxAP as integer 'Maximum aura.
    mAtk(3) as integer 'Melee attack
    rAtk(3) as integer 'Ranged attack
    sAtk(3) as integer 'Magic/Special attack
    pDef(3) as integer 'Physical defense
    sDef(3) as integer 'Magic/Special defense
    currXP as integer 'Current spirit rating
    totXP as integer 'Total spirit rating
    currGold as integer 'Current gold amount
    totGold as integer 'Lifetime gold amount
    location as mapCoordinate       'Character's current X and Y location.
    isPoisoned as integer       'Poisoned flag; true if character is poisoned.
    poisonLevel as integer      'Strength of poison affecting character.
    
    backpack(97 to 122) as inventoryType
    equipment(slotMain to slotRingL) as inventoryType
end type

'The backpack variable is the character inventory. The odd subscript ranges are
'the ASCII codes for the characters a through z. The character will have
'twenty-six inventory slots in addition to the items currently equipped. This
'way, we can take the ASCII code of the player's selection and translate it to
'a subscript of the inventory array.

'Character object.
type character
    private:
    _cInfo as characterInfo
    
    public:
    declare property charName() as string
    
    'FEROCITY base, modifier, and modifier timer values
    declare property fe(newFE as integer)
    declare property fe() as integer
    declare property feMod(newFEMod as integer)
    declare property feMod() as integer
    declare property feTmr(newFETmr as integer)
    declare property feTmr() as integer
    
    declare property en(newEN as integer)
    declare property en() as integer
    declare property ra(newRA as integer)
    declare property ra() as integer
    declare property ag(newAG as integer)
    declare property ag() as integer
    declare property iq(newIQ as integer)
    declare property iq() as integer
    
    declare property mAtk(newMAtk as integer)
    declare property mAtk() as integer
    declare property rAtk(newRAtk as integer)
    declare property rAtk() as integer
    declare property sAtk(newSAtk as integer)
    declare property sAtk() as integer
    declare property pDef(newPDef as integer)
    declare property pDef() as integer
    declare property sDef(newSDef as integer)
    declare property sDef() as integer
    
    declare property cond(newCond as integer)   'Sets current health.
    declare property cond() as integer          'Returns current health.
    declare property hits() as integer          'Returns maximum health.
    declare property aura(newAura as integer)   'Sets current aura.
    declare property aura() as integer          'Returns current aura.
    declare property maxAP() as integer         'Returns maximum aura.
    
    declare property currGold() as integer
    declare property currGold(newGold as integer)
    declare property totGold() as integer
    declare property totGold(newGold as integer)
    declare property currXP() as integer
    declare property currXP(newXP as integer)
    declare property totXP() as integer
    declare property totXP(newXP as integer)
    
    declare property locX(newX as integer)      'Sets X coordinate.
    declare property locX() as integer          'Returns X coordinate.
    declare property locY(newY as integer)      'Sets Y coordinate.
    declare property locY() as integer          'Returns Y coordinate.
    declare property lowInv() as integer
    declare property highInv() as integer
    
    declare property poisoned() as integer
    declare property poisoned(flag as integer)
    declare property poisonLvl() as integer
    declare property poisonLvl(amount as integer)
    
    declare sub addInventoryItem(index as integer, inv as inventoryType)
    declare sub getInventoryItem(index as integer, inv as inventoryType)
    declare sub printStats ()
    declare sub tick()
    
    declare function generateCharacter() as integer
    declare function moveCharacter() as integer
    declare function getFreeInventoryIndex() as integer
    declare function hasInventoryItem(index as integer) as integer
    declare function canEquip(inv as inventoryType) as integer

end type

'Returns the character name.
Property character.charName() As String
   Return _cInfo.cName
End Property

'FEROCITY base value
property character.fe(newFE as integer)
    _cInfo.fe(0) = newFE
end property
property character.fe() as integer
    return _cInfo.fe(0)
end property

'FEROCITY modifier
property character.feMod(newFEMod as integer)
    _cInfo.fe(1) = newFEMod
end property
property character.feMod() as integer
    return _cInfo.fe(1)
end property

'FEROCITY modifier timer
property character.feTmr(newFETmr as integer)
    _cInfo.fe(2) = newFETmr
end property
property character.feTmr() as integer
    return _cInfo.fe(2)
end property

property character.en(newEN as integer)
    _cInfo.en(0) = newEN
end property

property character.en() as integer
    return _cInfo.en(0)
end property

property character.ra(newRA as integer)
    _cInfo.ra(0) = newRA
end property

property character.ra() as integer
    return _cInfo.ra(0)
end property

property character.ag(newAG as integer)
    _cInfo.ag(0) = newAG
end property

property character.ag() as integer
    return _cInfo.ag(0)
end property

property character.iq(newIQ as integer)
    _cInfo.iq(0) = newIQ
end property

property character.iq() as integer
    return _cInfo.iq(0)
end property

property character.mAtk(newMAtk as integer)
    _cInfo.mAtk(0) = newMAtk
end property

property character.mAtk() as integer
    return _cInfo.mAtk(0)
end property

property character.rAtk(newRAtk as integer)
    _cInfo.rAtk(0) = newRAtk
end property

property character.rAtk() as integer
    return _cInfo.rAtk(0)
end property

property character.sAtk(newSAtk as integer)
    _cInfo.sAtk(0) = newSAtk
end property

property character.sAtk() as integer
    return _cInfo.sAtk(0)
end property

property character.pDef(newPDef as integer)
    _cInfo.pDef(0) = newPDef
end property

property character.pDef() as integer
    return _cInfo.pDef(0)
end property

property character.sDef(newSDef as integer)
    _cInfo.sDef(0) = newSDef
end property

property character.sDef() as integer
    return _cInfo.sDef(0)
end property

property character.cond(newCond as integer)
    _cInfo.cond = newCond
end property

property character.cond() as integer
    return _cInfo.cond
end property

property character.hits() as integer
    return _cInfo.hits
end property

property character.aura(newAura as integer)
    _cInfo.aura = newAura
end property

property character.aura() as integer
    return _cInfo.aura
end property

property character.maxAP() as integer
    return _cInfo.maxAP
end property

property character.currGold(newGold as integer)
    _cInfo.currGold = newGold
end property

property character.currGold() as integer
    return _cInfo.currGold
end property

property character.totGold(newGold as integer)
    _cInfo.totGold = newGold
end property

property character.totGold() as integer
    return _cInfo.totGold
end property

property character.currXP(newXP as integer)
    _cInfo.currXP = newXP
end property

property character.currXP() as integer
    return _cInfo.currXP
end property

property character.totXP(newXP as integer)
    _cInfo.totXP = newXP
end property

property character.totXP() as integer
    return _cInfo.totXP
end property

property character.locX(newX as integer)
    _cInfo.location.x = newX
end property

property character.locX() as integer
    return _cInfo.location.x
end property

property character.locY(newY as integer)
    '_cInfo.locY = newY
    _cInfo.location.y = newY
end property

property character.locY() as integer
    'return _cInfo.locY
    return _cInfo.location.y
end property

'Returns the low index of inv array.
Property character.lowInv() As Integer
   Return LBound(_cInfo.backpack)
End Property

'Returns the high index of inv array.
Property character.highInv() As Integer
   Return UBound(_cInfo.backpack)
End Property

property character.poisoned() as integer
    return _cInfo.isPoisoned
end property

property character.poisoned(flag as integer)
    _cInfo.isPoisoned = flag
end property

property character.poisonLvl() as integer
    return _cInfo.poisonLevel
end property

property character.poisonLvl(amount as integer)
    _cInfo.poisonLevel = amount
end property

'Adds inventory item to character inventory slot.
sub character.addInventoryItem(index as integer, inv as inventoryType)
    'Check to see if the item needs to go into the equipment.
    if index >= lbound(_cInfo.equipment) and index <= ubound(_cInfo.equipment) then
        'Clear the equipment slot.
        clearInventory _cInfo.equipment(index)
        'Set the item into the equipment slot.
        _cInfo.equipment(index) = inv
    else
        'Validate the index.
        if index >= lbound(_cInfo.backpack) and index <= ubound(_cInfo.backpack) then
            'Clear the inventory slot.
            clearInventory _cInfo.backpack(index)
            'Set the item into the inventory slot.
            _cInfo.backpack(index) = inv
        endif
    endif
end sub

'Gets an item from an inventory slot.
sub character.getInventoryItem(index as integer, inv as inventoryType)
    'Clear the item placeholder object.
    clearInventory inv
    
    'Check to see if the item is in the equipment.
    if index >= lbound(_cInfo.equipment) and index <= ubound(_cInfo.equipment) then
        inv = _cInfo.equipment(index)
    else
        'Validate the index.
        if index >= lbound(_cInfo.backpack) and index <= ubound(_cInfo.backpack) then
           inv = _cInfo.backpack(index)
        endif
    endif
end sub

'Prints out the current stats for the character.
sub character.printStats()
    dim as integer tx, ty, row = 8
    dim as string sInfo
    
    screenLock
    'Draw the background.
    drawBackground bgShield()
    
    'Draw the title.
    sInfo = Trim(_cInfo.cName) & " Attributes and Skills"
    ty = row * characterHeight
    tx = (centerX(sInfo)) * characterWidth
    drawShadowedText tx, ty, sInfo, cYellowBright
    
    'Draw the attributes on the left side, at X 70
    tx = 70
    row += 4 : ty = row * characterHeight
    sInfo = "Ferocity:  " & _cInfo.fe(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Endurance: " & _cInfo.en(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Radiance:  " & _cInfo.ra(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Agility:   " & _cInfo.ag(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Learning:  " & _cInfo.iq(0)
    drawShadowedText tx, ty, sInfo
    
    row += 3 : ty = row * characterHeight
    sInfo = "Health:    " & _cInfo.hits
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Aura:      " & _cInfo.aura
    drawShadowedText tx, ty, sInfo
    
    'Draw the attributes on the left side, at X 70
    tx = 240
    row = 12 : ty = row * characterHeight
    sInfo = "Melee Skill:      " & _cInfo.mAtk(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Ranged Skill:     " & _cInfo.rAtk(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Magical Skill:    " & _cInfo.sAtk(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Physical Defense: " & _cInfo.pDef(0)
    drawShadowedText tx, ty, sInfo
    
    row += 2 : ty = row * characterHeight
    sInfo = "Magical Defense:  " & _cInfo.sDef(0)
    drawShadowedText tx, ty, sInfo
    
    screenunlock
end sub

'TICK goes through all bonus settings and adjusts counts, applies poison, etc.
sub character.tick()
    dim as integer roll1, roll2, v1, v2
    
    'Poison affects character based on strength of poison.
    if _cInfo.isPoisoned = TRUE then
        'Get the strength of the poison.
        v1 = _cInfo.poisonLevel
        'Get the character's endurance, plus any bonus
        v2 = _cInfo.en(0) + _cInfo.en(1)
        
        'Roll to determine whether poison succeeds this turn.
        roll1 = randomRange(1,v1)
        roll2 = randomRange(1,v2)
        
        'If poison wins...
        if roll1 > roll2 then
            'Decrement health by one.
            _cInfo.cond = _cInfo.cond - 1
        endif
    endif
    
    'Check attribute bonus counts.
    'Ferocity
    if _cInfo.fe(2) > 0 then
        'Decrement the count.
        _cInfo.fe(2) -= 1
        if _cInfo.fe(2) <= 0 then
            'Reset bonus amount.
            _cInfo.fe(1) = 0
        endif
    endif
    
    'Endurance
    if _cInfo.en(2) > 0 then
        'Decrement the count.
        _cInfo.en(2) -= 1
        if _cInfo.en(2) <= 0 then
            'Reset bonus amount.
            _cInfo.en(1) = 0
        endif
    endif
    
    'Radiance
    if _cInfo.ra(2) > 0 then
        'Decrement the count.
        _cInfo.ra(2) -= 1
        if _cInfo.ra(2) <= 0 then
            'Reset bonus amount.
            _cInfo.ra(1) = 0
        endif
    endif
    
    'Agility
    if _cInfo.ag(2) > 0 then
        'Decrement the count.
        _cInfo.ag(2) -= 1
        if _cInfo.ag(2) <= 0 then
            'Reset bonus amount.
            _cInfo.ag(1) = 0
        endif
    endif
    
    'Learning
    if _cInfo.iq(2) > 0 then
        'Decrement the count.
        _cInfo.iq(2) -= 1
        if _cInfo.iq(2) <= 0 then
            'Reset bonus amount.
            _cInfo.iq(1) = 0
        endif
    endif
    
    'Melee Attack
    if _cInfo.mAtk(2) > 0 then
        'Decrement the count.
        _cInfo.mAtk(2) -= 1
        if _cInfo.mAtk(2) <= 0 then
            'Reset bonus amount.
            _cInfo.mAtk(1) = 0
        endif
    endif
    
    'Ranged Attack
    if _cInfo.rAtk(2) > 0 then
        'Decrement the count.
        _cInfo.rAtk(2) -= 1
        if _cInfo.rAtk(2) <= 0 then
            'Reset bonus amount.
            _cInfo.rAtk(1) = 0
        endif
    endif
    
    'Special Attack
    if _cInfo.sAtk(2) > 0 then
        'Decrement the count.
        _cInfo.sAtk(2) -= 1
        if _cInfo.sAtk(2) <= 0 then
            'Reset bonus amount.
            _cInfo.sAtk(1) = 0
        endif
    endif
    
    'Physical Defense
    if _cInfo.pDef(2) > 0 then
        'Decrement the count.
        _cInfo.pDef(2) -= 1
        if _cInfo.pDef(2) <= 0 then
            'Reset bonus amount.
            _cInfo.pDef(1) = 0
        endif
    endif
    
    'Special Defense
    if _cInfo.sDef(2) > 0 then
        'Decrement the count.
        _cInfo.sDef(2) -= 1
        if _cInfo.sDef(2) <= 0 then
            'Reset bonus amount.
            _cInfo.sDef(1) = 0
        endif
    endif
end sub

'Returns a free inventory slot index, or -1 if none exist.
function character.getFreeInventoryIndex() as integer
    dim as integer ret = -1
    
    'Look for an empty inventory slot.
    for i as integer = lbound(_cInfo.backpack) to ubound(_cInfo.backpack)
        'Examine class ID.
        if _cInfo.backpack(i).classID = iNone then
            'Empty slot.
            ret = i
            exit for
        endif
    next
        
    return ret
end function

'Returns true if an item exists in the given inventory slot.
function character.hasInventoryItem(index as integer) as integer
    'First, check equipped items
    if index >= lbound(_cInfo.equipment) and index <= ubound(_cInfo.equipment) then
        'Check the class ID.
        if _cInfo.equipment(index).classID = iNone then
            return FALSE
        else
            return TRUE
        endif
    else
        'Validate the index.
        if index >= lbound(_cInfo.backpack) and index <= ubound(_cInfo.backpack) then
            'Check the class ID.
            if _cInfo.backpack(index).classID = iNone then
                return FALSE
            else
                return TRUE
            endif
        else
            return FALSE
        endif
    endif
end function

'CAN EQUIP checks to see if the character can equip a given item.
function character.canEquip(inv as inventoryType) as integer
    dim as integer ret = TRUE
    
    if inv.classID = iArmor then
        if inv.armor.enRequired > _cInfo.en(0) then
            ret = FALSE
        endif
    endif
    
    if inv.classID = iShield then
        if inv.shield.enRequired > _cInfo.en(0) then
            ret = FALSE
        endif
    endif
    
    return ret
end function

'Generates a new character.
function character.generateCharacter() as integer
    dim as string enteredName, prompt, sKey
    dim as integer done = false, ret = true, tx, ty
    dim as tWidgets.btnID btn
    dim as tWidgets.tInputbox ib
    dim as inventoryType inv
    
    'Set up user input prompt.
    prompt = "Press R to reroll stats, <ENTER> to accept, or <ESC> to exit to menu."
    tx = (CenterX(prompt)) * characterWidth
    ty = (textRows - 6) * characterHeight
    
    /'Get the name of the character, using simple input. This loop is obsolete,
    'as the program now uses tWidgets.
    do
        cls
        'Using simple input here.
        input "Enter your character's name (30 characters maximum): ",enteredName
        
        'Validate the name.
        if len(enteredName) > 0 and len(enteredName) < 31 then
            done = true
        else
            'Let the user know what went wrong.
            cls
            if len(enteredName) = 0 then
                print "A name is required for your character. Press any key to continue."
                sleep
                clearKeys
            endif
            if len(enteredName) > 30 then
                print "Your character's name is too long. There is a thirty character limit. Press any key to continue."
                sleep
                clearKeys
            endif
        endif
        sleep 10
    loop until done = true
    
    done = false
    '/
    
    'Draw the background
    screenlock
    drawBackground bgShield()
    screenunlock
    
    ib.title = "Character Name"
    ib.prompt = "Enter your character's name:"
    ib.maxLen = 30
    ib.inputLen = 30
    
    'Get the name of the character.
    btn = ib.inputbox(enteredName)
    if btn = tWidgets.btnID.gbnCancel then
        ret = false
    endif
    if btn = tWidgets.btnID.gbnOK then
        ret = true
    endif
    
    'Display character.
    if ret = true then
        'Generate the character data.
        do
            with _cInfo
                .cName = enteredName
                .fe(0) = randomRange(10,20)
                .en(0) = randomRange(10,20)
                .ra(0) = randomRange(10,20)
                .ag(0) = randomRange(10,20)
                .iq(0) = randomRange(10,20)
                .cond = randomRange(6,18) + (.en(0) / 4)
                .hits = .cond
                .aura = randomRange(6,18) + (.ra(0) / 4)
                .maxAP = .aura
                .mAtk(0) = .fe(0) + .en(0)
                .rAtk(0) = .fe(0) + .ag(0)
                .sAtk(0) = .ra(0) + .iq(0)
                .pDef(0) = .en(0) + .ag(0)
                .sDef(0) = .ag(0) + .iq(0)
                .currXP = 0
                .totXP = 0
                .currGold = 0
                .totGold = 0
                .location.x = 0
                .location.y = 0
            end with
        
        'Print out the current character stats.
        printStats
        drawShadowedText tx, ty, prompt
        
        'Get the user command.
        do
            'Get the keypress.
            sKey = inkey
            'Format to lowercase.
            sKey = lcase(sKey)
            'if escape, exit back to the menu.
            if sKey = kEsc then
                done = true
                ret = false
            endif
            'If enter, continue with the game.
            if sKey = kEnter then
                done = true
            endif
            sleep 10
        loop until (sKey = "r") or (sKey = kEsc) or (sKey = kEnter)
    loop until done = true
    endif
    
    'Place some cloth armor into character's equipment.
    inv.classID = iArmor
    generateArmor inv, 1, armorCloth
    setItemIdentified inv, TRUE
    addInventoryItem slotArmor, inv
    
    'Place a buckler into character's equipment.
    inv.classID = iShield
    generateShield inv, 1, shieldBuckler
    setItemIdentified inv, TRUE
    addInventoryItem slotOffhand, inv
    
    'Place a dagger into character's equipment.
    
    return ret
end function

'Set up shared player character variable.
dim shared player as character    
