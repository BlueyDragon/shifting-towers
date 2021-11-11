#include "images/bg-title.bi"
#include "defs.bi"

'Displays the game title screen.
Sub DisplayTitle
    dim as string text
    dim as integer tx, ty

    'Set up the copyright notice.
    text = "Studio Draconis (c) 2021"
    tx = (textColumns / 2) - (Len(text) / 2)
    ty = textRows - 2

    'Lock the screen while we update it.
    ScreenLock
    cls

    'Iterate through the array, drawing the block character in the array color.
    for x as integer = 0 to bgWidth - 1
        for y as integer = 0 to bgHeight - 1
            'Get the color from the array using this formula
            dim clr as uinteger = bgTitle(x + y * bgWidth)

            'Use draw string, it's faster and doesn't require locate statements
            draw string (x * charWidth, y * charHeight), gBlock, clr
        next
    next

    'Draw the copyright notice.
    draw string (tx * charWidth, ty * charHeight), text, cYellow

    screenunlock
    sleep

    'Clear the key buffer.
    do:sleep 1:loop while inkey <> ""
end Sub

'Using 640 x 480 32 bit screen with 80x60 text.
screenres 640, 480, 32
width charWidth, charHeight
windowtitle "Feral Tales: The Shifting Towers"

'Draw the title screen.
DisplayTitle
