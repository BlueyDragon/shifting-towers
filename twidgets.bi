/'****************************************************************************
*
* Name: gui.bi
*
* Synopsis: Adds a minimal GUI for input and display.
*
* Description: This file contains a minimal GUI system for input and display of
*              game information.  
*
* Copyright 2010, Richard D. Clark
*
*                          The Wide Open License (WOL)
*
* Permission to use, copy, modify, distribute and sell this software and its
* documentation for any purpose is hereby granted without fee, provided that
* the above copyright notice and this license appear in all source copies. 
* THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY OF
* ANY KIND. See http://www.dspguru.com/wol.htm for more information.
*
*****************************************************************************'/
Namespace tWidgets

'Defines used in tGUI.
Const tFALSE = 0
Const tTRUE = Not tFALSE
Const tNull = 0
'Inkey return codes.
Const xk = Chr(255)
Const KeyRight = xk & "M"
Const KeyLeft = xk & "K"
Const KeyClose = xk + "k"
Const KeyEsc = Chr(27)
Const KeyEnter = Chr(13)
Const KeyHome = xk & "G"
Const KeyEnd = xk & "O"
Const KeyTab = Chr(9)
Const KeyBkspc = Chr(8)
Const KeyDel = xk & "S"

'******************************************************************************************************
'Global System Variables.
'******************************************************************************************************
Dim Shared gtBackColor As UInteger 'Window background color.
Dim Shared gtBackChar As String    'Window background char.
Dim Shared gtinitok As Integer     'Indicates that the window initialized properly.
Dim Shared gtrows As Integer      'Screen text rows.
Dim Shared gtcols As Integer      'Screen text columns.
Dim Shared gtcharw As Integer      'The width of the screen characters.
Dim Shared gtcharh As Integer      'The height of the screen characters.
Dim Shared gtdepth As Integer      'Graphics color depth.
Dim Shared gtgw As Integer         'Graphics width.
Dim Shared gtgh As Integer         'Graphics height.

Sub InitWidgets ()
   'Make sure we are in a graphics mode and the depth is 32bits.
   If ScreenPtr Then
      'Get the current grpahics width, height and color depth.
      ScreenInfo gtgw, gtgh, gtdepth
      'Get the number of text rows and columns.
      gtrows = HiWord(Width())
      gtcols = LoWord(Width())
      'Calculate the character width and height.
      gtcharw = gtgw / gtcols
      gtcharh = gtgh / gtrows
      'Set the init flag.
      gtinitok = tTrue
   Else
      gtinitok = tFalse
   End If
End Sub

'Draws text at specified row and column.
Sub PutText(txt As String, row As Integer, col As Integer, clr As UInteger)
	Dim As Integer x, y
	
	If gtinitok = tTrue Then
	   x = (col - 1) * gtcharw
	   y = (row - 1) * gtcharh
	   Draw String (x, y), txt, clr
	End If
End Sub

'Writes text at specified row and column with shadow.
Sub PutTextShadow(txt As String, row As Integer, col As Integer, clr As UInteger)
	Dim As Integer x, y
	
	x = (col - 1) * gtcharw
	y = (row - 1) * gtcharh
	If gtdepth > 8 Then
	   Draw String (x + 1, y + 1), txt, RGB(0, 0, 0)
	Else
	   Draw String (x + 1, y + 1), txt, 0
	End If
	Draw String (x, y), txt, clr
End Sub

'Centers text on screen.
Function tCenterX OverLoad (txt As String) As Integer
   Return (gtcols / 2) - (Len(txt) / 2)
End Function

'Centers text on screen.
Function tCenterX (lin As Integer) As Integer
   Return (gtcols / 2) - (lin / 2)
End Function

'Centers lengtgh of text between col1 and col2.
Function tCenterX (col1 As Integer, col2 As Integer, txt As String) As Integer
   Dim As Integer c
   
   c = col2 - col1
   Return (col1 + (c / 2)) - (Len(txt) / 2)
End Function

'Centers number of lines on screen.
Function tCenterY (lins As Integer) As Integer
   Return (gtrows / 2) - (lins / 2)
End Function

'******************************************************************************************************
'Button Object
'Draws a button on the screen.
'******************************************************************************************************
Type tButton
   Private:
   _initok As Integer        'Initok.
   _id As Integer            'Button id.
   _row As Integer           'Button row.
   _col As Integer           'Button column.
   _text As String           'Button caption.
   _seltext As String        'Button text when selected.
   _btnselcolor As UInteger  'Selected color.
   _btncolor As UInteger     'Non-selected color.
   _selected As Integer      'Selected flag. tTrue = selected.
   _shadow As Integer        'Shadow flag. tTrue = draw shadow.
   Declare Sub _DestroyButton () 'Clears the button data.
   Public:
   Declare Constructor ()
   Declare Destructor ()
   Declare Property Row (r As Integer)               'Sets button row.
   Declare Property Row () As Integer                'Returns button row.
   Declare Property Col (c As Integer)               'Sets button column.
   Declare Property Col () As Integer                'Returns button column.
   Declare Property Text (s As String)               'Sets button caption.
   Declare Property Text () As String                'Returns button caption.
   Declare Property SelText (s As String)            'Sets selected button caption.
   Declare Property SelText () As String             'Returns selected button caption.
   Declare Property BColor (clr As UInteger)         'Sets non-selected color.
   Declare Property BColor () As UInteger            'Returns non-selected color.
   Declare Property SelColor (clr As UInteger)       'Sets selected color.
   Declare Property SelColor () As UInteger          'Returns selected color.
   Declare Property Selected (b As Integer)          'Sets button to selected state.
   Declare Property Selected () As Integer           'Returns button selected state.
   Declare Property Shadow (s As Integer)            'Sets the shadow flag. 
   Declare Property Shadow () As Integer             'Returns the shadow flag.
   Declare Property ID (i As Integer)                'Sets the button id. 
   Declare Property ID () As Integer                 'Returns the button id. 
   Declare Sub DrawButton ()                         'Draws a button on the screen.
   Declare Sub DestroyButton ()                      'Calls _DestroyButton.
End Type

'Clears button data.
Sub tButton._DestroyButton ()
   _text = ""
   _seltext = ""
End Sub

Constructor tButton ()
   'Make sure system initialized.
   If gtinitok = tTrue Then
      _initok = tTrue
      _text = ""                          'Button caption.
      _selected = tFalse                  'Selected flag.
      _shadow = tTrue                     'Default shadow flag.
      If gtDepth > 8 Then         'Selected color.
         _btnselcolor = RGB(255, 255, 0)
      Else
         _btnselcolor = 14
      End If
      If gtDepth > 8 Then         'Non-selected color.
         _btncolor = RGB(255, 255, 255)
      Else
         _btncolor = 15
      End If
   End If 
End Constructor

Destructor tButton ()
   _DestroyButton
End Destructor

'Sets button row.
Property tButton.Row (r As Integer)
   _row = r
End Property

'Returns button row.
Property tButton.Row () As Integer
   Return _row
End Property

'Sets button column.
Property tButton.Col (c As Integer)
   _col = c
End Property

'Returns button column.
Property tButton.Col () As Integer
   Return _col
End Property

'Sets the button caption.
Property tButton.Text (s As String)
   _text = s
End Property

'Returns the button caption.
Property tButton.Text () As String
   Return _text
End Property

'Sets the button caption.
Property tButton.SelText (s As String)
   _seltext = s
End Property

'Returns the button caption.
Property tButton.SelText () As String
   Return _seltext
End Property

'Sets non-selected color.
Property tButton.BColor (clr As UInteger)
   _btncolor = clr
End Property

'Returns non-selected color.
Property tButton.BColor () As UInteger
   Return _btncolor
End Property

'Sets selected color.
Property tButton.SelColor (clr As UInteger)
   _btnselcolor = clr
End Property

'Returns selected color.
Property tButton.SelColor () As UInteger
   Return _btnselcolor
End Property

'Sets button selected state.
Property tButton.Selected (b As Integer)
   _selected = b
End Property

'Returns button selected state.
Property tButton.Selected () As Integer
   Return _selected
End Property

'Sets the shadow drawing on and off.
Property tButton.Shadow (s As Integer)
   _shadow = s
End Property

'Resturns current shadow flag setting.
Property tButton.Shadow () As Integer
   Return _shadow
End Property

'Sets the button id.
Property tButton.ID (i As Integer)
   _id = i
End Property

'Returns the button id.
Property tButton.ID () As Integer
   Return _id
End Property

