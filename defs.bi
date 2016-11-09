'Define true and false
#ifndef false
    #define false 0
#endif

#ifndef true
    #define true -1
#endif

'NULL value.
#Define null 0

'Using 8x8 characters
#define characterWidth 8
#define characterHeight 8

'Text mode 80x60
#Define textColumns 80
#define textRows 60

'Maximum levels in the game
#define maxLevel 50

'Finds center point on the screen.
#define centerX(textToCenter) ((textColumns / 2) - (Len(textToCenter) / 2))
#define centerY(numberOfItems) ((textColumns / 2) - (numberOfItems / 2))

'Returns maximum of two values.
#define imax(a,b) IIf( a > b, a, b )

'Program Version
const version = 0.01

'In-game Title
const title = "F O R C A S T I A  T A L E S:  T H E  S H I F T I N G  T O W E R S"

'Colors
const cBlack = rgb(0,0,0)
Const cBlue = RGB(0,0,255)
const cCrimson = rgb(220,20,60)
const cCyan = rgb(0,255,255)
const cGold = rgb(255,215,0)
Const cGray = RGB(128,128,128)
const cHoneydew = rgb(240,255,240)
const cYellow = rgb(200,200,0)
Const cYellowBright = rgb(255,255,0)
Const cWhite = RGB(255,255,255)
Const cWhite1 = RGB(200,200,200)
Const cWhite2 = RGB(150,150,150)
Const cWhite3 = RGB(100,100,100)
Const cTan = RGB(210,180,140)
Const cSlateGrayDark = RGB(47,79,79)
const cSienna = RGB(160,082,045)
Const cGreen = RGB(0,255,0)
Const cRed = RGB(255,0,0)
Const cPink = RGB(255,0,255)
Const cPurple = RGB(150,0,150)
const cSalmon = rgb(250,128,114)

'Color Bounds, used for random leather color generation
const lowerLimitBlue = 30
const upperLimitBlue = 80
const lowerLimitGreen = 30
const upperLimitGreen = 120
const lowerLimitRed = 210
const upperLimitRed = 255

'Glyphs - ASCII Characters
Const gBlock = Chr(219)
Const gAdventurer = "@"
const gFloor = chr(249)
const gWall = Chr(178)

'Keys
const xk = Chr(255)
const kUp = xk + "H"
const kDown = xk + "P"
const kRight = xk + "M"
const kLeft = xk + "K"
const kClose = xk + "k"
const kEsc = Chr(27)
const kEnter = chr(13)

'Dungeon Environments and Special Tile Descriptions
const dSewer = "the Sewer"
const dSanctum = "the Sanctum"

'dim shared specialSewerArray(1 to 2) as string = { _
'    "This is the first special tile description for the Sewer.", _
'    "This is the second special tile description for the Sewer." }

'Working variables.
Dim As String cKey
Dim As Integer mRet

'Message list.
dim shared mess(1 to 4) as string
dim shared messColor(1 to 4) as uinteger = {cWhite, cWhite1, cWhite2, cWhite3 }

'Dungeon wall colors.
dim shared dungeonColors(1 to 7) as uinteger = {cTan, cGreen, cRed, cPurple, _
cGray, cCrimson, cSienna}

'Leather background colors.
dim shared leatherColors(8) as uinteger = { _
&hFF43260B,&hFF634428,&hFF614224,&hFF614020,&hFF583616,&hFF644324,&hFF583717,&hFF5E3B1A}

