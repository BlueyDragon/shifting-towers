'DEFINEs, for numeric constants and macros
'TRUE and FALSE
#ifndef FALSE
    #define FALSE 0
#endif
#ifndef TRUE
    'Setting true to -1 allows you to do if not FALSE, which evaluates to -1
    #define TRUE -1
#endif

'Using 8x8 characters.
#define charWidth 8
#define charHeight 8

'Text mode 80x60
#define textColumns 80
#define textRows 60

'Background image size
#define bgWidth 80
#define bgHeight 60

'MACROS, for inline calculations
#define centerX(textToCenter) ((textColumns / 2) - (Len(textToCenter) / 2))
#define centerY(numberOfItems) ((textRows / 2) - (numberOfItems / 2))

'CONSTs, for pre-calculated values
'Program version
const version = 0.03

'COLORS, prefix c
const cBlack = rgb(0,0,0)
const cYellow = rgb(255,255,0)
Const cGray = RGB(128,128,128)
const cWhite = rgb(255,255,255)

'Ascii GLYPHS, prefix g
const gBlock = chr(219)

'KEYCODES
'Inkey returns a two-character string when an extended key (like arrow keys, function keys, etc) is pressed;
'the first character in the string is ASCII value 255 so we use xk to construct extended codes
const xk = chr(255)
const kUp = xk + "H"
const kDown = xk + "P"
const kRight = xk = "M"
Const kLeft = xk + "K"
Const kClose = xk + "k"
Const kEsc = Chr(27)
Const kEnter = Chr(13)