'Draws a button on the screen.
Sub tButton.DrawButton ()
   Dim As String ebutt, butt
   Dim As UInteger clr
   Dim As Integer blen = Len(_text)
   

   If _initok = tTrue Then
      'Draw selected color.
      If _selected = tTrue Then 
         clr = _btnselcolor
         butt = _seltext
      Else
         'Draw non-selected color.
         clr = _btncolor
         butt = _text
      EndIf
      'Draw background character.
      ebutt = String(Len(_text), gtBackChar)
      PutText ebutt, _row, _col, gtBackColor
      'Draw the shadow.
      If _shadow = tTrue Then
         'Draw the button.
         PutTextShadow butt, _row, _col, clr
      Else
         'Draw the button.
         PutText butt, _row, _col, clr
      EndIf
   EndIf
End Sub

Sub tButton.DestroyButton () 
   _DestroyButton
End Sub

'******************************************************************************************************
'Window Object
'The base window type. Draws a window on the screen saving the background under
'the window. Buttons can be added to the window by calling Add Button which are drawn on the window. 
'Calling DestroyWindow restores the background. 
'******************************************************************************************************

'Window line styles.
Enum wlinestyle
   wlNone
   wlDoubleLine
   wlSingleLine
   wlDoubleSingleLine
   wlSingleDoubleLine
   wlSolidLine
End Enum

'Title alignment ids.
Enum wtitlealign
   taCenter = 1
   taLeft
   taRight
End Enum

Type tWin
   Private:
   _btnlist(1 To 4) As tButton  'Button list.
   _btncnt As Integer       'The number of buttons on the window.
   _initok As Integer      'Indicates that the window initialized properly.
   _row1 As Integer        'Window text coordinates.
   _col1 As Integer
   _row2 As Integer
   _col2 As Integer
   _x1 As Integer               'Graphics x of col1.
   _y1 As Integer               'Graphics y of row1.
   _x2 As Integer               'Graphics x of col2.
   _y2 As Integer               'Graphics y of row2.
   _title As String             'Title of window.
   _titlealign As wtitlealign   'Title Alignment.
   _titlecolor As UInteger      'Color of title.
   _backcolor As UInteger       'Background color of window.
   _borderfore As UInteger      'Border foreground color.
   _background As Any Ptr       'Background image that is saved before drawing window.
   _linestyle As wlinestyle     'The window line style.
   _tlc As String               'Top left corner character.
   _trc As String               'Top right corner character.
   _brc As String               'Bottom right corner character.
   _blc As String               'Bottom left corner character.
   _tbl  As String              'Top-bottom line character.
   _rll As String               'Right-left line character.
   _bkc As String               'Background character.
   _xk As String
   _shadow As Integer           'Shadow flag. Defalut is tTrue.
   Declare Sub _DestroyWindow() 'Destroys window and restores the background.
   Declare Sub _DrawWindow()    'Draws the window on the screen.
   Public:
   Declare Constructor ()                        'Constructor initializes object.
   Declare Destructor ()                         'Calls _DestroyWindow.
   Declare Property InitOK () As Integer         'Returns the init flag: OK = tTrue, Error = tFalse.
   Declare Property Title(s As String)           'Sets the window title.
   Declare Property Title() As String            'Returns the window title.
   Declare Property AlignTitle(t As wtitlealign) 'Sets the window title alignment.
   Declare Property AlignTitle() As wtitlealign  'Returns the window title alignment.
   Declare Property TitleColor(c As UInteger)    'Sets the window title color.
   Declare Property TitleColor() As UInteger     'Returns the window title color.
   Declare Property LineStyle (ls As wlinestyle) 'Sets the border line style.
   Declare Property LineStyle () As wlinestyle   'Returns the border line style.
   Declare Property BorderColor(clr As UInteger) 'Sets the border color.
   Declare Property BorderColor() As UInteger    'Returns the border color.
   Declare Property BackColor (clr As UInteger)  'Sets the window background color.
   Declare Property BackColor () As UInteger     'Returns the window background color.
   Declare Property RowTop (r As Integer)        'Sets the top row.
   Declare Property RowTop () As Integer         'Returns the top row.
   Declare Property ColLeft (c As Integer)       'Sets the left column.
   Declare Property ColLeft () As Integer        'Returns the left column.
   Declare Property RowBottom (r As Integer)     'Sets the top row.
   Declare Property RowBottom () As Integer      'Returns the top row.
   Declare Property ColRight (c As Integer)      'Sets the right column.
   Declare Property ColRight () As Integer       'Returns the right column.
   Declare Property ColorDepth () As Integer     'Returns the current color depth.
   Declare Property Cols() As Integer            'Returns the number of columns on the screen.
   Declare Property Rows() As Integer            'Returns the number of rows on the screen.
   Declare Property Shadow (s As Integer)                        'Sets the shadow drawing on and off.
   Declare Property Shadow () As Integer                         'Returns current shadow flag setting.
   Declare property ButtonSelected (index As Integer, sel As Integer) 'Sets or clears button selection state.
   Declare property ButtonSelected (index As Integer) As Integer      'Returns button selected state.
   Declare Sub DestroyWindow ()                                  'Calls _DestroyWindow.
   Declare Sub DrawWindow()                                      'Calls _DrawWindow.
   Declare Sub DrawButton(index As Integer)                      'Draws indexed button.
   Declare Function AddButton (btn As tButton) As Integer 'Adds a button to the window returning the button index.
End Type

'Restores the saved background image and releases the resource.
Sub tWin._DestroyWindow()
   If _background <> tNull Then
      Put (_x1, _y1), _background, PSet 
      ImageDestroy _background
      _background = tNull
   EndIf
   'Clear the string space.
   _title = ""
   _tlc = ""
   _trc = ""
   _brc = ""
   _blc = ""
   _tbl = ""
   _rll = ""
   _bkc = ""
   _xk = ""
End Sub

'The object constructor initializes the window object.
Constructor tWin
   
   _initok = gtinitok
   If _initok = tTrue Then
      _btncnt = 0
      'Set the default title settings.
      _title = ""             
      _titlealign = taCenter   
      'Set the default window size.
      _row1 = 1
      _row2 = gtrows - 2
      _col1 = 1
      _col2 = gtcols - 2
      'Set the background pointer to null.
      _background = 0
      'Set the default line style.
      _linestyle = wlDoubleLine
      'Set the default border characters.
      _tlc = Chr(201)
      _trc = Chr(187)
      _brc = Chr(188)
      _blc = Chr(200)
      _tbl = Chr(205)
      _rll = Chr(186)
      _bkc = Chr(219)
      gtBackChar = _bkc 
      'Set the default colors.
      If gtDepth > 8 Then
         _backcolor = RGB (0, 0, 128)
         gtBackColor = RGB (0, 0, 128)
         _borderfore = RGB(255, 255, 0)
      Else
         'Use 8bit colors.
         _backcolor = 1
         gtBackColor = 1
         _borderfore = 14
      End If
      _titlecolor = _borderfore 'Set deafult title color.
      _shadow = tTrue           'Default is to draw the shadow.
   EndIf
End Constructor

'Object destructor.
Destructor tWin
   _DestroyWindow
End Destructor

