/'****************************************************************************
* dungeon.bas
* Main program file for Dungeon of Doom
* by Stephen Gatten
* Last update: November 8, 2016
*****************************************************************************'/

#include "images/bg-title.bi"
#include "images/bg-shield.bi"

#include "fbgfx.bi"
#include "tWidgets.bi"

#include "vector.bi"
#include "defs.bi"
#include "utils.bi"
#include "mainmenu.bi"
#include "inventory.bi"
#include "character.bi"
#include "intro.bi"
#include "map.bi"
#include "commands.bi"

'Displays the game title screen. This subroutine is obsolete, the game now loads
'straight into the main menu.
Sub DisplayTitle
    Dim As String copyrightText
    Dim As Integer textX, textY
        
    'Set up the copyright notice.
    copyrightText = "(c) 2016 Studio (D)raconis"
    textX = centerX(copyrightText)
    textY = textRows - 2
    
    'Lock the screen while we update it.
    ScreenLock
    
    'Draw the background
    drawBackground bgTitle()
        
    'Draw the copyright notice
    Draw String(textX * characterWidth, textY * characterHeight), copyrightText, cYellowBright
    ScreenUnLock
    Sleep
        
    'Clear the key buffer
    clearKeys
End Sub

Sub clearMessageArea()
   Dim As Integer y, x, j
   
   y = 1 + viewHeight + 2
   For x = 2 To textColumns - 1
      For j = 0 To 3
         placeSpace x, y + j
      Next
   Next
   
end sub

'Prints any messages to the screen's message box.
sub printMessage(txt as string)
    dim as integer i, x, y
    
    if len(txt) > 0 then
        'Move all messages down by 1.
        for i = 3 to 1 step -1
            mess(i + 1) = mess(i)
        next
        mess(1) = txt
    endif
    
    'Clear current messages
    clearMessageArea
    
    'Print out messages
    y = 1 + viewHeight + 2
    x = 3
    for i = 1 to 4
        placeGlyph mess(i), x, y, messColor(i)
        y += 1
    next
end sub

