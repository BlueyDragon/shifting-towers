Namespace intro

#include "images/bg-parchment.bi"

const maxAge = 80
const framerate = 1 / 60

dim shared pal(maxAge) as uinteger = { _
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
dim shared fire(0 to textColumns - 1, 0 to textRows - 1) as integer
dim shared coolmap(0 to textColumns - 1, 0 to textRows - 1) as integer

'SMOOTH averages particle age values.
function Smooth(arr() as integer, x as integer, y as integer) as integer
    dim as integer xx, yy, cnt, v

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

'MOVE PARTICLES moves each particle up on the screen, with a chance of moving side to side.
sub MoveParticles
    dim as integer x, y, particleAge, newX
    dim as single r

    for x = 0 to textColumns - 1
        for y = 1 to textRows - 1
            'Get the current age of the particle.
            particleAge = fire(x, y)

            'Moves particle left (-1), right (1), or keep in same column (0)
            newX = RandomRange(-1, 1) + x

            'Wrap around the screen horizontally.
            if newX < 0 then newX = textColumns - 1
            if newX > textColumns - 1 then newX = 0

            'Set the particle age.
            particleAge += coolmap(newX, y - 1) + 1

            'Make sure the age is in range.
            if particleAge < 0 then particleAge = 0
            if particleAge > (maxAge - 1) then particleAge = maxAge - 1

            fire(newX, y - 1) = particleAge
        next
    next

end sub

'ADD PARTICLES produces new particles along the bottom of the screen.
sub AddParticles
    dim as integer x

    for x = 0 to textColumns - 1
        'Age of the particle can be anything from 0 to 20
        fire(x, textRows - 1) = RandomRange(0,20)
    next

end sub

'DRAW SCREEN draws either the fire effect or the parchment graphic.
sub DrawScreen(displayMode as integer)
    dim as integer x, y, cooledAge, tx, ty, wid = 68
    dim as uinteger clr
    dim as string st, tt

    ScreenLock
    MoveParticles
    AddParticles

    for x = 0 to textColumns - 1
        for y = 0 to textRows - 1
            if fire(x,y) < maxAge then
                cooledAge = Smooth(fire(), x, y)
                cooledAge += 10
                if cooledAge > maxAge then cooledAge = maxAge

                'Check to see if we draw the background - if background color is zero, then use fire color.
                clr = backParchment(x + y * textColumns)
                if clr = &hFF000000 then clr = pal(cooledAge)
                if displayMode = TRUE then clr = pal(cooledAge)

                draw string (x * 8, y * 8), Chr(219), clr
            endif
        next
    next

    'Draw the story text.
    tx = 6 * charWidth
    ty = 3 * charHeight
    st = "Attention all ciphers:"
    DrawStringShadow tx, ty, st

    ty += (charHeight * 2)
    st = "My friend and ally... Dark days are upon us and the fires of evil are threatening the beloved land. "
    st &= "The evil wizard Deboza has escaped from her prison, the magical crystal shard in the center of the Amulet of Crystal Fire."

    do
        tt = WordWrap(st, wid)
        DrawStringShadow tx, ty, tt
        ty += charHeight + 2
    loop until len(tt) = 0

    screenunlock

end sub

'Creates a cool map that will combine with the fire value to give a nice effect.
sub CreateCoolMap
    dim as integer i, j, x, y

    for x = 0 to textColumns - 1
        for y = 0 to textRows - 1
            coolmap(x, y) = RandomRange(-10, 10)
        next
    next

    for j = 1 to 10
        for x = 1 to textColumns - 2
            for y = 1 to textRows - 2
                coolmap(x,y) = Smooth(coolmap(), x, y)
            next
        next
    next

end sub

'DO INTRO executes the game intro.
sub DoIntro()
    dim as single t
    dim as string eg
    dim as integer display = FALSE

    CreateCoolMap
    do
        eg = Inkey
        if eg = "f" then
            display = not display
            eg = ""
        endif

        t = Timer

        'Draws the screen.
        DrawScreen display
        do while (Timer - t) < framerate
            sleep 1
        loop
    loop until eg <> ""
    ClearKeys

end sub

end Namespace