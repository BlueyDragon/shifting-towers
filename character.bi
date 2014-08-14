/'****************************************************************************
* character.bi
* This file contains declarations and functions for generating and maintaining
* a character.
* by Stephen Gatten
* Last update: July 2, 2014
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
    locX as integer 'Current X position on the map
    locY as integer 'Current Y position on the map
end type

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
    declare property locX(newX as integer)      'Sets X coordinate.
    declare property locX() as integer          'Returns X coordinate.
    declare property locY(newY as integer)      'Sets Y coordinate.
    declare property locY() as integer          'Returns Y coordinate.
    
    declare sub printStats ()
    
    declare function generateCharacter() as integer
    declare function moveCharacter() as integer
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

property character.locX(newX as integer)
    _cInfo.locX = newX
end property

property character.locX() as integer
    return _cInfo.locX
end property

property character.locY(newY as integer)
    _cInfo.locY = newY
end property

property character.locY() as integer
    return _cInfo.locY
end property

'Generates a new character.
function character.generateCharacter() as integer
    dim as string enteredName, prompt, sKey
    dim as integer done = false, ret = true, tx, ty
    
    'Set up user input prompt.
    prompt = "Press R to reroll stats, <ENTER> to accept, or <ESC> to exit to menu."
    tx = (CenterX(prompt)) * characterWidth
    ty = (textRows - 6) * characterHeight
    
    'Get the name of the character.
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
    'Generate character attributes.
    
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
            .locX = 0
            .locY = 0
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
    return ret
end function

'Prints out the current stats for the character.
sub character.printStats()
    dim as integer tx, ty, row = 8
    dim as string sInfo
    
    screenLock
    'Draw the background.
    drawBackground bgTitle()
    
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
    sInfo = "Aura:      " & _cInfo.hits
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