'Draws the main game screen.
sub drawMainScreen()
    dim as integer x, y, j, healthPercent, row, column, titleX
    dim as double pctd
    dim as uinteger clr
    dim as string txt
    dim as terrainIDs terr
    
    screenlock
    
    healthPercent = int((player.cond / player.hits) * 100)
    if healthPercent > 74 then
        drawSolidBackground(cGreen)
    elseif (healthPercent > 24) andalso (healthPercent < 75) then 
        drawSolidBackground(cYellow)
    else
        drawSolidBackground(cRed)
    endif
    
    level.drawMap
    
    'Draw the message area.
    printMessage ""
    
    'Draw the information area.
    y = 2
    for j = 0 to viewHeight - 1
        for x = viewWidth + 3 to textColumns - 1
            placeSpace x, y + j
        next
    next
    
    'drawShadowedText characterWidth, 0, "Dungeon Level: " & level.levelID
    'titleX = centerX(title)
    'drawGlowText (titleX * characterWidth), 0, title, cYellowBright
    
    'Draw the character name.
    row = 3
    column = viewWidth + 4
    placeGlyph player.charName, column, row, cYellowBright
    row += 1
    txt = " the Adventurer"
    placeGlyph txt, column, row
    row += 2
    placeGlyph "-Vitals-", column, row, cYellowBright
    
    'Draw the character's health bar and health rating in numeric form.
    row += 2
    pctd = player.cond / player.hits
    txt = string((textColumns - 1) - (column + 8), gBlock)
    placeGlyph "        " & txt, column, row, cBlack
    txt = string((textColumns - 1) - (column + 8), chr(176))
    placeGlyph "        " & txt, column, row, cGray
    txt = string(len(txt) * pctd, gBlock)
    placeGlyph "        " & txt, column, row, cRed
    placeGlyph "Health: ", column, row
    txt = player.cond & "/" & player.hits
    drawShadowedText (textColumns - (len(txt) + 2)) * characterWidth, (row - 1) * characterHeight, txt
    
    row += 2
    pctd = player.aura / player.maxAP
    txt = string((textColumns - 1) - (column + 8), gBlock)
    placeGlyph "        " & txt, column, row, cBlack
    txt = string((textColumns - 1) - (column + 8), chr(176))
    placeGlyph "        " & txt, column, row, cGray
    txt = string(len(txt) * pctd, gBlock)
    placeGlyph "        " & txt, column, row, cBlue
    placeGlyph "Aura:   ", column, row
    txt = player.aura & "/" & player.maxAP
    drawShadowedText (textColumns - (len(txt) + 2)) * characterWidth, (row - 1) * characterHeight, txt
    
    'Draw the main stats.
    row += 2
    placeGlyph "-Attributes-", column, row, cYellowBright
    
    row += 2
    placeGlyph "Courage Level: 0", column, row
    row += 2
    placeGlyph "Ferocity:  " & player.fe, column, row
    row += 1
    placeGlyph "Endurance: " & player.en, column, row
    row += 1
    placeGlyph "Radiance:  " & player.ra, column, row
    row += 1
    placeGlyph "Agility:   " & player.ag, column, row
    row += 1
    placeGlyph "Learning:  " & player.iq, column, row
    
    'Draw the battle skills.
    row += 2
    placeGlyph "-Battle Skills-", column, row, cYellowBright
    
    row += 2
    placeGlyph "Melee Skill:      " & player.mAtk, column, row
    row += 1
    placeGlyph "Ranged Skill:     " & player.rAtk, column, row
    row += 1
    placeGlyph "Magical Skill:    " & player.sAtk, column, row
    row += 1
    placeGlyph "Physical Defense: " & player.pDef, column, row
    row += 1
    placeGlyph "Magical Defense:  " & player.sDef, column, row
    
    'Draw the dungeon level information.
    row += 2
    placeGlyph "-Compass-", column, row, cYellowBright
    
    row += 2
    placeGlyph "Dungeon Level: " & level.levelID, column, row
    row += 1 : placeGlyph " the " & level.getLevelDescription, column, row
    
    'Check to see if the character is standing on an item.
    if level.hasItem(player.locX, player.locY) = true then
        'txt = "There is a " & level.getItemDescription(player.locX, player.locY) & " here."
        txt = level.getItemDescription(player.locX, player.locY)
        printMessage txt
    else
        'See if character is on a special tile.
        terr = level.getTileID(player.locX, player.locY)
        if (terr = tStairUp) orelse (terr = tStairDown) then
            txt = level.getTerrainDescription(player.locX, player.locY)
            printMessage txt
        endif
    endif
    screenunlock
end sub