'Draws the window on the screen.
Sub twin._DrawWindow()    
   Dim As Integer i, tx 
   Dim As String lne, wtitle = _title, ecl, ecr

	If _initok = tTrue Then
	   'Make sure the coords are in the right order.
	   If _col2 < _col1 Then Swap _col2, _col1
	   If _row2 < _row1 Then Swap _row2, _row1
	   'Force the row column to fit the screen.
	   If _col1 < 1 Then _col1 = 1
	   If _col2 > gtcols Then _col2 = gtcols - 1
	   If _row1 < 1 Then _row1 = 1
	   If _row2 > gtrows Then _row2 = gtrows - 1
      'Save the background under window.
      _x1 = (_col1 - 1) * gtcharw
      _x2 = ((_col2 + 2) - 1) * gtcharw
      _y1 = (_row1 - 1) * gtcharh
      _y2 = ((_row2 + 2) - 1) * gtcharh
      'Force the x,y to screen.
      If _x1 < 0 Then _x1 = 0
      If _x2 > gtgw - 1 Then _x2 = gtgw - 1 
      If _y1 < 0 Then _y1 = 0
      If _y2 > gtgh - 1 Then _y2 = gtgh - 1 
      'Grab the background.
      _background = ImageCreate((_x2 - _x1) + 1, (_y2 - _y1) + 1) 
      Get (_x1, _y1) - (_x2, _y2), _background
      'Build string for each line.
      lne = String((_col2 - _col1) + 1, _bkc)
      'First clear the box area with background color.
      For i = _row1 To _row2
         PutText lne, i, _col1, _backcolor
      Next
      'Print the top row.
      lne = _tlc
      lne &= String((_col2 - _col1) - 1, _tbl)
      lne &= _trc
      PutText lne, _row1, _col1, _borderfore
      'Print the sides.
      lne = _rll
      For i = _row1 + 1 To _row2 - 1
         PutText lne, i, _col1, _borderfore
         PutText lne, i, _col2, _borderfore
      Next
      'Print bottom row.
      lne = _blc
      lne &= String((_col2 - _col1) - 1, _tbl)
      lne &= _brc
      PutText lne, _row2, _col1, _borderfore
      'Print the title if any.
      If Len(wtitle) > 0 Then
         'Make sure the title will fit.
         If Len(wtitle) > (_col2 - _col1) - 5 Then
            wtitle = Trim(Mid(wtitle, 1, (_col2 - _col1) - 5))
         EndIf
         'Set the title markers based on box type.
         If (_linestyle = wlDoubleLine) OrElse (_linestyle = wlDoubleSingleLine)  Then
            ecl = Chr(181) & Chr(32)
            ecr = Chr(32) & Chr(198) 
         ElseIf (_linestyle = wlSingleLine) OrElse (_linestyle = wlSingleDoubleLine) Then
            ecl = Chr(180) & Chr(32)
            ecr = Chr(32) & Chr(195)
         Else
            ecl = String(2, 32)
            ecr = String(2, 32)
         EndIf
         'Align title to left.
         If _titlealign = taLeft Then
            tx = _col1 + 1
         'Align title to right.
         ElseIf _titlealign = taRight Then
            tx = _col2 - (Len(ecl & wtitle & ecr))
         'Center title.   
         Else
            tx = tCenterX(_col1, _col2, ecl & wtitle & ecr)
         EndIf
      EndIf
      'Draw the title.
      If _shadow = tTrue Then
         'Make a space for the title.
         PutText String(Len(ecl & wtitle & ecr), _bkc), _row1, tx, _backcolor
         'Draw the title.
         PutText ecl, _row1, tx, _borderfore
         PutTextShadow wtitle, _row1, tx + 2, _titlecolor 
         PutText ecr, _row1, tx + 2 + Len(wtitle), _borderfore
      Else
         'Make a space for the title.
         PutText String(Len(ecl & wtitle & ecr), _bkc), _row1, tx, _backcolor
         'Draw the title.
         PutText ecl, _row1, tx, _borderfore
         PutText wtitle, _row1, tx + 2, _titlecolor 
         PutText ecr, _row1, tx + 2 + Len(wtitle), _borderfore
      EndIf
      'Draw the buttons if any.
      For i = 1 To _btncnt
         _btnlist(i).DrawButton
      Next
      'Check the shadow flag.
      If _shadow = tTrue Then
         'Draw the shadow along bottom.
         lne = String((_col2 - _col1) + 1, 177)
         If gtDepth > 8 Then
            PutText lne, _row2 + 1, _col1 + 1, RGB(0, 0, 0)
         Else
            PutText lne, _row2 + 1, _col1 + 1, 0
         End If
         'Draw shadow along the side.
         lne = Chr(177)
         For i = _row1 + 1 To _row2
            If gtDepth > 8 Then
               PutText lne, i, _col2 + 1, RGB(0, 0, 0)
            Else
               PutText lne, i, _col2 + 1, 0
            End If
         Next
      End If
	End If
End Sub

'Sets the window title.
Property tWin.Title(s As String)
   _title = Trim(s)
End Property

'Returns the window title.
Property tWin.Title() As String
   Return _title
End Property

'Sets the window title alignment.
Property tWin.AlignTitle(t As wtitlealign)
   _titlealign = t
End Property

'Returns the window title alignment.
Property tWin.AlignTitle() As wtitlealign
   Return _titlealign
End Property

'Sets the window title color.
Property tWin.TitleColor(c As UInteger)
   _titlecolor = c
End Property

'Returns the window title color.
Property tWin.TitleColor() As UInteger
   Return _titlecolor
End Property

'Sets the border line style.
Property tWin.LineStyle (ls As wlinestyle)
   _linestyle = ls
   
   Select Case _linestyle
      Case wlDoubleLine
         _tlc = Chr(201)
         _trc = Chr(187)
         _brc = Chr(188)
         _blc = Chr(200)
         _tbl = Chr(205)
         _rll = Chr(186)
      Case wlSingleLine
         _tlc = Chr(218)
         _trc = Chr(191)
         _brc = Chr(217)
         _blc = Chr(192)
         _tbl = Chr(196)
         _rll = Chr(179)
      Case wlDoubleSingleLine
         _tlc = Chr(213)
         _trc = Chr(184)
         _brc = Chr(190)
         _blc = Chr(212)
         _tbl = Chr(205)
         _rll = Chr(179)
      Case wlSingleDoubleLine
         _tlc = Chr(214)
         _trc = Chr(183)
         _brc = Chr(189)
         _blc = Chr(211)
         _tbl = Chr(196)
         _rll = Chr(186)
      Case wlSolidLine
         _tlc = Chr(219)
         _trc = Chr(219)
         _brc = Chr(219)
         _blc = Chr(219)
         _tbl = Chr(219)
         _rll = Chr(219)
      Case Else
         _tlc = Chr(32)
         _trc = Chr(32)
         _brc = Chr(32)
         _blc = Chr(32)
         _tbl = Chr(32)
         _rll = Chr(32)
   End Select
End Property

'Returns the border line style.
Property tWin.LineStyle () As wlinestyle 
   Return _linestyle
End Property

'Sets the border color.
Property tWin.BorderColor(clr As UInteger)
   _borderfore  = clr
End Property

'Returns the border color.
Property tWin.BorderColor() As UInteger
   Return _borderfore
End Property

'Sets the window background color.
Property tWin.BackColor (clr As UInteger)
   _backcolor  = clr
   gtBackColor = clr
End Property

'Returns the window background color.
Property tWin.BackColor () As UInteger
   Return _backcolor
End Property

'Sets the top row.
Property tWin.RowTop (r As Integer)
   _row1 = r
End Property

'Returns the top row.
Property tWin.RowTop () As Integer
   Return _row1
End Property

'Sets the left column.
Property tWin.ColLeft (c As Integer)
   _col1 = c
End Property

'Returns the left column.
Property tWin.ColLeft () As Integer
   Return _col1
End Property

'Sets the top row.
Property tWin.RowBottom (r As Integer)
   _row2 = r
End Property

'Returns the top row.
Property tWin.RowBottom () As Integer
   Return _row2
End Property

'Sets the left column.
Property tWin.ColRight (c As Integer)
   _col2 = c
End Property

'Returns the right column.
Property tWin.ColRight () As Integer
   Return _col2
End Property

'Returns the init flag: OK = tTrue, Error = tFalse.
Property tWin.InitOK () As Integer 
   Return _initok
End Property

'Returns the current color depth.
Property tWin.ColorDepth () As Integer
   Return gtDepth
End Property

'Returns the number of columns on the screen.
Property tWin.Cols() As Integer
   Return gtcols
End Property

'Returns the number of rows on the screen.
Property tWin.Rows() As Integer
   Return gtrows
End Property

'Sets the shadow drawing on and off.
Property tWin.Shadow (s As Integer)
   _shadow = s
End Property

'Resturns current shadow flag setting.
Property tWin.Shadow () As Integer
   Return _shadow
End Property
'Sets or clears button selection state.
Property tWin.ButtonSelected (index As Integer, sel As Integer)
   If (index >= 1) And (index <= _btncnt) Then
      _btnlist(index).Selected = sel
   EndIf
End Property

'Returns button selected state.
Property tWin.ButtonSelected (index As Integer) As Integer      
   If (index >= 1) And (index <= _btncnt) Then
      Return _btnlist(index).Selected
   EndIf
End Property

'Draws indexed button.
Sub tWin.DrawButton(index As Integer)
   If (index >= 1) And (index <= _btncnt) Then
      _btnlist(index).DrawButton
   EndIf
End Sub

'Calls _DrawWindow
Sub tWin.DrawWindow()
   _DrawWindow  
End Sub

'Calls _DestroyWindow
Sub tWin.DestroyWindow()
   _DestroyWindow
End Sub

