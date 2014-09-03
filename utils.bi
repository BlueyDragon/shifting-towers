/'****************************************************************************
* utils.bi
* Utility functions for Dungeon of Doom.
* by Stephen Gatten
* Last update: June 26, 2014
*****************************************************************************'/

'Clears keyboard buffer.
Sub clearKeys
    Do: Sleep 1:Loop while inkey <> ""
end sub

'Draws a background image using a color array.
sub drawBackground(cmap() as UInteger)
    'Iterate through the array, drawing the block character in the array color.
    For x as Integer = 0 To textColumns - 1
        For y as Integer = 0 To textRows - 1
            'Get the color from the array using the formula
            Dim clr As UInteger = cmap(x + y * textColumns)
            'Use draw string as it is faster and we don't need to worry about locate statements.
            Draw String (x * characterWidth, y * characterHeight), gBlock, clr
        Next
    Next
end sub

'Draws a background of solid color.
sub drawSolidBackground(clr as UInteger)
    'Iterate through the array, drawing the block character.
    For x as Integer = 0 To textColumns - 1
        For y as Integer = 0 To textRows - 1
            Draw String (x * characterWidth, y * characterHeight), gBlock, clr
        Next
    Next
end sub

'This function returns a random integer within the bounds given.
function randomRange(low as integer, high as integer) as integer
    return int((high - low + 1) * rnd + low)
end function

'This subroutine draws a background simulating a leather design by iterating
'through the screen, drawing the block character in a color randomly picked
'from the leatherColors array defined in defs.bi.
sub generateLeatherBackground()
    dim as uinteger clr
    
    for x as integer = 0 to textColumns - 1
        for y as integer = 0 to textRows - 1
            clr = leatherColors(randomRange(0, ubound(leatherColors) - 1))
            draw string (x * characterWidth, y * characterHeight), gBlock, clr
        next
    next
end sub

'This subroutine draws a background simulating a leather design by iterating
'through the screen, drawing the block character in a randomly-generated color
'using the bounds defined in defs.bi.
sub generateLeatherBackgroundFromRGB()
    dim as uinteger r, g, b, clr
    
    for x as integer = 0 to textColumns - 1
        for y as integer = 0 to textRows - 1
            r = randomRange(lowerLimitRed,upperLimitRed)
            g = randomRange(lowerLimitGreen,upperLimitGreen)
            b = randomRange(lowerLimitBlue,upperLimitBlue)
            clr = rgb(r, g, b)
            draw String (x * characterWidth, y * characterHeight), gBlock, clr
        next
    next
end sub

sub drawShadowedText(x as integer, y as integer, text as string, clr as uinteger = cWhite)
    draw string (x + 1, y + 1), text, cBlack
    draw string (x,y), text, clr
end sub

sub drawGlowText(x as integer, y as integer, text as string, clr as uinteger = cWhite)
    draw string (x + 1, y + 1), text, rgb(0,200,200)
    draw string (x,y), text, clr
end sub

'This subroutine places an empty black block at a specified row and column.
sub placeSpace(column as integer, row as integer)
    dim as integer x, y
    
    x = (column - 1) * characterWidth
    y = (row - 1) * characterHeight
    draw string (x,y), gBlock, cBlack
end sub

'This subroutine places text at a specified row and column.
sub placeGlyph(text as string, column as integer, row as integer, clr as uinteger = cWhite)
    dim as integer x, y
    
    x = (column - 1) * characterWidth
    y = (row - 1) * characterHeight
    draw string (x,y), text, clr
end sub

'This subroutine places text at a specified row and column, with a drop shadow.
sub placeGlyphShadow(text as string, column as integer, row as integer, clr as uinteger = cWhite)
    dim as integer x, y
    
    x = (column - 1) * characterWidth
    y = (row - 1) * characterHeight
    draw string (x + 1, y + 1), text, cBlack
    draw string (x, y), text, clr
end sub

'Returns fast distance calculation between two points.
Function calculateDistance(x1 As Integer, x2 As Integer, y1 As Integer, y2 As Integer) As Integer
    Dim As Integer xdiff, ydiff
    Dim As Integer dist
   
    xdiff = abs(x1 - x2)
    ydiff = abs(y1 - y2)
    dist = (xdiff + ydiff + imax(xdiff, ydiff)) Shr 1
    return dist
End Function

'Splits text InS at sLen and returns clipped string.
Function wordWrap(InS As String, sLen As Integer) As String
    Dim As Integer i = sLen, sl
    Dim As Integer BackFlag = FALSE
    Dim As String sret, ch
    
    'Make sure we have something to work with here.
    sl = Len(InS)
    If sl <= sLen Then
        sret = InS
        InS = ""
    Else
    		'Find the break point in the string, backtracking
    		'to find a space to break the line at if not at a space.
        Do
            'Break is at space, so done.
            ch = Mid(InS, i, 1)
            If ch = Chr(32) Then
                Exit Do
            End If
            'If not backtracking, start backtrack.
            If BackFlag = FALSE Then
                If i + 1 <= sl Then
                    i+= 1
                End If
                BackFlag = TRUE
            Else
                i -= 1
            End If
        Loop Until i = 0 Or ch = Chr(32) 'Backtrack to space.
        'Make sure we still have something to work with.
        If i > 0 Then
        		'Return clipped string.
            sret = Mid(InS, 1, i)
            'Modify the input string: string less clipped.
            InS = Mid(InS, i + 1)
        Else
            sret = ""
        End If 
    End If
    Return sret
End Function