'Draws the player inventory.
sub drawInventoryScreen()
    dim as integer col, row, iItem, ret, savedRow, sRow, ssRow, count, i
    dim as string text, text2, desc, itemName
    dim as inventoryType inv
    dim as uInteger clr
    
    screenLock
    'Set the background for the inventory screen.
    drawBackground bgShield()
        
    'Add the title.
    text = "Current Inventory for " & trim(player.charName)
    col = centerX(text)
    row = 1
    
    'Draw the title with a drop shadow.
    placeGlyphShadow text, col, row, cYellowBright
    
    'Add the current held equipment.
    col = 2
    row += 3
    savedRow = row 'Save the row location.
    
    'Iterate through all equipment slots printing item names.
    for i = slotMain to slotRingL
        select case i
        case slotMain
            text = i & " Main Hand: "
        case slotOffhand
            text = i & " Offhand: "
        case slotArmor
            text = i & " Armor: "
        case slotNeck
            text = i & " Neck: "
        case slotRingR
            text = i & " Ring (Right): "
        case slotRingL
            text = i & " Ring (Left): "
        end select
        
        itemName = "" 
        iItem = player.hasInventoryItem(i)
        if iItem = TRUE then
            player.getInventoryItem i, inv
            ret = isIdentified(inv)
            itemName = getInventoryItemDescription(inv)
            clr = inv.glyphColor
            text &= itemName
            if ret = FALSE then
                text &= " (*)"
            endif
        else
            clr = cWhite
        endif
        
        placeGlyphShadow text, col, row, clr
        row += 2
        if i = slotArmor then
            col = textColumns / 2
            row = savedRow
        endif
    next
    
    'Draw the divider line.
    'row += 2
    col = 1
    text = string(80, chr(205))
    mid(text, 2) = " Backpack  (*) = Unidentified "
    text2 = " Gold: " & player.currGold & " "
    mid(text, 80 - len(text2)) = text2
    placeGlyphShadow text, col, row, cYellowBright
    
    row += 2
    col = 2
    sRow = row
    
    'Print out the inventory items.
    for i = player.lowInv to player.highInv
        'See if the character has an item in slot.
        iItem = player.hasInventoryItem(i)
        if iItem = true then
            'Get the inventory item.
            player.getInventoryItem i, inv
            
            'Has the item been identified?
            ret = isIdentified(inv)
            
            'Get the description.
            desc = getInventoryItemDescription(inv)
            
            'Get the color of the item.
            clr = inv.glyphColor
            
            'Build the text string.
            text = chr(i) & " " & desc & " "
            
            'If not examined, mark it as such.
            if ret = false then
                text &= "(*)"
            endif
        else
            text = chr(i)
            clr = cWhite
        endif
        
        'Move column over when reached half of the list.
        count += 1
        if count = 14 then
            col = textColumns / 2
            'Save the end of the first column so we can draw a line.
            ssRow = row
            row = sRow
        endif
        
        'Draw the text.
        placeGlyphShadow text, col, row, clr
        row += 2
    next
    
    'Draw the divider line.
    row = ssRow + 1
    col = 1
    text = string(80, chr(205))
    mid(text, 2) = " Spells Learned "
    placeGlyphShadow text, col, row, cYellowBright
    
    'Draw the spell slots.
    col = 2
    row += 2
    count = 0
    sRow = row
    for i = 65 to 78
        text = chr(i)
        'Move column over when reached half of the list.
        count += 1
        if count = 8 then
            col = textColumns / 2
            'Save the end of the first column so we can draw line.
            ssRow = row
            row = sRow
        endif
        
        'Draw the text.
        placeGlyphShadow text, col, row, clr
        row += 2
    next
    
    'Draw the divider line.
    row = ssRow + 1
    col = 1
    text = string(80, chr(205))
    mid(text, 2) = " Commands "
    placeGlyphShadow text, col, row, cYellowBright
    
    'Draw the command list
    row += 2
    text = "(D)rop - (E)quip - (I)dentify - (L)ook - (U)se   (ESC) Exit"
    col = centerX(text)
    placeGlyphShadow text, col, row, cWhite
    screenunlock
end sub

'Print message to user using msgbox.
Sub showMsg(newTitle As String, mess As String, mtype As tWidgets.MsgBoxType)
   Dim As tWidgets.tMsgbox mb
   Dim As tWidgets.btnID btn

   mb.MessageStyle = mtype
   mb.Title = newTitle
   btn = mb.MessageBox(mess)
end sub

'SHOW MSG LINES prints a multi-line message to the user using msgbox.
sub showMsgLines(newTitle as string, mess() as string, mtype as tWidgets.MsgBoxType)
    dim as tWidgets.tMsgbox mb
    dim as tWidgets.btnID btn
    
    mb.MessageStyle = mtype
    mb.Title = newTitle
    btn = mb.MessageBox(mess())
end sub

