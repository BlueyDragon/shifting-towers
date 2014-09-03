/'****************************************************************************
* mainmenu.bi
* Main menu file.
* by Stephen Gatten
* Last update: June 27, 2014
*****************************************************************************'/

'Wrap this in a namespace, since we only need this at the beginning of the program.
Namespace mMenu

'Background color map.
#include "images/bg-title.bi"

'Menu return values
enum mMenuRet
    mNew
    mLoad
    mInfo
    mQuit
end enum

'Draws the menu to the screen.
sub drawMenu(m() as string, midx as integer, mx as integer, my as integer)
    dim as integer x = mx, y = my
    
    'Iterate through the menu array, drawing items to the screen. The currently selected item is white, while the other items are gray.
    for i as integer = mNew to mQuit
        if midx = i then
            drawShadowedText (x * characterWidth), (y * characterHeight), m(i), cWhite
        else
            drawShadowedText (x * characterWidth), (y * characterHeight), m(i), cGray
        endif
        y += 2
    next
    
end sub

'This draws the menu and returns the selected value.
function mainMenu() as mMenuRet
    dim as mMenuRet idx = mNew
    dim menuItems(mNew to mQuit) as string
    dim as integer mx, my, done = false, tx, ty, cx, cy
    dim as string mkey, mtitle, mVersion, copyrightText
    
    copyrightText = "(c) 2014 Studio (D)raconis"
    cx = centerX(copyrightText)
    cy = textRows - 2
    
    'Set the main menu text.
    menuItems(mNew) = "New Adventure "
    menuItems(mLoad) = "Load Adventure"
    menuItems(mInfo) = "Instructions  "
    menuItems(mQuit) = "Quit          "
    
    'Set the menu items x,y
    mx = centerX(menuItems(3))
    my = centerY(UBound(menuItems) * 2)
    ScreenLock
    
    'Draw the menu background.
    drawBackground bgTitle()
    
    'Draw the title with a drop shadow.
    mTitle = "Forcastia Tales: the Shifting Towers"
    mVersion = "version " & version
    tx = centerX(mtitle) * characterWidth
    ty = (10 * characterHeight)
    drawShadowedText tx, ty, mtitle, cYellowBright
    tx = centerX(mVersion) * characterWidth
    drawShadowedText tx, ty + (characterHeight * 2), mVersion, cYellowBright 
    
    'Draw the copyright notice
    drawShadowedText (cx * characterWidth), (cy * characterHeight), copyrightText, cYellowBright
    
    'Draw the menu text.
    drawMenu menuItems(), idx, mx, my
    screenunlock
    do
        'Get the current key.
        mkey = inkey
        
        'Did the user press a key?
        if mkey <> "" then
            'if user presses escape or the close button, exit with quit id
            if(mkey = kEsc) or (mkey = kClose) then
                idx = mQuit
                done = true
            endif
            
            'if user presses up arrow
            if mkey = kUp then
                'decrement menu index
                idx -= 1
                'wrap around, if need be
                if idx < mNew then idx = mQuit
                'redraw the menu
                screenlock
                drawMenu menuItems(),idx,mx,my
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
                drawMenu menuItems(),idx,mx,my
                screenunlock
            endif
            
            'if user presses enter
            if mkey = kEnter then
                'exit menu.
                done = true
            endif
        endif
        sleep 10
    loop until done = true
    
    'clear any keys.
    clearKeys
    return idx
end function

end Namespace
                    
                
        