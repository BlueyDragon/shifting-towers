#include "images/bg-title.bi"
#include "defs.bi"
#include "utils.bi"
#include "mainmenu.bi"

'Displays the game title screen.
Sub DisplayTitle
    dim as string text
    dim as integer tx, ty

    'Set up the copyright notice.
    text = "Studio Draconis (c) 2021"
    tx = centerX(text)
    ty = textRows - 2

    'Lock the screen while we update it.
    ScreenLock

    'Draw the background image.
    DrawBackground bgTitle()

    'Draw the copyright notice.
    draw string (tx * charWidth, ty * charHeight), text, cYellow

    screenunlock
    sleep
    ClearKeys
end Sub

'Using 640 x 480 32 bit screen with 80x60 text.
screenres 640, 480, 32
width charWidth, charHeight
windowtitle "Feral Tales: The Shifting Towers"

'Draw the title screen.
'DisplayTitle

'Get the menu selection
dim mm as mmenu.mmenuret

'Loop until the user selects something useful
do
    'Draw the main menu.
    mm = mmenu.mainMenu()

    'Process the menu selection.
    if mm = mmenu.mNew then
        'Generate the character.
    elseif mm = mmenu.mLoad then
        'Load the saved game.
    elseif mm = mmenu.mHelp then
        'Print the instructions.
    endif
loop until mm <> mmenu.mHelp