'Processes the IDENTIFY command.
function processIdentify() as integer
    dim as string res, mask, desc
    dim as integer i, iRet, iItem, idDR, playerIQ, rollP, rollI, ret = false
    dim as inventoryType inv
    dim as tWidgets.btnID btn
    dim as tWidgets.tInputBox ib
    
    'Make sure there is something to identify.
    for i = player.lowInv to player.highInv
        iItem = player.hasInventoryItem(i)
        if iItem = true then
            'Get the inventory item.
            player.getInventoryItem i, inv
            
            'Is the item identified?
            iRet = isIdentified(inv)
            
            'An item to identify.
            if iRet = false then
                'Build the mask.
                mask &= chr(i)
            endif
        endif
    next
    
    if len(mask) = 0 then
        showMsg "Identify", "There are no unidentified items in your pack.", tWidgets.MsgBoxType.gmbOK
    else
        'Draws an input box on the screen.
        ib.Title = "Identify"
        ib.Prompt = "Select item(s) to identify (" & mask & ")"
        ib.Row = 39
        ib.EditMask = mask
        ib.MaxLen = len(mask)
        ib.InputLen = len(mask)
        btn = ib.Inputbox(res)
        
        'Identify each item in the list.
        if(btn <> tWidgets.btnID.gbnCancel) and (len(res) > 0) then
            'Identify the list of items.
            for i = 1 to len(res)
                'Get index into character inventory.
                iItem = asc(res,i)
                
                'Get the inventory item.
                player.getInventoryItem iItem, inv
                
                'Get the identify difficulty.
                idDR = getIdentifyDifficulty(inv)
                
                'Use the intelligence attribute to calculate the identify attempt.
                playerIQ = player.iq
                
                'Roll for the item's difficulty.
                rollI = randomRange(0, idDR)
                
                'Roll for player.
                rollP = randomRange(0, playerIQ)
                
                'Get the item description.
                desc = getInventoryItemDescription(inv)
                
                'If the player rolls => identify roll, item is identified.
                if rollP > rollI then
                    desc &= " was successfully identified!"
                    showMsg "Identify", desc, tWidgets.MsgBoxType.gmbOK
                    setItemIdentified inv, true
                    player.addInventoryItem iItem, inv
                    ret = true
                else
                    desc &= " was not identified."
                    showMsg "Identify", desc, tWidgets.MsgBoxType.gmbOK
                endif
            next
        endif
    endif
    
    return ret
end function

'Processes the LOOK inventory command.
function processLook() as integer
    dim as string res, mask, desc, choice
    dim as integer i, iItem, ret = false
    dim as inventoryType inv
    dim as tWidgets.btnID btn
    dim as tWidgets.tInputBox ib
    dim lines() as string
    
    'Make sure there is something to look at.
    for i = player.lowInv to player.highInv
        iItem = player.hasInventoryItem(i)
        if iItem = true then
            'Get the inventory item.
            player.getInventoryItem i, inv
            'Build the mask.
            mask &= chr(i)
        endif
    next
    
    'Add any held items.
    for i = slotMain to slotRingL
        iItem = player.hasInventoryItem(i)
        if iItem = TRUE then
            'Build the mask.
            mask &= str(i)
        endif
    next
    
    if len(mask) = 0 then
        showMsg "Look", "You have no items to look at.", tWidgets.MsgBoxType.gmbOK
    else
        'Draws an input box on the screen.
        ib.Title = "Look"
        ib.Prompt = "Select item(s) to look at (" & mask & ")"
        ib.Row = 39
        ib.EditMask = mask
        ib.MaxLen = len(mask)
        ib.InputLen = len(mask)
        btn = ib.Inputbox(res)
        
        'Look at each item in the list.
        if(btn <> tWidgets.btnID.gbnCancel) and (len(res) > 0) then
            for i = 1 to len(res)
                'Get index into character inventory.
                choice = mid(res, i, 1)
                
                'Player chooses 1-6, equipment item
                if instr("123456", choice) > 0 then
                    iItem = val(choice) 'Get index into equipment.
                'Player chooses A-Z, backpack item
                else
                    iItem = asc(choice) 'Get index into backpack.
                endif
                    
                player.getInventoryItem iItem, inv
                getFullDescription lines(), inv
                
                if ubound(lines) > 0 then
                    showMsgLines getInventoryItemDescription(inv), lines(), tWidgets.MsgBoxType.gmbOK
                endif
            next
        endif
    endif
    
    return ret
end function