'Adds a button to the window returning the button index.
Function tWin.AddButton (btn As tButton) As Integer 
   _btncnt += 1
   If _btncnt <= UBound(_btnlist) Then
      _btnlist(_btncnt) = btn
   End If
   Return _btncnt
End Function

'******************************************************************************************************
'Message Box Object
'Displays a message box centered on the screen and returns the selected button id.
'******************************************************************************************************

'GUI button ids
Enum btnID
   gbnNone
   gbnOK
   gbnYes
   gbnNo
   gbnCancel
End Enum

'GUI messagebox type.
Enum MsgBoxType
   gmbOK = 1
   gmbOKCancel
   gmbYesNo
   gmbYesNoCancel
End Enum

Type tMsgbox
   Private:
   _win As tWin                'Window object.
   _winstyle As wlinestyle     'Window style.
   _msgstyle As MsgBoxType     'Msgbox type.
   _btncolor As UInteger       'Non-selected button color.
   _btnselcolor As UInteger    'Selected button color.
   _promptcolor As UInteger    'Color of the message.
   _btn1 As tButton            'Button 1.
   _btn2 As tButton            'Button 2.
   _btn3 As tButton            'Button 3.
   Public:
   Declare Constructor ()
   Declare Property WindowStyle (wstyle As wlinestyle)      'Sets the window style.
   Declare Property WindowStyle () As wlinestyle            'Returns the window style.
   Declare Property MessageStyle (m As MsgBoxType)          'Sets the msgbox style.
   Declare Property MessageStyle () As MsgBoxType           'Returns the msgbox style.
   Declare Property BackgroundColor (clr As UInteger)       'Sets background color.
   Declare Property BackgroundColor () As UInteger          'Returns background color.
   Declare Property BorderColor (clr As UInteger)           'Sets the border color.
   Declare Property BorderColor () As UInteger              'Returns the border color.
   Declare Property ButtonSelectColor (clr As UInteger)     'Sets the color of the selected button.
   Declare Property ButtonSelectColor () As UInteger        'Returns the color of the selected button.
   Declare Property ButtonColor (clr As UInteger)           'Sets the color of the non-selected button.
   Declare Property ButtonColor () As UInteger              'Returns the color of the non-selected button.
   Declare Property PromptColor (clr As UInteger)           'Sets the prompt forecolor.
   Declare Property PromptColor () As UInteger              'Return the prompt forecolor.
   Declare Property Title(s As String)                      'Sets the window title.
   Declare Property Title() As String                       'Returns the window title.
   Declare Property AlignTitle(t As wtitlealign)            'Sets the window title alignment.
   Declare Property AlignTitle() As wtitlealign             'Returns the window title alignment.
   Declare Property TitleColor(c As UInteger)               'Sets the window title color.
   Declare Property TitleColor() As UInteger                'Returns the window title color.
   Declare Property Shadow (s As Integer)                   'Sets the shadow flag. 
   Declare Property Shadow () As Integer                    'Returns the shadow flag. 
   Declare Function MessageBox (prompt As String) As btnID  'Draws messagebox on screen.
End Type

'Initalizes the object.
Constructor tMsgbox ()
   If _win.InitOk = tTrue Then
      _msgstyle = gmbOK                  'Default msgbox style is single OK button.
      If _win.ColorDepth > 8 Then        'Default colors.
         _btncolor = RGB(255, 255, 255)
         _btnselcolor = RGB(255, 255, 0)
         _promptcolor = RGB(255, 255, 255)
      Else
         _btncolor = 15
         _btnselcolor = 14
         _promptcolor = 15
      End If
   End If
End Constructor

'Sets the window line style.
Property tMsgbox.WindowStyle (wstyle As wlinestyle)
   _win.LineStyle = wstyle
End Property

'Returns the window line style.
Property tMsgbox.WindowStyle () As wlinestyle
   Return _win.LineStyle 
End Property

'Sets the msgbox style.
Property tMsgbox.MessageStyle(m As MsgBoxType)
   _msgstyle = m
   If _msgstyle < gmbOK Then _msgstyle = gmbOK
   If _msgstyle > gmbYesNoCancel Then _msgstyle = gmbYesNoCancel 
End Property

'Returns the msgbox style.
Property tMsgbox.MessageStyle() As MsgBoxType
   Return _msgstyle
End Property

'Sets background color.
Property tMsgBox.BackgroundColor (clr As UInteger)
   _win.BackColor = clr
End Property

'Returns the background color.
Property tMsgbox.BackgroundColor () As UInteger
   Return _win.Backcolor
End Property

'Sets the border color.
Property tMsgbox.BorderColor (clr As UInteger)
   _win.BorderColor = clr
End Property

'Returns the border color.
Property tMsgbox.BorderColor () As UInteger
   Return _win.BorderColor
End Property

'Sets the color of the selected button.
Property tMsgbox.ButtonSelectColor (clr As UInteger)
   _btnselcolor = clr
End Property

'Returns the color of the selected button.
Property tMsgbox.ButtonSelectColor () As UInteger
   Return _btnselcolor
End Property

'Sets the color of the non-selected button.
Property tMsgbox.ButtonColor (clr As UInteger)
   _btncolor = clr
End Property

'Returns the color of the non-selected button.
Property tMsgbox.ButtonColor () As UInteger
   Return _btncolor
End Property

'Sets the prompt forecolor.
Property tMsgBox.PromptColor (clr As UInteger)
   _promptcolor = clr
End Property

'Returns the prompt forecolor.
Property tMsgBox.PromptColor () As UInteger
   Return _promptcolor
End Property

'Sets the window title.
Property tMsgBox.Title(s As String)
   _win.Title = s
End Property

'Returns the window title.
Property tMsgBox.Title() As String
   Return _win.Title
End Property

'Sets the window title alignment.
Property tMsgBox.AlignTitle(t As wtitlealign)
   _win.AlignTitle = t
End Property

'Returns the window title alignment.
Property tMsgBox.AlignTitle() As wtitlealign
   Return _win.AlignTitle
End Property

'Sets the window title color.
Property tMsgBox.TitleColor(c As UInteger)
   _win.TitleColor = c
End Property

'Returns the window title color.
Property tMsgBox.TitleColor() As UInteger
   Return _win.TitleColor
End Property

'Sets the shadow drawing on and off.
Property tMsgBox.Shadow (s As Integer)
   _win.Shadow = s
End Property

'Resturns current shadow flag setting.
Property tMsgBox.Shadow () As Integer
   Return _win.Shadow
End Property

