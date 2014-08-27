/'****************************************************************************
* dungeon.bas
* Main program file for Dungeon of Doom
* by Stephen Gatten
* Last update: July 3, 2014
*****************************************************************************'/

#include "images/bg-title.bi"
#include "defs.bi"
#include "utils.bi"
#include "mainmenu.bi"
#include "character.bi"
#include "inventory.bi"
#include "intro.bi"
#include "map.bi"
#include "vector.bi"
#include "commands.bi"

'Displays the game title screen. This subroutine is obsolete, the game now loads straight into the main menu
Sub DisplayTitle
    Dim As String copyrightText
    Dim As Integer textX, textY
        
    'Set up the copyright notice.
    copyrightText = "(c) 2014 Studio (D)raconis"
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
    titleX = centerX(title)
    drawGlowText (titleX * characterWidth), 0, title, cYellowBright
    
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
    
    'healthPercent = int((player.cond / player.hits) * 100)
    'if healthPercent > 74 then
    '    drawSolidBackground(cGreen)
    'elseif (healthPercent > 24) andalso (healthPercent < 75) then 
    '    drawSolidBackground(cYellow)
    'else
    '    drawSolidBackground(cRed)
    'endif
end sub

'Using 640x480 32 bit screen with 80x60 text.
ScreenRes 640, 480, 32
Width characterWidth, characterHeight
WindowTitle "Forcastia Tales"

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

'Main game loop.
if mm <> mMenu.mQuit then
    'Build the first level of the dungeon.
    level.levelWallColor = dungeonColors(randomRange(1,ubound(dungeonColors)))
    level.LevelID = 1
    level.generateDungeonLevel
    'Main screen turn on
    'drawSolidBackground(cPurple)
    generateLeatherBackground()
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
        endif
    sleep 1
    loop until cKey = kESC
endif
