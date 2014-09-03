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
    fe(2) as integer 'Ferocity rating array. 0 - base, 1 - modifier
    en(2) as integer 'Endurance
    ra(2) as integer 'Radiance
    ag(2) as integer 'Agility
    iq(2) as integer 'Learning/Intellect
    cond as integer 'Current health.
    hits as integer 'Maximum health.
    aura as integer 'Current aura points.
    maxAP as integer 'Maximum aura.
    mAtk(2) as integer 'Melee attack
    rAtk(2) as integer 'Ranged attack
    sAtk(2) as integer 'Magic/Special attack
    pDef(2) as integer 'Physical defense
    sDef(2) as integer 'Magic/Special defense
    currXP as integer 'Current spirit rating
    totXP as integer 'Total spirit rating
    currGold as integer 'Current gold amount
    totGold as integer 'Lifetime gold amount
    location as mapCoordinate       'Character's current X and Y location.
    backpack(97 to 122) as inventoryType
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
    declare property fe(newFE as integer)
    declare property fe() as integer
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
    
    declare function generateCharacter() as integer
    declare function moveCharacter() as integer
    declare function getFreeInventoryIndex() as integer
    declare function hasInventoryItem(index as integer) as integer
    
    declare sub addInventoryItem(index as integer, inv as inventoryType)
    declare sub getInventoryItem(index as integer, inv as inventoryType)
    declare sub printStats ()
    
end type

'Returns the character name.
Property character.charName() As String
   Return _cInfo.cName
End Property

property character.fe(newFE as integer)
    _cInfo.fe(0) = newFE
end property

property character.fe() as integer
    return _cInfo.fe(0)
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
    'Validate the index.
    if index >= lbound(_cInfo.backpack) and index <= ubound(_cInfo.backpack) then
        'Check the class ID.
        if _cInfo.backpack(index).classID = iNone then
            return false
        else
            return true
        endif
    else
        return false
    endif
end function

'Generates a new character.
function character.generateCharacter() as integer
    dim as string enteredName, prompt, sKey
    dim as integer done = false, ret = true, tx, ty
    dim as tWidgets.btnID btn
    dim as tWidgets.tInputbox ib
    
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
                .fe(0) = randomRange(1,20)
                .en(0) = randomRange(1,20)
                .ra(0) = randomRange(1,20)
                .ag(0) = randomRange(1,20)
                .iq(0) = randomRange(1,20)
                .cond = randomRange(4,18) + (.en(0) / 4)
                .hits = .cond
                .aura = randomRange(4,18) + (.ra(0) / 4)
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
    
    return ret
end function

'Adds inventory item to character inventory slot.
sub character.addInventoryItem(index as integer, inv as inventoryType)
    'Validate the index.
    if index >= lbound(_cInfo.backpack) and index <= ubound(_cInfo.backpack) then
        'Clear the inventory slot.
        clearInventory _cInfo.backpack(index)
        
        'Set the item into the inventory slot.
        _cInfo.backpack(index) = inv
    endif
end sub

'Gets an item from an inventory slot.
sub character.getInventoryItem(index as integer, inv as inventoryType)
    'Clear the inventory item.
    clearInventory inv
    
    'Validate the index.
    if index >= lbound(_cInfo.backpack) and index <= ubound(_cInfo.backpack) then
        inv = _cInfo.backpack(index)
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

dim shared player as character    