'Draws a message box on the screen and returns the button id.
'Prompt is the message prompt.
Function tMsgbox.MessageBox(prompt As String) As btnID
   Dim As btnID btn, activebtn
   Dim As String btn1, btn2, btn3, prcopy = prompt, ch
   Dim As Integer lprompt = Len(prompt), row1, col1, row2, col2
   Dim As Integer prow, pcol, btnrow, btn1col, btn2col, btn3col
   Dim As Integer bidx1, bidx2, bidx3
   
   If _win.InitOK = tTrue Then
      ScreenLock
      'Draw the box.
      If lprompt < 30 Then lprompt = 30
      'If the prompt is too long, trim it.
      If lprompt > (_win.Cols - 4) Then
         prcopy = Mid(prcopy, 1, _win.Cols - 4)
         lprompt = Len(prcopy)
      EndIf
      'Calculate the screen center point of the prompt.
      prow = tCenterY(6) - 2
      pcol = tCenterX(prcopy)
      'Build the box around the prompt.
      row1 = prow - 2
      row2 = prow + 4
      col1 = tCenterX(lprompt) - 2
      col2 = col1 + lprompt + 3
      'Set the window dimensions.
      _win.RowTop = row1
      _win.ColLeft = col1
      _win.RowBottom = row2
      _win.ColRight = col2
      'Draw the OK, Cancel buttons.
      btnRow = row2 - 2
      'Set the messagebox buttons.
      'OK
      If _msgstyle = gmbOK Then
         btn1 = "[ OK ]"
         activebtn = gbnOK
         
         _btn1.Text = btn1
         _btn1.SelText = "< OK >"
         _btn1.Row = btnrow
         _btn1.Col = tCenterX(col1, col2, btn1)
         _btn1.Selected = tTrue
         _btn1.BColor = _btncolor
         _btn1.SelColor = _btnselcolor
         _btn1.Shadow = _win.Shadow
         _btn1.ID = gbnOK
         bidx1 = _win.AddButton(_btn1)
      EndIf
      'OK-Cancel
      If _msgstyle = gmbOKCancel Then
         btn1 = "[ OK ]"
         btn2 = " [ Cancel ]"
         btn1col = tCenterX(col1, col2, btn1 & btn2)
         btn2col = btn1col + Len(btn1)
         activebtn = gbnOK

         _btn1.Text = btn1
         _btn1.SelText = "< OK >"
         _btn1.Row = btnrow
         _btn1.Col = btn1col
         _btn1.Selected = tTrue
         _btn1.BColor = _btncolor
         _btn1.SelColor = _btnselcolor
         _btn1.Shadow = _win.Shadow
         _btn1.ID = gbnOK
         bidx1 = _win.AddButton(_btn1)

         _btn2.Text = btn2
         _btn2.SelText = " < Cancel >"
         _btn2.Row = btnrow
         _btn2.Col = btn2col
         _btn2.Selected = tFalse
         _btn2.BColor = _btncolor
         _btn2.SelColor = _btnselcolor
         _btn2.Shadow = _win.Shadow
         _btn2.ID = gbnCancel
         bidx2 = _win.AddButton(_btn2)
      EndIf
      'Yes-No
      If _msgstyle = gmbYesNo Then
         btn1 = "[ Yes ]"
         btn2 = " [ No ]"
         btn1col = tCenterX(col1, col2, btn1 & btn2)
         btn2col = btn1col + Len(btn1)
         activebtn = gbnYes
         
         _btn1.Text = btn1
         _btn1.SelText = "< Yes >"
         _btn1.Row = btnrow
         _btn1.Col = btn1col
         _btn1.Selected = tTrue
         _btn1.BColor = _btncolor
         _btn1.SelColor = _btnselcolor
         _btn1.Shadow = _win.Shadow
         _btn1.ID = gbnYes
         bidx1 = _win.AddButton(_btn1)

         _btn2.Text = btn2
         _btn2.SelText = " < No >"
         _btn2.Row = btnrow
         _btn2.Col = btn2col
         _btn2.Selected = tFalse
         _btn2.BColor = _btncolor
         _btn2.SelColor = _btnselcolor
         _btn2.Shadow = _win.Shadow
         _btn2.ID = gbnNo
         bidx2 = _win.AddButton(_btn2)
      EndIf
      'Yes-No-Cancel
      If _msgstyle = gmbYesNoCancel Then
         btn1 = " [ Yes ]"
         btn2 = " [ No ]"
         btn3 = " [ Cancel ]" 
         btn1col = tCenterX(col1, col2, btn1 & btn2 & btn3)
         btn2col = btn1col + Len(btn1)
         btn3col = btn1col + Len(btn1) + Len(btn2)
         activebtn = gbnYes
         
         _btn1.Text = btn1
         _btn1.SelText = " < Yes >"
         _btn1.Row = btnrow
         _btn1.Col = btn1col
         _btn1.Selected = tTrue
         _btn1.BColor = _btncolor
         _btn1.SelColor = _btnselcolor
         _btn1.Shadow = _win.Shadow
         _btn1.ID = gbnYes
         bidx1 = _win.AddButton(_btn1)

         _btn2.Text = btn2
         _btn2.SelText = " < No >"
         _btn2.Row = btnrow
         _btn2.Col = btn2col
         _btn2.Selected = tFalse
         _btn2.BColor = _btncolor
         _btn2.SelColor = _btnselcolor
         _btn2.Shadow = _win.Shadow
         _btn2.ID = gbnNo
         bidx2 = _win.AddButton(_btn2)

         _btn3.Text = btn3
         _btn3.SelText = " < Cancel >"
         _btn3.Row = btnrow
         _btn3.Col = btn3col
         _btn3.Selected = tFalse
         _btn3.BColor = _btncolor
         _btn3.SelColor = _btnselcolor
         _btn3.Shadow = _win.Shadow
         _btn3.ID = gbnCancel
         bidx3 = _win.AddButton(_btn3)
      EndIf
      'Draw the window.
      _win.DrawWindow
      'Draw the prompt.
      PutText prcopy, prow, pcol, _promptcolor
      ScreenUnlock
      'Get the input.
      Do
         ch = Inkey
         If ch <> "" Then
            'Process enter key.
            If ch = KeyEnter Then
               btn = activebtn
            EndIf
            'Process escape key.
            If ch = KeyEsc Then
               btn = gbnCancel
            EndIf
            'Process tab key.
            If ch = KeyTab Then
               'OK-Cancel messagebox type.
               If _msgstyle = gmbOKCancel Then
                  'Increment the button index.
                  If activebtn = gbnOK Then
                     activebtn = gbnCancel
                     'Toggle selected state.
                     _win.ButtonSelected(bidx1) = tFalse 
                     _win.ButtonSelected(bidx2) = tTrue 
                  Else
                     activebtn = gbnOK
                     'Toggle selected state.
                     _win.ButtonSelected(bidx1) = tTrue 
                     _win.ButtonSelected(bidx2) = tFalse 
                  EndIf
                  'Redraw the buttons.
                  _win.DrawButton(bidx1)
                  _win.DrawButton(bidx2)
               EndIf
               'Yes-No messagebox type.
               If _msgstyle = gmbYesNo Then
                  'Increment the button index.
                  If activebtn = gbnYes Then
                     activebtn = gbnNo
                     'Toggle selected state.
                     _win.ButtonSelected(bidx1) = tFalse 
                     _win.ButtonSelected(bidx2) = tTrue 
                  Else
                     activebtn = gbnYes
                     'Toggle selected state.
                     _win.ButtonSelected(bidx1) = tTrue 
                     _win.ButtonSelected(bidx2) = tFalse 
                  EndIf
                  'Redraw the buttons.
                  _win.DrawButton(bidx1)
                  _win.DrawButton(bidx2)
               EndIf
               'Yes-No-Cancel messagebox type.
               If _msgstyle = gmbYesNoCancel Then
                  'Increment the button index.
                  If activebtn = gbnYes Then
                     activebtn = gbnNo
                     'Toggle selected state.
                     _win.ButtonSelected(bidx1) = tFalse 
                     _win.ButtonSelected(bidx2) = tTrue 
                     _win.ButtonSelected(bidx3) = tFalse 
                  ElseIf activebtn = gbnNo Then
                     activebtn = gbnCancel
                     'Toggle selected state.
                     _win.ButtonSelected(bidx1) = tFalse 
                     _win.ButtonSelected(bidx2) = tFalse 
                     _win.ButtonSelected(bidx3) = tTrue 
                  ElseIf activebtn = gbnCancel Then
                     activebtn = gbnYes
                     'Toggle selected state.
                     _win.ButtonSelected(bidx1) = tTrue 
                     _win.ButtonSelected(bidx2) = tFalse 
                     _win.ButtonSelected(bidx3) = tFalse 
                  EndIf
                  'Redraw the buttons.
                  _win.DrawButton(bidx1)
                  _win.DrawButton(bidx2)
                  _win.DrawButton(bidx3)
               EndIf
            EndIf
         EndIf
         Sleep 1
      Loop Until (btn = gbnOK) Or (btn = gbnCancel) Or (btn = gbnYes) Or (btn = gbnNo)
   End If
   'Destroy window and restoe background.
   _win.DestroyWindow
       
   Return btn
End Function

'******************************************************************************************************
'Edit field Object
'Displays an edit field on the screen and returns the the entered data. 
'******************************************************************************************************

'Widget key ids
Enum tKeys
   gkyNone 
   gkyEsc
   gkyEnter
   gkyTab
End Enum

