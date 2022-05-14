Namespace mmenu

#include "images/bg-title.bi"

'Menu return values
enum mmenuret
    mNew
    mLoad
    mHelp
    mQuit
end enum

'Draws the menu to the screen.
sub drawMenu(m() as String, index as integer, menuX as integer, menuY as integer)
    dim as integer x = menuX, y = menuY

    'Iterate through the menu array and draw items to the screen.
    for i as integer = mNew to mQuit
        if index = i then
            draw string(x * charWidth, y * charHeight), m(i), cWhite
        else
            draw string(x * charWidth, y * charHeight), m(i), cGray
        endif
        y += 2
    next
end sub

'This renders the menu and returns the selected value.
function mainMenu() as mmenuret
    dim as mmenuret idx = mNew
    dim menuitems(mNew to mQuit) as string
    dim as integer mX, mY, tX, tY, cX, cY, done = FALSE
    dim as string mKey, mTitle, mVers, copy

    'Initialize copyright label.
    copy = "(c) 2014-2022 Studio (D)raconis"
    cX = centerX(copy)
    cY = textRows - 2
    
    'Set the menu text.
    menuItems(mNew) = "New Adventure"
    menuItems(mLoad) = "Load Adventure"
    menuItems(mHelp) = "Instructions"
    menuItems(mQuit) = "Quit Game"

    'Set the menu items location.
    mX = centerX(menuitems(3))
    mY = centerY(ubound(menuitems) * 2)

    ScreenLock

    'Draw the menu background.
    DrawBackground bgTitle()

    'Draw the title with a drop shadow.
    mTitle = "FERAL Tales: The Shifting Towers"
    tX = centerX(mTitle) * charWidth
    tY = (10 * charHeight)
    draw string (tX + 1, tY + 1), mTitle, cBlack
    draw string (tX, tY), mTitle, cYellow
    
    'Draw the version number.
    mVers = "v" & version
    tX = centerX(mVers) * charWidth
    tY += (charHeight * 2)
    draw string (tX + 1, tY + 1), mVers, cBlack
    draw string (tX, tY), mVers, cYellow

    'Draw the copyright notice
    draw string ((cX * charWidth) + 1, (cY * charHeight) + 1), copy, cBlack
    draw string ((cX * charWidth), (cY * charHeight)), copy, cYellow
    
    'Draw the menu text.
    drawMenu menuItems(), idx, mX, mY
    screenunlock
    do
        'Get the current key.
        mKey = inkey
        
        'Did the user press a key?
        if mKey <> "" then
            'if user presses escape or the close button, exit with quit id
            if(mKey = kEsc) or (mKey = kClose) then
                idx = mQuit
                done = TRUE
            endif
            
            'if user presses up arrow
            if mkey = kUp then
                'decrement menu index
                idx -= 1
                'wrap around, if need be
                if idx < mNew then idx = mQuit
                'redraw the menu
                screenlock
                drawMenu menuItems(),idx,mX,mY
                screenunlock
            endif
                
            'if user presses down arrow
            if mkey = kDown then
                'increment menu index
                idx += 1
                'wrap around, if need be
                if idx > mQuit then idx = mNew
                'redraw the menu
                screenlock
                drawMenu menuItems(),idx,mX,mY
                screenunlock
            endif
            
            'if user presses enter
            if mKey = kEnter then
                'exit menu.
                done = TRUE
            endif
        endif
        sleep 10
    loop until done = TRUE
    
    'clear any keys.
    clearKeys
    return idx
end function

end Namespace