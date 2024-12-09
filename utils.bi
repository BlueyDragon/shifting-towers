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

'WORD WRAP splits the text of inputString at targetLength, and returns the clipped string.
function WordWrap(inputString as string, targetLength as integer) as string
    dim as integer i = targetLength, stringLength 
    dim as integer backFlag = FALSE
    dim as string stringReturn, targetCharacter

    'Make sure we have something to work with...
    stringLength = len(inputString)
    if stringLength <= targetLength then
        stringReturn = inputString
        inputString = ""
    else
        'Find the breakpoint in the string, backtracking to find
        'a space to break the line at if not at a space.
        do
            'Break is at space, so done.
            targetCharacter = mid(inputString, i, 1)
            if targetCharacter = chr(32) then
                exit do
            endif

            'If not already backtracking, start.
            if backFlag = FALSE then
                if i + 1 <= stringLength then
                    i += 1
                endif
                backFlag = TRUE
            else
                i -= 1
            endif
        loop until i = 0 or targetCharacter = chr(32) 'Backtrack to space.

        'Make sure we still have something to work with...
        if i > 0 then
            'Return clipped string.
            stringReturn = mid(inputString, 1, i)

            'Modify the input string: input, minus the clipped part.
            inputString = mid(inputString, i + 1)
        else
            stringReturn = ""
        endif
    endif

    return stringReturn
end function