Type tEdit
   Private:
   _text As String                             'Edit text.
   _maxlen As Integer                          'Maximum lengtgh of the text. 0 = unlimited.
   _inputlen As Integer                        'The number of characters of the input field.
   _textcolor As UInteger                      'The color of the text.
   _inputcolor As UInteger                     'The color of the input field.
   _inputchar As String                        'The character to use for the input field.
   _caretcolor As UInteger                      'The color of the caret.
   _caret As String                            'The caret character.
   _caretins As String                         'The caret character when insert is active.
   _insert As Integer                          'Insert flag.
   _row As Integer                             'Row of input field.
   _col As Integer                             'Col of input field.
   _mask As String                             'Input mask.
   Declare Function _Substr(tstart As Integer, tend As Integer) As String 'Returns substr of _text from tstart to tend.
   Declare Function _Paint (tstart As Integer, tend As Integer) As Integer 'Paints the edit field. Returns position 1 past input string.
   Declare Sub _DeleteChar(index As Integer)  'Delete character at index in _text.
   Public:
   Declare Constructor ()                      'Initialze the object.
   Declare Destructor ()                       'Clean up object.
   Declare Property Row(r As Integer)          'Sets row of input field.
   Declare Property Row() As Integer           'Returns row of input field.
   Declare Property Col(c As Integer)          'Sets column of input field.
   Declare Property Col() As Integer           'Returns column of input field.
   Declare Property Text (t As String)         'Sets the text property.
   Declare Property Text () As String          'Returns the text.
   Declare Property EditMask (t As String)         'Sets the mask property.
   Declare Property EditMask () As String          'Returns the mask.
   Declare Property MaxLen(m As Integer)       'Sets the max lengtgh of input text. 0 = unlimited.
   Declare Property MaxLen() As Integer        'Returns the max lengtgh of input text. 0 = unlimited.
   Declare Property InputLen (i As Integer)    'Sets the lengtgh of the input field. Default is 10 chars. 
   Declare Property InputLen () As Integer     'Returns the lengtgh of the input field. Default is 10 chars.
   Declare Property TextColor (c As UInteger)  'Sets the color of the text.
   Declare Property TextColor () As UInteger   'Returns the color of the text.
   Declare Property InputColor (c As UInteger) 'Sets the color of the input field. 
   Declare Property InputColor () As UInteger  'Returns the color of the input field.
   Declare Property InputChar (c As Integer)   'Sets the input field to ascci code character. 
   Declare Property InputChar () As Integer    'Returns the input field ascci code character.
   Declare Property CaretColor (c As UInteger) 'Sets the caret color.
   Declare Property CaretColor () As UInteger  'Returns the caret color.
   Declare Property Caret (c As Integer)       'Sets the caret to ascii code character.
   Declare Property Caret () As Integer        'Returns the caret ascii code.
   Declare Property CaretIns (c As Integer)    'Sets the insert caret to ascii code character.
   Declare Property CaretIns () As Integer     'Returns the insert caret ascii code.
   Declare Function DrawEdit () As tKeys       'Draws te edit field and returns the key command. 
End Type

'Returns substr of _text from tstart to tend.
Function tEdit._Substr(tstart As Integer, tend As Integer) As String 
   Dim As String ret = _text
   Dim As Integer lentext = Len(_text)
   
   'Make sure we have some text.
   If lentext > 0 Then
      'Make sure tstart is less than tend.
      If tstart < tend Then
         'Make sure tstart and tend contain valid values.
         If (tstart >= 1) And (tstart <= lentext) Then
            If (tend >= 1) And (tend <= lentext) Then
               ret = Mid(_text, tstart, (tend - tstart) + 1)
            EndIf
         EndIf
      End If
   EndIf
   
   Return ret
End Function

'Paints the edit field. Returns 1 past text string if any.
Function tEdit._Paint(tstart As Integer, tend As Integer) As Integer
   Dim As String ifield, vtxt
   Dim As Integer ret
   
  'Erase the edit field.
   ifield = String(_inputlen, gtBackChar)
   PutText ifield, _row, _col, gtBackColor
   'Draw the edit field.
   ifield = String(_inputlen, _inputchar)
   PutText ifield, _row, _col, _inputcolor
   'Get the text view if we have text.
   If Len(_text) > 0 Then
      vtxt = _Substr(tstart, tend)
       PutText vtxt, _row, _col, _textcolor
       ret = Len(vtxt) + 1
   Else
      ret = 1
   EndIf
   
   Return ret
End Function

'Delected character at index.
Sub tEdit._DeleteChar(index As Integer)
   Dim As String lt, rt
   Dim As Integer ltxt = Len(_text)
   
   'Make sure we have some text.
   If ltxt > 0 Then
      'Make sure index is in range.
      If (index >= 1) And (index <= ltxt) Then
         'Index at beginning of string.
         If index = 1 Then
            _text = Mid(_text, 2)
         'Index at end of string.
         ElseIf index = ltxt Then
            _text = Left(_text, ltxt - 1)
         Else
            lt = Left(_text, index - 1)
            rt = Mid(_text, index + 1)
            _text = lt & rt
         EndIf
      EndIf
   End If
   
End Sub

Constructor tEdit ()
   If gtinitok = tTrue Then
      If gtDepth > 8 Then        'Default colors.
         _textcolor = RGB(0, 0, 0)
         _inputcolor = RGB(255, 255, 255)
         _caretcolor = RGB(0, 0, 0)
      Else
         _textcolor = 0
         _inputcolor = 15
         _caretcolor = 0
      End If
   End If
   _text = ""
   _mask = ""
   _maxlen = 0
   _inputlen = 10
   _inputchar = Chr(219)
   _caret = Chr(95)
   _caretins = Chr(22)
   _insert = tFalse
   _row = 0
   _col = 0
End Constructor

Destructor tEdit ()
   _text = ""
   _mask = ""
   _caret = ""
   _caretins = ""
   _inputchar = ""
End Destructor

'Sets row of input field.
Property tEdit.Row(r As Integer)
   _row = r
End Property

'Returns row of input field.
Property tEdit.Row() As Integer
   Return _row
End Property

'Sets column of input field.
Property tEdit.Col(c As Integer)
   _col = c
End Property

'Returns column of input field.
Property tEdit.Col() As Integer
   Return _col
End Property

'Sets the text property.
Property tEdit.Text (t As String)
   Dim As String et = t

   If _maxlen > 0 Then
      If Len(et) > _maxlen Then
         et = Mid(et, 1, _maxlen)
      EndIf
   End If
   
   _text = et
End Property

'Returns the text.
Property tEdit.Text () As String
   Return _text
End Property

'Sets the mask property.
Property tEdit.EditMask (t As String)
   _mask = t
End Property

'Returns the text.
Property tEdit.EditMask () As String
   Return _mask
End Property

'Sets the max lengtgh of input text. 0 = unlimited.
Property tEdit.MaxLen(m As Integer)
   _maxlen = m
End Property

'Returns the max lengtgh of input text. 0 = unlimited.
Property tEdit.MaxLen() As Integer
   Return maxlen
End Property

'Sets the lengtgh of the input field. Default is 10 chars.
Property tEdit.InputLen (i As Integer)
   _inputlen = i
End Property

'Returns the lengtgh of the input field. Default is 10 chars.
Property tEdit.InputLen () As Integer
   Return _inputlen
End Property

'Sets the color of the text.
Property tEdit.TextColor (c As UInteger)
   _textcolor = c
End Property

'Returns the color of the text.
Property tEdit.TextColor () As UInteger
   Return _textcolor
End Property

'Sets the color of the input field.
Property tEdit.InputColor (c As UInteger)
   _inputcolor = c
End Property

'Returns the color of the input field.
Property tEdit.InputColor () As UInteger
   Return _inputcolor
End Property

'Sets the input field to ascci code character.
Property tEdit.InputChar (c As Integer)   
   If (c > 0) And (c < 255) Then
      _inputchar = Chr(c)
   EndIf
End Property

'Returns the input field ascci code character.
Property tEdit.InputChar () As Integer    
   Return Asc(_inputchar)
End Property

'Sets the caret color.
Property tEdit.CaretColor (c As UInteger)
   _caretcolor = c
End Property

'Returns the caret color.
Property tEdit.CaretColor () As UInteger
   Return _caretcolor
End Property

'Sets the caret to ascii code character.
Property tEdit.Caret (c As Integer)
   If (c > 0) And (c < 255) Then
      _caret = Chr(c)
   EndIf
End Property

'Returns the caret ascii code.
Property tEdit.Caret () As Integer
   Return Asc(_caret)
End Property

'Sets the insert caret to ascii code character.
Property tEdit.CaretIns (c As Integer)
   If (c > 0) And (c < 255) Then
      _caretins = Chr(c)
   EndIf
End Property

'Returns the insert caret ascii code.
Property tEdit.CaretIns () As Integer
   Return Asc(_caretins)
End Property

