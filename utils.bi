'CLEAR KEYS clears the keyboard buffer.
sub ClearKeys
    do:sleep 1:loop while inkey <> ""
end sub

'DRAW BACKGROUND draws a background image using a color map array.
sub DrawBackground(colorMap() as uinteger)
    'Iterate through the array, drawing the block character in the array color.
    for x as integer = 0 to textColumns - 1
        for y as integer = 0 to textRows - 1
            'Get the color from the array using this formula
            dim clr as uinteger = colorMap(x + y * textColumns)

            'Use draw string, it's faster and doesn't require locate statements
            draw string (x * charWidth, y * charHeight), gBlock, clr
        next
    next
end sub

'Print a string with a drop shadow.
sub DrawStringShadow(x as integer, y as integer, text as string, textColor as uinteger = cWhite)
    draw string (x + 1, y + 1), text, cBlack
    draw string (x, y), text, textColor
end sub

'Returns a random number within range
function RandomRange(lowerBound as integer, upperBound as integer) as integer
    return int((upperBound - lowerBound + 1) * rnd + lowerBound)
end function