'PROCESS DROP drops an item from the character's inventory.
function processDrop() as integer
    dim as string res, mask, desc
    dim as integer i, iRet, iItem, ret = FALSE
    dim as inventoryType inv
    dim as tWidgets.btnID btn
    dim as tWidgets.tInputbox ib
    dim as mapVector targetVector
    
    'Make sure there is something in the inventory that can be dropped.
    for i = player.lowInv to player.highInv
        iItem = player.hasInventoryItem(i)
        if iItem = TRUE then
            'Get the inventory item.
            player.getInventoryItem i, inv
            'Build the mask.
            mask &= chr(i)
        endif
    next
    
    if len(mask) = 0 then
        showMsg "Drop", "You have nothing in the pack to drop.", tWidgets.MsgBoxType.gmbOK
    else
        'Draws an input box on the screen.
        ib.Title = "Drop Items"
        ib.Prompt = "Select item(s) to drop (" & mask & ")"
        ib.Row = 39
        ib.EditMask = mask
        ib.MaxLen = len(mask)
        ib.InputLen = len(mask)
        btn = ib.InputBox(res)
        
        'Process drop for each item in the list, one by one.
        if(btn <> tWidgets.btnID.gbnCancel) and (len(res) > 0) then
            for i = 1 to len(res)
                'Get index into character inventory.
                iItem = asc(res,i)
                'Get the inventory item.
                player.getInventoryItem iItem, inv
                'Get the item's name
                desc = getInventoryItemDescription(inv)
                'Look for an empty space on the map.
                iRet = level.getEmptySpot(targetVector)
                
                if iRet = TRUE then
                    'There's an empty spot. Put the item back onto the map.
                    level.putItemOnMap targetVector.vx, targetVector.vy, inv
                    'Clear the item.
                    clearInventory inv
                    'Put the blank item back into the player's inventory, effectively clearing the space.
                    player.addInventoryItem iItem, inv
                    ret = TRUE
                    showMsg "Drop","Dropped " & desc,tWidgets.MsgBoxType.gmbOK
                else
                    'No empty spots.
                    showMsg "Drop","There are no available spots here to drop item.",tWidgets.MsgBoxType.gmbOK
                    exit for
                endif
            next
        endif
    endif
    
    return ret
end function

'PROCESS USE invokes the special ability of a consumable item.
function processUse() as integer
    dim as string res, mask, desc1, desc2
    dim as integer i, iItem, identified, idDiff, ret = false
    dim as inventoryType inv
    dim as tWidgets.btnID btn
    dim as tWidgets.tInputBox ib
    dim lines() as string
    
    'Make sure there is something to use.
    for i = player.lowInv to player.highInv
        iItem = player.hasInventoryItem(i)
        if iItem = true then
            'Get the inventory item.
            player.getInventoryItem i, inv
            'Build the mask.
            mask &= chr(i)
        endif
    next
    
    if len(mask) = 0 then
        showMsg "Use", "You have nothing in your pack to use.", tWidgets.MsgBoxType.gmbOK
    else
        'Draws an input box on the screen.
        ib.Title = "Use Items"
        ib.Prompt = "Select item(s) to use (" & mask & ")"
        ib.Row = 39
        ib.EditMask = mask
        ib.MaxLen = len(mask)
        ib.InputLen = len(mask)
        btn = ib.Inputbox(res)
        
        'Look at each item in the list.
        if(btn <> tWidgets.btnID.gbnCancel) and (len(res) > 0) then
            for i = 1 to len(res)
                'Get index into character inventory.
                iItem = asc(res,i)
                
                'Get the inventory item.
                player.getInventoryItem iItem, inv
               
                'Check the identify state.
                identified = isIdentified(inv)
                
                'Get the identity difficulty.
                idDiff = getIdentifyDifficulty(inv)
                
                'Get the item name.
                desc1 = getInventoryItemDescription(inv)
                desc2 = ""
                
                'Apply the item's effect.
                if inv.supply.id = supplyGreenHerb then
                    'Identified?
                    if (identified = TRUE) and (idDiff > 0) then
                        player.cond = player.hits
                        desc2 = " completely heals you."
                    else
                        player.cond = player.cond + (player.hits * 0.5)
                        if player.cond > player.hits then
                            player.cond = player.hits
                        endif
                        desc2 = " heals you."
                    endif
                elseif inv.supply.id = supplyMeat then
                    player.cond = player.cond + (player.hits * 0.25)
                    if player.cond > player.hits then
                        player.cond = player.hits
                    endif
                    desc2 = " heals you."
                    if (identified = TRUE) and (idDiff > 0) then
                        player.feMod = randomRange(1, player.fe)
                        player.feTmr = randomRange(1, 100)
                        desc2 = " heals you and makes you more ferocious."
                    endif
                elseif inv.supply.id = supplyBread then
                    player.cond = player.cond + (player.hits * 0.1)
                    if player.cond > player.hits then
                        player.cond = player.hits
                    endif
                    desc2 = "heals you."
                    if (identified = TRUE) and (idDiff > 0) then
                        if player.poisoned = TRUE then
                            player.poisoned = FALSE
                            player.poisonLvl = 0
                            desc2 = " heals you and cures your poison."
                        endif
                    endif
                endif
                
                showMsg "Use", desc1 & desc2, tWidgets.MsgBoxType.gmbOK
                'Clear the item.
                clearInventory inv
                'Put the blank item back into inventory.
                player.addInventoryItem iItem, inv
            next
        endif
    endif
    
    return ret