'Draws the edit field and returns the key command.
Function tEdit.DrawEdit () As tKeys    
   Dim As tKeys ret
   Dim As String ch
   Dim As Integer done = tFalse, istart = 1, iend = _inputlen, tidx, ccol
   Dim As Integer chk
   
   If gtinitok = tTrue Then
      'Paint the edit field.
      tidx = _Paint(istart, iend)
      ccol = (_col - 1) + tidx 
      'Draw the caret.
      PutText _caret, _row, ccol, _caretcolor
      Do
         ch = InKey
         If ch <> "" Then
            If ch = KeyEnter Then
               ret = gkyEnter
               done = tTrue
            ElseIf ch = KeyEsc Then
               ret = gkyEsc
               done = tTrue
            ElseIf ch = KeyTab Then
               ret = gkyTab
               done = tTrue
            ElseIf ch = KeyBkspc Then
               _DeleteChar tidx - 1
               tidx = _Paint(istart, iend)
               ccol = (_col - 1) + tidx 
               PutText _caret, _row, ccol, _caretcolor
            Else
               'Get the next character and echo to screen.
               If (Asc(ch) > 31) And (Asc(ch) < 127) Then
                  'Check the edit mask.
                  If Len(_mask) > 0 Then
                     chk = InStr(_mask, ch)
                     If chk > 0 Then
                        _text &= ch
                     EndIf
                  Else
                     _text &= ch
                  EndIf
                  'Check the lengtgh.
                  If (_maxlen > 0) Then
                     If (Len(_text) > _maxlen) Then
                        _text = Mid(_text, 1, _maxlen)
                     End If
                  EndIf
                  'Paint the field.
                  tidx = _paint(istart, iend)
                  ccol = (_col - 1) + tidx
                  If ccol > (_col - 1) + _inputlen Then
                     ccol = (_col - 1) + _inputlen
                  EndIf
                  PutText _caret, _row, ccol, _caretcolor
               EndIf
            End If
         End If
         Sleep 1
      Loop Until done = tTrue
      tidx = _Paint(1, _inputlen)   
   End If
   
   Return ret
End Function

'******************************************************************************************************
'InputBox Object
'Displays an input box on the screen and returns the the entered data. An empty string is returned if
'the user selected Cancel.
'******************************************************************************************************

Type tInputbox
   Private:
   _win As tWin                'Window object.
   _edit As tEdit              'Edit field object.
   _row As Integer             'Input box row.
   _col As Integer             'Input box column.
   _winstyle As wlinestyle     'Window style.
   _btncolor As UInteger       'Non-selected button color.
   _btnselcolor As UInteger    'Selected button color.
   _prompt As String           'The prompt to display.
   _promptcolor As UInteger    'Color of the message.
   _btn1 As tButton            'Ok buton.
   _btn2 As tButton            'Cancel button.
   _inputlen As Integer        'Input field lengtgh.
   Public:
   Declare Constructor ()
   Declare Property Row(r As Integer)                   'Sets the inputbox row.
   Declare Property Row() As Integer                    'Returns the inputbox row.
   Declare Property Col(c As Integer)                   'Sets the inputbox column.
   Declare Property Col() As Integer                    'Returns the inputbox column.
   Declare Property WindowStyle (wstyle As wlinestyle)  'Sets the window style.
   Declare Property WindowStyle () As wlinestyle        'Returns the window style.
   Declare Property BackgroundColor (clr As UInteger)   'Sets background color.
   Declare Property BorderColor (clr As UInteger)       'Sets the border color.
   Declare Property BorderColor () As UInteger          'Returns the border color.
   Declare Property ButtonSelectColor (clr As UInteger) 'Sets the color of the selected button.
   Declare Property ButtonSelectColor () As UInteger    'Returns the color of the selected button.
   Declare Property ButtonColor (clr As UInteger)       'Sets the color of the non-selected button.
   Declare Property ButtonColor () As UInteger          'Returns the color of the non-selected button.
   Declare Property Prompt (p As String)                'Sets the prompt string.
   Declare Property Prompt () As String                 'Return the prompt string.
   Declare Property PromptColor (clr As UInteger)       'Sets the prompt forecolor.
   Declare Property PromptColor () As UInteger          'Return the prompt forecolor.
   Declare Property Title(s As String)                  'Sets the window title.
   Declare Property Title() As String                   'Returns the window title.
   Declare Property AlignTitle(t As wtitlealign)        'Sets the window title alignment.
   Declare Property AlignTitle() As wtitlealign         'Returns the window title alignment.
   Declare Property TitleColor(c As UInteger)           'Sets the window title color.
   Declare Property TitleColor() As UInteger            'Returns the window title color.
   Declare Property Shadow (s As Integer)               'Sets the shadow flag. 
   Declare Property Shadow () As Integer                'Returns the shadow flag. 
   Declare Property MaxLen(m As Integer)                'Sets the max lengtgh of input text. 0 = unlimited.
   Declare Property MaxLen() As Integer                 'Returns the max lengtgh of input text. 0 = unlimited.
   Declare Property InputLen (i As Integer)             'Sets the lengtgh of the input field. Default is 10 chars. 
   Declare Property InputLen () As Integer              'Returns the lengtgh of the input field. Default is 10 chars.
   Declare Property TextColor (c As UInteger)           'Sets the color of the text.
   Declare Property TextColor () As UInteger            'Returns the color of the text.
   Declare Property InputColor (c As UInteger)          'Sets the color of the input field. 
   Declare Property InputColor () As UInteger           'Returns the color of the input field.
   Declare Property InputChar (c As Integer)            'Sets the input field to ascci code character. 
   Declare Property InputChar () As Integer             'Returns the input field ascci code character.
   Declare Property CaretColor (c As UInteger)          'Sets the caret color.
   Declare Property CaretColor () As UInteger           'Returns the caret color.
   Declare Property Caret (c As Integer)                'Sets the caret to ascii code character.
   Declare Property Caret () As Integer                 'Returns the caret ascii code.
   Declare Property CaretIns (c As Integer)             'Sets the insert caret to ascii code character.
   Declare Property CaretIns () As Integer              'Returns the insert caret ascii code..
   Declare Property BackColor (c As UInteger)            'Sets the window back color.
   Declare Property BackColor () As UInteger             'Returns the window back color.
   Declare Property EditMask (t As String)               'Sets the mask property.
   Declare Property EditMask () As String                'Returns the mask.
   Declare Function Inputbox (result As String) As btnID 'Draws inputbox on screen.
End Type

'Initalizes the object.
Constructor tInputbox ()
   If _win.InitOk = tTrue Then
      _inputlen = _edit.InputLen
      _row = 0
      _col = 0
      If _win.ColorDepth > 8 Then        'Default colors.
         _btncolor = RGB(255, 255, 255)
         _btnselcolor = RGB(255, 255, 0)
         _promptcolor =  RGB(255, 255, 255)
      Else
         _btncolor = 15
         _btnselcolor = 14
         _promptcolor =  15
      End If
   End If
End Constructor

'Sets the inputbox row.
Property tInputbox.Row(r As Integer)
   _row = r
End Property

'Returns the inputbox row.
Property tInputbox.Row() As Integer
   Return _row
End Property

'Sets the inputbox column.
Property tInputbox.Col(c As Integer)
   _col = c
End Property

'Returns the inputbox column.
Property tInputbox.Col() As Integer
   Return _col
End Property

'Sets the window line style.
Property tInputbox.WindowStyle (wstyle As wlinestyle)
   _win.LineStyle = wstyle
End Property

'Sets background color.
Property tInputbox.BackColor (clr As UInteger)
   _win.BackColor = clr
End Property

'Returns the background color.
Property tInputbox.BackColor () As UInteger
   Return _win.Backcolor
End Property

'Sets the border color.
Property tInputbox.BorderColor (clr As UInteger)
   _win.BorderColor = clr
End Property

'Returns the border color.
Property tInputbox.BorderColor () As UInteger
   Return _win.BorderColor
End Property

'Sets the color of the selected button.
Property tInputbox.ButtonSelectColor (clr As UInteger)
   _btnselcolor = clr
End Property

'Returns the color of the selected button.
Property tInputbox.ButtonSelectColor () As UInteger
   Return _btnselcolor
End Property

'Sets the color of the non-selected button.
Property tInputbox.ButtonColor (clr As UInteger)
   _btncolor = clr
End Property

'Returns the color of the non-selected button.
Property tInputbox.ButtonColor () As UInteger
   Return _btncolor
End Property

'Sets the prompt string.
Property tInputbox.Prompt (s As String)
   _prompt = s
End Property

'Returns the prompt string.
Property tInputbox.Prompt () As String
   Return _prompt
End Property

'Sets the prompt forecolor.
Property tInputbox.PromptColor (clr As UInteger)
   _promptcolor = clr
End Property

'Returns the prompt forecolor.
Property tInputbox.PromptColor () As UInteger
   Return _promptcolor
End Property

'Sets the window title.
Property tInputbox.Title(s As String)
   _win.Title = s
End Property

'Returns the window title.
Property tInputbox.Title() As String
   Return _win.Title
End Property

'Sets the window title alignment.
Property tInputbox.AlignTitle(t As wtitlealign)
   _win.AlignTitle = t
