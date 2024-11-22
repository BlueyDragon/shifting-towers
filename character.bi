'Character screen background.
#include "images/bg-shield.bi"

'Character attribute type definition.
Type CharacterInfo
    cName as string * 40     'Character name
    fe(2) as integer            'Ferocity
    en(2) as integer            'Endurance
    ra(2) as integer            'Radiance
    ag(2) as integer            'Agility
    iq(2) as integer            'Learning
    cond as integer             'Current HP
    hits as integer             'Max HP
    currXP as integer
    totXP as integer
    currGold as integer
    totGold as integer
    locX as integer
    locY as integer
end type

'Character object
Type Character
    private:
        _cInfo as CharacterInfo
    public:
        declare sub PrintStats()
        declare function GenerateCharacter() as integer
end type

'Prints out the current stats for the character
sub Character.PrintStats()
    dim as integer tx, ty, row = 8
    dim as string toWrite

    ScreenLock

    'Draw the background.
    DrawBackground bgShield()

    'Draw the title.
    toWrite = trim(_cInfo.cName) & " Attributes and Skills"
    ty = row * charHeight
    tx = (CenterX(toWrite)) * charWidth
    DrawStringShadow tx, ty, toWrite, cYellow

    'Draw the attributes.
    row += 4
    ty = row * charHeight
    tx = 70
    toWrite = "FEROCITY: " & _cInfo.fe(0)
    DrawStringShadow tx, ty, toWrite

    screenunlock
end sub

'Generates a new character.
function Character.GenerateCharacter() as integer
    dim as string enteredName, prompt, sKey
    dim as integer done = FALSE, ret = TRUE, tx, ty

    'Set up user input prompt.
    prompt = "(R)eroll | (ENTER) Accept | (ESC) Cancel"
    tx = (CenterX(prompt)) * charWidth
    ty = (textRows - 6) * charHeight

    'Get the name of the character.
    do
        cls
        'Using simple input here for now.
        input "Enter your character's name (40 chars max):", enteredName

        'Validate the name here.
        if len(enteredName) > 0 and len(enteredName) < 40 then
            done = TRUE
        else
            'Let the user know what went wrong.
            cls
            if len(enteredName) = 0 then
                print "Name is required. (Press any key.)"
                sleep
                ClearKeys
            endif
            if len(enteredName) > 40 then
                print "Name is too long. 40 chars max. (Press any key.)"
                sleep
                ClearKeys
            endif
        endif
        sleep 10
    loop until done = TRUE

    'Generate the character data.
    done = FALSE
    do
        with _cInfo
            .cName = enteredName
            .fe(0) = RandomRange(3,16)
            .en(0) = RandomRange(3,16)
            .ra(0) = RandomRange(3,16)
            .ag(0) = RandomRange(3,16)
            .iq(0) = RandomRange(3,16)
            .hits = .fe(0) + .en(0)
            .cond = .hits
            .currXP = 0
            .totXP = .currXP
            .currGold = 0
            .totGold = .currGold
            .locX = 0
            .locY = 0
        end with

        'Print out the current rolled character stats.
        PrintStats
        DrawStringShadow tx, ty, prompt

        'Get the user command.
        do
            'Get the keypress
            sKey = inkey

            'Format the keypress to lowercase
            sKey = lcase(sKey)

            'If ESC, exit back to menu.
            if sKey = kEsc then
                done = TRUE
                ret = FALSE
            endif

            'If ENTER, continue with the game
            if sKey = kEnter then
                done = TRUE
            endif

            sleep 10
        loop until (sKey = "r") or (sKey = kEsc) or (sKey = kEnter)
    loop until done = TRUE
    
    return ret
end function

'Set up character variable.
dim shared player as Character