end function

'PROCESS EQUIP removes an item from the pack and places it into the character's
'equipment if there is an available space, or removes an item from the character's
'equipment and places it into the pack.
function processEquip() as integer
    dim as string res, mask, message, choice
    dim as integer i, iRet, iItem, index, ret = FALSE
    dim as inventoryType inv
    dim as tWidgets.btnID btn
    dim as tWidgets.tInputbox ib
    dim as mapVector targetVector
    dim slot as integer
    
    'Make sure there is something to process in the inventory.
    for i = player.lowInv to player.highInv
        iItem = player.hasInventoryItem(i)
        if iItem = TRUE then
            'Get the inventory item.
            player.getInventoryItem i, inv
            'Make sure the item is equippable.
            iRet = matchUse(inv, useEquip)
            if iRet = TRUE then
                'Build the mask.
                mask &= chr(i)
            endif
        endif
    next
    
    'Add any held items.
    for i = slotMain to slotRingL
        iItem = player.hasInventoryItem(i)
        if iItem = TRUE then
            'Build the mask.
            mask &= str(i)
        endif
    next
    
    if len(mask) = 0 then
        showMsg "Equip", "You have nothing to wield or remove.", tWidgets.msgBoxType.gmbOK
    
    else
        'Draws an input box on screen.
        ib.Title = "Equip"
        ib.Prompt = "Select item(s) to wield or remove (" & mask & ")"
        ib.Row = 39
        ib.EditMask = mask
        ib.MaxLen = Len(mask)
        ib.InputLen = Len(mask)
        btn = ib.Inputbox(res)
        
        if (btn <> tWidgets.btnID.gbnCancel) and (len(res) > 0) then
            'Process each item in the list.
            for i = 1 to len(res)
                choice = mid(res, i, 1)
                
                'Player chooses 1-6, an equipment item
                if instr("123456", choice) > 0 then
                    iItem = val(choice) 'Get index into equipment.
                    player.getInventoryItem iItem, inv
                    message = getInventoryItemDescription(inv)
                    iRet = player.getFreeInventoryIndex
                    
                    'If the player has a free spot for the item
                    if iRet > -1 then
                        player.addInventoryItem iRet, inv
                        clearInventory inv
                        player.addInventoryItem iItem, inv
                        ret = TRUE
                        message &= " was unequipped."
                        
                    'The player does NOT have a free spot for the item
                    else
                        message = "You have no free backpack slots for this item."
                        showMsg "Equip", message, tWidgets.MsgBoxType.gmbOK
                        exit for 'Give up immediately, otherwise it will just keep erroring
                    endif
                    showMsg "Equip", message, tWidgets.MsgBoxType.gmbOK
                
                'Player chooses A-Z, an inventory item
                else
                    iItem = asc(choice) 'Get index into backpack.
                    player.getInventoryItem iItem, inv
                    message = getInventoryItemDescription(inv)
                    iRet = FALSE
                    index = 0
                    slot = getInventoryESlot(inv,1)
                    if slot <> slotNone then
                        'Check character to see if slot is open.
                        if player.hasInventoryItem(slot) = FALSE then
                            index = slot
                            iRet = TRUE
                        endif
                    else
                        slot = getInventoryESlot(inv,2)
                        if slot <> slotNone then
                            if player.hasInventoryItem(slot) = FALSE then
                                index = slot
                                iRet = TRUE
                            endif
                        endif
                    endif
                    
                    if iRet = TRUE then
                        if player.canEquip(inv) = TRUE then
                            player.addInventoryItem(index,inv)
                            clearInventory inv
                            player.addInventoryItem iItem, inv
                            ret = TRUE
                            message &= " was equipped."
                        else
                            message = "You do not have enough Endurance to equip this item."
                        endif
                        showMsg "Equip", message, tWidgets.MsgBoxType.gmbOK
                    else
                        message = "You do not have any empty slots to equip this item."
                        showMsg "Equip", message, tWidgets.MsgBoxType.gmbOK
                        exit for
                    endif
                endif
            next
        endif
    endif
        
    return ret
