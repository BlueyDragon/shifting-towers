/'****************************************************************************
* intro.bi
* This file contains the intro code.
* by Stephen Gatten
* Last update: June 29, 2014
*****************************************************************************'/
Namespace intro
#include "images/bg-parchment.bi"

const maxAge = 80
const FD = 1 / 60

Dim Shared pal(maxAge) As UInteger = { _
&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4, _
&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4, _
&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4,&hFFF9F7D4, _
&hFFF9F7D4,&hFFF9F6B6,&hFFF8F48E,&hFFF8F364,&hFFF8F139,&hFFF9EC14,&hFFFAD51B,&hFFFCBE22, _
&hFFFDA52A,&hFFFF8C31,&hFFFA802E,&hFFF4752A,&hFFEE6A26,&hFFE95E22,&hFFE3531D,&hFFDE471A, _
&hFFD53613,&hFFCC250D,&hFFC31207,&hFFBB0100,&hFFAC0000,&hFF9D0000,&hFF8E0000,&hFF7F0000, _
&hFF700000,&hFF610000,&hFF5A0000,&hFF550000,&hFF510000,&hFF4D0000,&hFF480000,&hFF440000, _
&hFF3F0000,&hFF3B0000,&hFF370000,&hFF320000,&hFF2E0000,&hFF2A0000,&hFF250000,&hFF210000, _
&hFF1C0000,&hFF180000,&hFF130000,&hFF100000,&hFF0B0000,&hFF070000,&hFF020000,&hFF000000, _
&hFF000000,&hFF000000,&hFF000000,&hFF000000,&hFF000000,&hFF000000,&hFF000000,&hFF000000}
dim shared fire(0 To textColumns - 1, 0 To textRows - 1) As Integer
dim shared coolMap(0 To textColumns - 1, 0 To textRows - 1) As Integer

Function smooth(arr() As Integer, x As Integer, y As Integer) As Integer
    Dim As Integer xx, yy, cnt, v
    
    cnt = 0
    
    v = arr(x, y)
    cnt += 1

    If x < textColumns - 1 Then 
        xx = x + 1
        yy = y
        v += arr(xx, yy)
        cnt += 1
    End If

    If x > 0 Then 
        xx = x - 1
        yy = y
        v += arr(xx, yy)
        cnt += 1
    End If
                
    If y < textRows - 1 Then
        xx = x 
        yy = (y + 1)
        v += arr(x, y + 1)
        cnt += 1
    End If
    
    If y > 0 Then
        xx = x
        yy = (y - 1)
        v += arr(x, y - 1)
        cnt += 1
    End If
    
    v = v / cnt
        
    Return v
End Function

'Moves each particle up on the screen, with a chance of moving side to side.
sub moveParticles
    dim as integer x,y,tAge,xx
    dim as single r
    
    for x = 0 to textColumns - 1
        for y = 1 to textRows - 1
            'Get the current age of the particle.
            tAge = fire(x,y)
            
            'Moves particle left (-1) or right (1) or keeps it in current column (0).
            xx = randomRange(-1,1) + x
            
            'Wrap around the screen.
            if xx < 0 then xx = textColumns - 1
            if xx > textColumns - 1 then xx = 0
            
            'Set the particle age.
            tAge += coolMap(xx, y-1) + 1
            
            'Make sure the age is in range.
            if tAge < 0 then tAge = 0
            if tAge > (maxAge - 1) then tAge = maxAge - 1
            fire(xx, y - 1) = tAge
        next
    next
    
end sub

'Adds particles to the fire along the bottom of the screen.
sub addParticles
    dim as integer x
    
    for x = 0 to textColumns - 1
        fire(x,textRows - 1) = randomRange(0,20)
    next
    
end sub

'Draws the fire or parchment on the screen.
sub drawScreen(egg as integer)
    dim as integer x, y, cAge, tx, ty, wid = 68
    dim as uinteger clr
    dim as string st, tt
    
    screenlock
    moveParticles
    addParticles
    
    for x = 0 to textColumns - 1
        for y = 0 to textRows - 1
            if fire(x,y) < maxAge then
                cAge = smooth(fire(),x,y)
                cAge += 10
                if cAge > maxAge then cAge = maxAge
                
                'if background color is 0, then use fire color
                clr = backParchment(x + y * textColumns)
                
                'check to see if we draw the parchment.
                if clr = &hFF000000 then clr = pal(cAge)
                
                'do the easter egg.
                if egg = true then
                    clr = pal(cAge)
                endif
                
                draw string (x*8,y*8), chr(219), clr
            endif
        next
    next
    
    'Draw the story text.
    tx = 6 * characterWidth
    ty = 3 * characterHeight
    st = "Dear " & player.charName & ","
    drawShadowedText tx, ty, st
    
    ty += (characterHeight * 2)
    st = "My friend and ally... Dark days are upon us and the fires of evil are threatening the beloved land. "
    st &= "But that sort of thing will have to come later, when a story has been written."
    
    do
        tt = wordWrap(st, wid)
        drawShadowedText tx, ty, tt
        ty += characterHeight * 2
    loop until len(tt) = 0
    
    screenunlock
end sub

'Creates a cool map that will combine with the fire value to give a nice effect.
sub createCoolMap
    dim as integer i,j,x,y
    
    for x = 0 to textColumns - 1
        for y = 0 to textRows - 1
            coolmap(x,y) = randomRange(-10,10)
        next
    next
    
    for j = 1 to 10
        for x = 1 to textColumns - 2
            for y = 1 to textRows - 2
                coolmap(x,y) = smooth(coolmap(),x,y)
            next
        next
    next
end sub

'Executes the intro.
sub doIntro()
    dim as single t
    dim as string eg
    dim as integer doegg = false
    
    createCoolMap
    do
        eg = inkey
        if eg = "f" then
            doegg = not doegg
            eg = ""
        endif
        t = timer
        
        'Draws the screen.
        drawScreen doegg
        do while (timer - t) < FD
            sleep 1
        loop
    loop until eg <> ""
    clearKeys
end sub

end namespace