End Property

'Returns the window title alignment.
Property tInputbox.AlignTitle() As wtitlealign
   Return _win.AlignTitle
End Property

'Sets the window title color.
Property tInputbox.TitleColor(c As UInteger)
   _win.TitleColor = c
End Property

'Returns the window title color.
Property tInputbox.TitleColor() As UInteger
   Return _win.TitleColor
End Property

'Sets the shadow drawing on and off.
Property tInputbox.Shadow (s As Integer)
   _win.Shadow = s
End Property

'Resturns current shadow flag setting.
Property tInputbox.Shadow () As Integer
   Return _win.Shadow
End Property

'Sets the max lengtgh of input text. 0 = unlimited.
Property tInputbox.MaxLen(m As Integer)
   _edit.MaxLen = m
End Property

'Returns the max lengtgh of input text. 0 = unlimited.
Property tInputbox.MaxLen() As Integer
   Return _edit.MaxLen
End Property

'Sets the lengtgh of the input field. Default is 10 chars.
Property tInputbox.InputLen (i As Integer)
   _edit.InputLen = i
   _inputlen = i
End Property

'Returns the lengtgh of the input field. Default is 10 chars.
Property tInputbox.InputLen () As Integer
   Return _edit.InputLen
End Property

'Sets the color of the text.
Property tInputbox.TextColor (c As UInteger)
   _edit.TextColor = c
End Property

'Returns the color of the text.
Property tInputbox.TextColor () As UInteger
   Return _edit.TextColor
End Property

'Sets the color of the input field.
Property tInputbox.InputColor (c As UInteger)
   _edit.InputColor = c
End Property

'Returns the color of the input field.
Property tInputbox.InputColor () As UInteger
   Return _edit.InputColor
End Property

'Sets the input field to ascci code character.
Property tInputbox.InputChar (c As Integer)   
   _edit.InputChar = c
End Property

'Returns the input field ascci code character.
Property tInputbox.InputChar () As Integer    
   Return _edit.InputChar
End Property

'Sets the caret color.
Property tInputbox.CaretColor (c As UInteger)
   _edit.CaretColor = c
End Property

'Returns the caret color.
Property tInputbox.CaretColor () As UInteger
   Return _edit.CaretColor
End Property

'Sets the caret to ascii code character.
Property tInputbox.Caret (c As Integer)
   _edit.Caret = c
End Property

'Returns the caret ascii code.
Property tInputbox.Caret () As Integer
   Return _edit.Caret
End Property

'Sets the insert caret to ascii code character.
Property tInputbox.CaretIns (c As Integer)
   _edit.CaretIns = c
End Property

'Returns the insert caret ascii code.
Property tInputbox.CaretIns () As Integer
   Return _edit.CaretIns
End Property

'Sets the mask property.
Property tInputbox.EditMask (t As String)
   _edit.EditMask = t
End Property

'Returns the text.
Property tInputbox.EditMask () As String
   Return _edit.EditMask
End Property


'Draws a message box on the screen and return button id. Entered data is returned in result. 
Function tInputbox.InputBox(result As String) As btnID
   Dim As btnID btn, activebtn
   Dim As String btn1, btn2, prcopy = _prompt, ch
   Dim As Integer lprompt = Len(prompt), row1, col1, row2, col2
   Dim As Integer prow, pcol, btnrow, btn1col, btn2col
   Dim As Integer bidx1, bidx2, editactive = tTrue, done = tFalse
   Dim As tKeys ky
   
   If _win.InitOK = tTrue Then
      'Set the prompt lengtgh to the maxlen size if less than maxlen.
      If lprompt < _inputlen Then lprompt = _inputlen
      'Draw the box.
      If lprompt < 30 Then lprompt = 30
      'If the prompt is too long, trim it.
      If lprompt > (_win.Cols - 4) Then
         prcopy = Mid(prcopy, 1, _win.Cols - 4)
         lprompt = Len(prcopy)
      EndIf
      'Center on screen.
      If _row > 0 Then
         'Set the position based on set row, col.
         prow = _row + 2
      Else
         'Calculate the screen center point of the prompt.
         prow = tCenterY(6) - 2
      End If
      If _col > 0 Then
         pcol = _col + 2
      Else
         pcol = tCenterX(prcopy)
      EndIf
      'Build the box around the prompt.
      row1 = prow - 2
      row2 = prow + 6
      col1 = tCenterX(lprompt) - 2
      col2 = col1 + lprompt + 3
      'Set the window dimensions.
      _win.RowTop = row1
      _win.ColLeft = col1
      _win.RowBottom = row2
      _win.ColRight = col2
      'Draw the OK, Cancel buttons.
      btnRow = row2 - 2
      'Set the buttons. Uses Ok-Cancel button.
      btn1 = "[ OK ]"
      btn2 = " [ Cancel ]"
      btn1col = tCenterX(col1, col2, btn1 & btn2)
      btn2col = btn1col + Len(btn1)

      _btn1.Text = btn1
      _btn1.SelText = "< OK >"
      _btn1.Row = btnrow
      _btn1.Col = btn1col
      _btn1.Selected = tFalse
      _btn1.BColor = _btncolor
      _btn1.SelColor = _btnselcolor
      _btn1.Shadow = _win.Shadow
      _btn1.ID = gbnOK
      bidx1 = _win.AddButton(_btn1)

      _btn2.Text = btn2
      _btn2.SelText = " < Cancel >"
      _btn2.Row = btnrow
      _btn2.Col = btn2col
      _btn2.Selected = tFalse
      _btn2.BColor = _btncolor
      _btn2.SelColor = _btnselcolor
      _btn2.Shadow = _win.Shadow
      _btn2.ID = gbnCancel
      bidx2 = _win.AddButton(_btn2)
      ScreenLock
      'Draw the window.
      _win.DrawWindow
      'Draw the prompt.
      PutText prcopy, prow, pcol, _promptcolor
      ScreenUnLock
      'Set the edit field location.
      _edit.Row = prow + 2
      _edit.Col = tCenterX(lprompt)
      'Load with any text passed.
      _edit.Text = result
      'Set the active button to the text field.
      activebtn = gbnNone
      'Get the input.
      Do
         If editactive = tTrue Then
            ky = _edit.DrawEdit
            editactive = tFalse
         End If
         'Process enter key from edit.
         If (ky = gkyEnter) And (editactive = tFalse) Then
            btn = gbnOK
            result = _edit.text
            done = tTrue
         EndIf
         'Process escape key from edit.
         If ky = gkyEsc Then
            btn = gbnCancel
            result = ""
            done = tTrue
         EndIf
         'Process tab key from edit.
         If ky = gkyTab Then
            activebtn = gbnOK
            _win.ButtonSelected(bidx1) = tTrue 
            _win.ButtonSelected(bidx2) = tFalse
            'Redraw the buttons.
            _win.DrawButton(bidx1)
            _win.DrawButton(bidx2)
         EndIf
         'Clear the key flag.
          ky = gkyNone 
         'Not in edit so process buttons.
         If editactive = tFalse Then
            ch = InKey
            If ch <> "" Then
               'Process tab key.
               If ch = KeyTab Then
                  'Increment the control index.
                  Select Case activebtn
                     Case gbnCancel
                        _win.ButtonSelected(bidx1) = tFalse 
                        _win.ButtonSelected(bidx2) = tFalse
                        activebtn = gbnNone
                        editactive = tTrue
                     Case gbnOK
                        activebtn = gbnCancel
                        'Toggle selected state.
                        _win.ButtonSelected(bidx1) = tFalse 
                        _win.ButtonSelected(bidx2) = tTrue
                     Case gbnNone
                        activebtn = gbnOK
                        _win.ButtonSelected(bidx1) = tTrue 
                        _win.ButtonSelected(bidx2) = tFalse
                  End Select
                 'Redraw the buttons.
                  _win.DrawButton(bidx1)
                  _win.DrawButton(bidx2)
               EndIf
               'Process enter key.
               If ch = KeyEnter Then
                  btn = activebtn
                  If btn = gbnOK Then
                     result = _edit.text
                     done = tTrue
                  Else
                     btn = gbnCancel
                     result = ""
                     done = tTrue
                  End If
               EndIf
               'Process escape key.
               If ch = KeyEsc Then
                  btn = gbnCancel
                  result = ""
                  done = tTrue
               EndIf
            End If
         End If
         Sleep 1
      Loop Until done = tTrue
   End If
   'Destroy window and restoe background.
   _win.DestroyWindow
       
   Return btn
End Function

End Namespace