end function
    
'Manages the character's inventory.
sub manageInventory()
    dim as string kChar, iChar
    dim as integer ret
    
    drawInventoryScreen
    do
        kChar = inKey
        kChar = ucase(kChar)
        
        'Check to see if we have a key.
        if kChar <> "" then
            
            '(I)dentify
            if kChar = "I" then
                ret = processIdentify()
                'Screen changed.
                if ret = TRUE then
                    drawInventoryScreen
                endif
            endif
            
            '(U)se
            if kChar = "U" then
                ret = processUse()
                'Screen changed.
                if ret = TRUE then
                    drawInventoryScreen
                endif
            endif
            
            '(D)rop
            if kChar = "D" then
                ret = processDrop()
                'Screen changed.
                if ret = TRUE then
                    drawInventoryScreen
                endif
            endif
            
            '(L)ook
            if kChar = "L" then
                ret = processLook()
                'Screen changed.
                if ret = TRUE then
                    drawInventoryScreen
                endif
            endif
            
            '(E)quip
            if kChar = "E" then
                ret = processEquip()
                'Screen changed.
                if ret = TRUE then
                    drawInventoryScreen
                endif
            endif
        endif
        sleep 1
    loop until kChar = kEsc
    clearKeys
end sub

'Using 640x480 32 bit screen with 80x60 text.
ScreenRes 640, 480, 32
Width characterWidth, characterHeight
WindowTitle "Forcastia Tales: Mersenne Labyrinth"
randomize timer 'Seed the random number generator.
tWidgets.initWidgets 'Initialize the text widgets.

'shell("echo")

'Draw the title screen.
'DisplayTitle

'Get the menu selection
dim mm as mMenu.mMenuRet
'Loop until the user selects New, Load, or Quit.
do
    'Draw the main menu.
    mm = mMenu.mainMenu
    'Process the menu selection.
    if mm = mMenu.mNew then
        'Generate the character.
        var ret = player.generateCharacter
        'Do not exit menu when user presses escape.
        if ret = false then
            'Set this so we loop.
            mm = mMenu.mInfo
        else
            'Perform the intro
            intro.doIntro
        endif
elseif mm = mMenu.mLoad then
        'Load the save game.
elseif mm = mMenu.mInfo then
        'Print the instructions.
        endif
loop until mm <> mMenu.mInfo

'Set the dead flag.
dim as integer isDead = FALSE

'Main game loop.
if mm <> mMenu.mQuit then
    'Build the first level of the dungeon.
    level.levelWallColor = dungeonColors(randomRange(1,ubound(dungeonColors)))
    level.LevelID = 1
    level.generateDungeonLevel
    'Main screen turn on
    drawSolidBackground(cPurple)
    'generateLeatherBackground()
    drawMainScreen
    do
        cKey = inkey
        if cKey <> "" then
            'Get direction key from numpad or arrows.
            
            'Up Arrow / 8
            if (cKey = kUp) orelse (cKey = "8") then
                mRet = moveCharacter(north)
                if mRet = true then drawMainScreen
            endif
            
            '9
            if cKey = "9" then
                mRet = moveCharacter(northeast)
                if mRet = true then drawMainScreen
            endif
            
            'Right Arrow / 6
            if (cKey = kRight) orelse (cKey = "6") then
                mRet = moveCharacter(east)
                if mRet = true then drawMainScreen
            endif
            
            '3
            if cKey = "3" then
                mRet = moveCharacter(southeast)
                if mRet = true then drawMainScreen
            endif
            
            'Down Arrow / 2
            if (cKey = kDown) orelse (cKey = "2") then
                mRet = moveCharacter(south)
                if mRet = true then drawMainScreen
            endif
            
            '1
            if cKey = "1" then
                mRet = moveCharacter(southwest)
                if mRet = true then drawMainScreen
            endif
            
            'Left Arrow / 4
            if (cKey = kLeft) orelse (cKey = "4") then
                mRet = moveCharacter(west)
                if mRet = true then drawMainScreen
            endif
            
            '7
            if cKey = "7" then
                mRet = moveCharacter(northwest)
                if mRet = true then drawMainScreen
            endif
            
            '(G)et an item from the dungeon and add to inventory.
            if cKey = "g" then
                dim inv as inventoryType
                
                'Make sure the character is standing on an item.
                if level.hasItem(player.locX, player.locY) = true then
                    'Check for gold. This is a special case and will be added
                    'to the character's gold total without touching the pack.
                    dim iClass as classIDs = level.getInventoryClassID(player.locX, player.locY)
                    if iClass = iGold then
                        'Get the gold from the map.
                        level.getItemFromMap player.locX, player.locY, inv
                        
                        'Add to gold total.
                        player.currGold = player.currGold + inv.gold.amount
                        player.totGold = player.totGold + inv.gold.amount
                        
                        'Add to experience total.
                        player.currXP = player.currXP + inv.gold.amount
                        player.totXP = player.totXP + inv.gold.amount
                        
                        'Message player.
                        printMessage inv.gold.amount & " gold coins collected."
                        drawMainScreen
                    else
                        'Look for a free inventory slot.
                        dim as integer index = player.getFreeInventoryIndex
                        
                        'If a slot is found, load inventory item.
                        if index <> -1 then
                            level.getItemFromMap player.locX, player.locY, inv
                            
                            'Put it into character inventory.
                            player.addInventoryItem index, inv
                            printMessage "Item added to inventory."
                            'printMessage player.charName & " picks up the item."
                        else
                            'No slots open.
                            printMessage "There is no room in the pack for this item."
                            'printMessage player.charName & "'s pack is full."
                        endif
                    endif
                else
                    printMessage "There is nothing here to pick up."
                endif
            endif
            
            '(I)nventory draws the inventory screen.
            if cKey = "i" then
                manageInventory
                
                'At this point, the background will need to be redrawn.
                drawSolidBackground(cPurple)
                drawMainScreen
            endif
                
            'Descend
            if cKey = ">" then
                'Check to make sure player is actually on stairs down.
                if level.getTileID(player.locX,player.locY) = tStairDown then
                    'Increment the level counter and build a new level.
                    level.levelID = level.levelID + 1
                    level.levelWallColor = dungeonColors(randomRange(1,ubound(dungeonColors)))
                    level.generateDungeonLevel
                    drawMainScreen
                endif
            endif
            
            'Since the player has pressed a key, run the character tick.
            player.tick
            
            'Check whether the character is dead.
            if player.cond <= 0 then
                isDead = TRUE
            endif
        endif
    sleep 1
    loop until (cKey = kESC) or (isDead = TRUE)
endif

'Print dead message.
if isDead = TRUE then
    cls
    print player.charName & " has died."
    sleep
endif
