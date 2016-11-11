/'****************************************************************************
* map.bi
* This file contains declarations and functions for building a dungeon level.
* by Stephen Gatten
* Last update: November 8, 2016
*****************************************************************************'/

'Minimum and maximum room dimensions
#define roomMin 4
#define roomMax 8
#define numberOfRoomsMin 20
#define numberOfRoomsMax 50

'Empty cell flag.
#define emptyCell 0

'Level size.
#define mapWidth 100
#define mapHeight 100

'Viewport width and height.
#define viewWidth 45
#define viewHeight 53

'Grid cell size
const cellSizeWidth = 10
const cellSizeHeight = 10

'Grid dimensions
const gridWidth = mapWidth / cellSizeWidth
const gridHeight = mapHeight / cellSizeHeight

'Types of terrain in the map.
enum terrainIDs
    tFloor = 0
    tWall
    tDoorOpen
    tDoorClosed
    tStairUp
    tStairDown
end enum

'Room dimensions. The roomDimension type defines the dimensions of a room.
'The roomCoordinate denotes the center of a room, used in cooridor building.
type roomDimension
    roomWidth as integer
    roomHeight as integer
    roomCoordinate as mapCoordinate
end type

'Room information. Used to create a room array to contain list of rooms.
type roomType
    roomSize as roomDimension
    topLeft as mapCoordinate
    bottomRight as mapCoordinate
end type

'Grid cell structure. cellType represents a region within the grid.
type cellType
    cellCoordinate as mapCoordinate 'Cell position.
    room as integer 'Room ID; this is an index into the room array.
end type

type doorType
    locked as integer               'True if locked.
    lockDifficulty as integer       'Lockpick difficulty.
    doorStrength as integer         'Strength of door.
end type

'Map info type.
type mapInfoType
    terrainID as terrainIDs
    hasMonster as integer
    monsterIndex as integer
    hasItem as integer
    visible as integer
    seen as integer
    doorInfo as doorType
end type

type levelInfo
    numLevel as integer
    wallColor as uinteger
    levelMap(1 to mapWidth, 1 to mapHeight) as mapInfoType
    levelInv(1 to mapWidth, 1 to mapHeight) as inventoryType    'Map inventory type
end type

'Object for the level data. Most of the code in this object is private since
'it is only used in the dungeon generation and display code.
type levelObject
    private:
    _level as levelInfo
    _numberOfRooms as integer
    _rooms(1 to numberOfRoomsMax) as roomType
    _grid(1 to gridWidth, 1 to gridHeight) as cellType
    _blockingTiles as integer ptr
    _numberOfBlockingTiles as integer
    
    declare sub _calculateLOS()
    declare sub _initializeGrid()
    declare sub _connectRooms(room1 as integer, room2 as integer)
    declare sub _addDoorsToRoom(i as integer)
    declare sub _addDoors()
    declare sub _drawMapToArray()
    declare sub _generateItems()
    
    declare function _blockingTile(tileX as integer, tileY as integer) as integer
    declare function _lineOfSight(x1 as integer, y1 as integer, x2 as integer, y2 as integer) as integer
    declare function _canSee(tileX as integer, tileY as integer) as integer
    declare function _getLevelWallColor() as uinteger
    declare function _getMapGlyph(tile as terrainIDs) as string
    declare function _getMapGlyphColor(tile as terrainIDs) as UInteger
    declare function _getTerrainInfo(x as integer, y as integer) as string
    declare function _getLevelName() as string
    
    public:
    declare constructor()
    declare destructor()
    
    declare property levelID(newLevel as integer)
    declare property levelID() as integer
    declare property levelWallColor(newColor as uinteger)
    declare property levelWallColor() as uinteger
    
    declare sub drawMap()
    declare sub setTile(x as integer, y as integer, newTileID as terrainIDs)
    declare sub getItemFromMap(x as integer, y as integer, inv as inventoryType)
    declare sub generateDungeonLevel()
    declare sub putItemOnMap(x as integer, y as integer, inv as inventoryType)
    
    declare function isBlocking(x as integer, y as integer) as integer
    declare function isDoorLocked(x as integer, y as integer) as integer
    declare function getTileID(x as integer, y as integer) as terrainIDs
    declare function getTerrainDescription(x as integer, y as integer) as string
    declare function getItemDescription(x as integer, y as integer) as string
    declare function getInventoryClassID(x as integer, y as integer) as classIDs
    declare function hasItem(x as integer, y as integer) as integer
    declare function getLevelDescription() as string
    declare function getEmptySpot(v as mapVector) as integer
end type

dim shared rooms(1 to numberOfRoomsMax) as roomType
dim shared grid(1 to gridWidth, 1 to gridHeight) as cellType 'Grid of cells.
dim shared as integer numberOfRooms 'Number of rooms in the map.

'Initializes object.
constructor levelObject()
    'Set the number of blocking tiles.
    _numberOfBlockingTiles = 3
    
    'Set up the list of blocking tiles.
    _blockingTiles = callocate(_numberOfBlockingTiles * sizeof(integer))
    
    'Add these blocking tiles to the list.
    _blockingTiles[0] = tWall
    _blockingTiles[1] = tDoorClosed
    _blockingTiles[2] = tStairUp
    
    'Reset the level number.
    _level.numLevel = 0
    
    'Reset the level wall color to default.
    _level.wallColor = cTan
end constructor

'Cleans up object.
destructor levelObject()
    if _blockingTiles <> null then
        deallocate _blockingTiles
        _blockingTiles = null
    endif
end destructor

'Sets the current level.
property levelObject.levelID(newLevel As Integer)
   _level.numLevel = newLevel
end property

'Returns the current level number.
property levelObject.levelID() As Integer
   return _level.numLevel
end property

'Sets the level's wall color.
property levelObject.levelWallColor(newColor as uinteger)
    _level.wallColor = newColor
end property

'Returns the level's wall color.
property levelObject.levelWallColor() as uinteger
    return _level.wallColor
end property

'This subroutine calculates line of sight.
sub levelObject._calculateLOS()
    dim as integer i, j, x, y, w = viewWidth / 2, h = viewHeight / 2
    dim as integer x1, x2, y1, y2
    
    'Clear the visibility map.
    for i = 1 to mapWidth
        for j = 1 to mapHeight
            _level.levelMap(i,j).visible = false
        next
    next
    
    'Only check locations within the viewport. Other locations will not be seen
    x1 = player.locX - w
    if x1 < 1 then x1 = 1
    y1 = player.locY - h
    if y1 < 1 then y1 = 1
    
    x2 = player.locX + w
    if x2 > mapWidth then x2 = mapWidth
    y2 = player.locY + h
    if y2 > mapHeight then y2 = mapHeight
    
    'Iterate through the vision area.
    for i = x1 to x2
        for j = y1 to y2
            'Don't recalculate for seen tiles
            if _level.levelMap(i,j).visible = false then
                if _canSee(i,j) = true then
                    _level.levelMap(i,j).visible = true
                    _level.levelMap(i,j).seen = true
                endif
            endif
        next
    next
    
    'Post-process the map to remove artifacts caused by the integer math used
    'in Bresenham's line algorithm.
    for i = x1 to x2
        for j = y1 to y2
            if(_blockingTile(i,j) = true) and (_level.levelMap(i,j).visible = false) then
                x = i
                y = j - 1
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
                x = i
                y = j + 1
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
                x = i + 1
                y = j
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
                x = i - 1
                y = j
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
                x = i - 1
                y = j - 1
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
                x = i + 1
                y = j - 1
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
                x = i + 1
                y = j + 1
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
                x = i - 1
                y = j + 1
                if (x > 0) and (x < mapWidth + 1) then
                    if (y > 0) and (y < mapHeight + 1) then
                        if(_level.levelMap(x,y).terrainID = tFloor) and (_level.levelMap(x,y).visible = true) then
                            _level.levelMap(i,j).visible = true
                            _level.levelMap(i,j).seen = true
                        endif
                    endif
                endif
                
            endif
        next
    next
end sub

'Initialize the grid and room arrays.
sub levelObject._initializeGrid
    dim as integer i,j,x,y,gx = 1, gy = 1
    
    'Clear the room array.
    for i = 1 to numberOfRoomsMax
        _rooms(i).roomSize.roomWidth = 0
        _rooms(i).roomSize.roomHeight = 0
        _rooms(i).roomSize.roomCoordinate.x = 0
        _rooms(i).roomSize.roomCoordinate.y = 0
        _rooms(i).topLeft.x = 0 : rooms(i).topLeft.y = 0
        _rooms(i).bottomRight.x = 0 : rooms(i).bottomRight.y = 0
    next
    
    'How many rooms will be in this dungeon?
    _numberOfRooms = randomRange(numberOfRoomsMin, numberOfRoomsMax)
    
    'Build some rooms.
    for i = 1 to _numberOfRooms
        _rooms(i).roomSize.roomWidth = randomRange(roomMin, roomMax)
        _rooms(i).roomSize.roomHeight = randomRange(roomMin, roomMax)
    next
    
    'Clear the grid array.
    for i = 1 to gridWidth
        for j = 1 to gridHeight
            _grid(i,j).cellCoordinate.x = gx
            _grid(i,j).cellCoordinate.y = gy
            _grid(i,j).room = emptyCell
            gy += cellSizeHeight
        next
        gy = 1
        gx += cellSizeWidth
    next
    
    'Add rooms to the grid.
    for i = 1 to _numberOfRooms
        'Find an empty spot in the grid
        do
            x = randomRange(2, gridWidth - 1)
            y = randomRange(2, gridHeight - 1)
        loop until _grid(x,y).room = emptyCell
        
        'Room center
        _rooms(i).roomSize.roomCoordinate.x = _grid(x,y).cellCoordinate.x + (_rooms(i).roomSize.roomWidth / 2)
        _rooms(i).roomSize.roomCoordinate.y = _grid(x,y).cellCoordinate.y + (_rooms(i).roomSize.roomHeight / 2)
        
        'Set the room rectangle.
        _rooms(i).topLeft.x = _grid(x,y).cellCoordinate.x
        _rooms(i).topLeft.y = _grid(x,y).cellCoordinate.y
        _rooms(i).bottomRight.x = _grid(x,y).cellCoordinate.x + _rooms(i).roomSize.roomWidth + 1
        _rooms(i).bottomRight.y = _grid(x,y).cellCoordinate.y + _rooms(i).roomSize.roomHeight + 1
        
        'Save the room index.
        _grid(x,y).room = 1
    next
end sub

'Connect all the rooms.
sub levelObject._connectRooms(room1 as integer, room2 as integer)
    dim as integer index, x, y
    dim as mapCoordinate currentCell, lastCell
    dim as integer wFlag
    
    currentCell = _rooms(room1).roomSize.roomCoordinate
    lastCell = _rooms(room2).roomSize.roomCoordinate
    
    x = currentCell.x
    if x < lastCell.x then
        wFlag = false
        do
            x += 1
            if _level.levelMap(x,currentCell.y).terrainID = tWall then wFlag = true
            if (_level.levelMap(x,currentCell.y).terrainID = tFloor) and (wFlag = true) then
                exit sub
            endif
            _level.levelMap(x,currentCell.y).terrainID = tFloor
        loop until x = lastCell.x
    endif
    
    if x > lastCell.x then
        wFlag = false
        do
            x -= 1
            if _level.levelMap(x,currentCell.y).terrainID = tWall then wFlag = true
            if (_level.levelMap(x,currentCell.y).terrainID = tFloor) and (wFlag = true) then
                exit sub
            endif
            _level.levelMap(x,currentCell.y).terrainID = tFloor
        loop until x = lastCell.x
    endif
    
    y = currentCell.y
    if y < lastCell.y then
        wFlag = FALSE
        do
            y += 1
            if _level.levelMap(x, y).terrainID = tWall then wFlag = true
            If (_level.levelMap(x, y).terrainID = tFloor) and (wFlag = true) then 
                exit sub
            endIf
            _level.levelMap(x, y).terrainID = tFloor
        loop until y = lastCell.y
    endif
    
    If y > lastCell.y then
        do
            y -= 1
            if _level.levelMap(x, y).terrainID = tWall then wFlag = true
            if (_level.levelMap(x, y).terrainID = tFloor) and (wFlag = true) then 
                exit sub
            endif
            _level.levelMap(x, y).terrainID = tFloor
        loop until y = lastCell.y
    endif
end sub

'Adds doors to rooms. This subroutine iterates through all the rooms in the list
'and calls addDoorsToRoom for each one.
sub levelObject._addDoors()
    for i as integer = 1 to _numberOfRooms
        _addDoorsToRoom i
    next
end sub

'Add doors to a room. This subroutine walks along each wall in a room using
'the room's rectangle data. If it finds a floor tile, then it sets the terrain
'type to a closed door. It does two walls at a time, top and bottom, and then
'left and right.
sub levelObject._addDoorsToRoom(i as integer)
    dim as integer row, column, dd1, dd2
    
    'Iterate along the top of the room.
    for column = _rooms(i).topLeft.x to _rooms(i).bottomRight.x
        dd1 = _rooms(i).topLeft.y : dd2 = _rooms(i).bottomRight.y
        
        'if there is a floor space in the wall, place a door there.
        if _level.levelMap(column, dd1).terrainID = tFloor then
            _level.levelMap(column, dd1).terrainID = tDoorClosed
            _level.levelMap(column, dd1).doorInfo.locked = false
            if _level.levelMap(column, dd1).doorInfo.locked = true then
               _level.levelMap(column, dd1).doorInfo.lockDifficulty = 0
               _level.levelMap(column, dd1).doorInfo.doorStrength = 0
            endif
        endif
        
        if _level.levelMap(column, dd2).terrainID = tFloor then
            _level.levelMap(column, dd2).terrainID = tDoorClosed
            _level.levelMap(column, dd2).doorInfo.locked = false
            if _level.levelMap(column, dd2).doorInfo.locked = true then
               _level.levelMap(column, dd2).doorInfo.lockDifficulty = 0
               _level.levelMap(column, dd2).doorInfo.doorStrength = 0
            endif
        endif
    next
    
    'Iterate along the left side of the room.
    for row = _rooms(i).topLeft.y to _rooms(i).bottomRight.y
        dd1 = _rooms(i).topLeft.x : dd2 = _rooms(i).bottomRight.x
        if _level.levelMap(dd1, row).terrainID = tFloor then
            _level.levelMap(dd1, row).terrainID = tDoorClosed
            _level.levelMap(dd1, row).doorInfo.locked = false
            if _level.levelMap(dd1, row).doorInfo.locked = true then
               _level.levelMap(dd1, row).doorInfo.lockDifficulty = 0
               _level.levelMap(dd1, row).doorInfo.doorStrength = 0
            endif
        endif
        
        if _level.levelMap(dd2, row).terrainID = tFloor then
            _level.levelMap(dd2, row).terrainID = tDoorClosed
            _level.levelMap(dd2, row).doorInfo.locked = false
            if _level.levelMap(dd2, row).doorInfo.locked = true then
               _level.levelMap(dd2, row).doorInfo.lockDifficulty = 0
               _level.levelMap(dd2, row).doorInfo.doorStrength = 0
            endif
        endif
    next
end sub

sub levelObject._drawMapToArray()
    dim as integer i, x, y, pr, rr, rl, ru, kr
    
    'Draw the first room to map array.
    for x = _rooms(1).topLeft.x + 1 to _rooms(1).bottomRight.x - 1
        for y = _rooms(1).topLeft.y + 1 to _rooms(1).bottomRight.y - 1
            _level.levelMap(x,y).terrainID = tFloor
        next
    next
    
    'Draw the rest of the rooms to the map array and connect them.
    for i = 2 to _numberOfRooms
        for x = _rooms(i).topLeft.x + 1 to _rooms(i).bottomRight.x - 1
            for y = _rooms(i).topLeft.y + 1 to _rooms(i).bottomRight.y - 1
                _level.levelMap(x,y).terrainID = tFloor
            next
        next
        _connectRooms i, i - 1
    next
    
    'Add doors to selected rooms.
    _addDoors
    
    'Set up player location and the stairs up. The dungeon's stairs up will
    'always be at the player's starting location, the first room in the list.
    x = _rooms(1).roomSize.roomCoordinate.x + (_rooms(1).roomSize.roomWidth / 2)
    y = _rooms(1).roomSize.roomCoordinate.y + (_rooms(1).roomSize.roomHeight / 2)
    player.locX = x - 1
    player.locY = y - 1
    _level.levelMap(player.locX,player.locY).terrainID = tStairUp
    
    'Set up the stairs down in the last room in the list. This way the stairs up
    'and the stairs down will never be in the same room.
    x = _rooms(_numberOfRooms).roomSize.roomCoordinate.x + (_rooms(_numberOfRooms).roomSize.roomWidth / 2)
    y = _rooms(_numberOfRooms).roomSize.roomCoordinate.y + (_rooms(_numberOfRooms).roomSize.roomHeight / 2)
    _level.levelMap(x - 1, y - 1).terrainID = tStairDown
end sub

'This function returns true if the given tile is blocking line of sight.
function levelObject._blockingTile(tileX as integer, tileY as integer) as integer
    dim ret as integer = false
    dim tID as terrainIDs = _level.levelMap(tileX, tileY).terrainID
    
    'if tile contains a monster, it is blocking.
    if _level.levelMap(tileX, tileY).hasMonster = true then
        ret = true
    else
        'Make sure the pointer was initialized.
        if _blockingTiles <> NULL then
            'look for the current tile in the list.
            for i as integer = 0 to _numberOfBlockingTiles - 1
                'found it, so it must be blocking.
                if _blockingTiles[i] = tID then
                    ret = true
                    exit for
                endif
            next
        endif
    endif
    return ret
end function

'This function uses Bresenham's line algorithm. It performs a line of sight
'calculation by casting a ray from the tile to the character.
function levelObject._lineOfSight(x1 as integer, y1 as integer, x2 as integer, y2 as integer) as integer
    dim as integer i, deltaX, deltaY, numberOfTiles
    dim as integer d, dinc1, dinc2
    dim as integer x, xinc1, xinc2
    dim as integer y, yinc1, yinc2
    dim isSeen as integer = true
    
    deltaX = abs(x2 - x1)
    deltaY = abs(y2 - y1)
    
    if deltaX >= deltaY then
        numberOfTiles = deltaX + 1
        d = (2 * deltaY) - deltaX
        dinc1 = deltaY shl 1
        dinc2 = (deltaY - deltaX) Shl 1
        xinc1 = 1
        xinc2 = 1
        yinc1 = 0
        yinc2 = 1
    else
        numberOfTiles = deltay + 1
        d = (2 * deltaX) - deltaY
        dinc1 = deltaX Shl 1
        dinc2 = (deltaX - deltaY) Shl 1
        xinc1 = 0
        xinc2 = 1
        yinc1 = 1
        yinc2 = 1
    End If

    If x1 > x2 Then
        xinc1 = - xinc1
        xinc2 = - xinc2
    End If
    
    If y1 > y2 Then
        yinc1 = - yinc1
        yinc2 = - yinc2
    End If

    x = x1
    y = y1
    
    For i = 2 To numberOfTiles
      If _blockingTile(x, y) Then
        isSeen = false
        exit for
      End If
      If d < 0 Then
          d = d + dinc1
          x = x + xinc1
          y = y + yinc1
      Else
          d = d + dinc2
          x = x + xinc2
          y = y + yinc2
        End If
    Next
    
    Return isSeen
End Function

'This function determines if the player can see an object. It calculates the
'distance to the tile we are examining. If this distance is greater than the
'vertical distance of the display, then we do not check it. This effectively
'gives the player character a vision range of the viewport's height.
'Theoretically, viewHeight could be replaced with a vision attribute of the
'character, if we wanted to modify how far a character could see
function levelObject._canSee(tileX as integer, tileY as integer) as integer
    dim as integer ret = false, playerX = player.locX, playerY = player.locY
    dim as integer visibility = viewHeight, distance
    
    distance = calculateDistance(player.locX, tileX, player.locY, tileY)
    if distance <= visibility then
        ret = _lineOfSight(tileX, tileY, playerX, playerY)
    endif
    
    return ret
end function

'Return ascii symbol for tile
Function levelObject._getMapGlyph(tile As terrainIDs) As String
	Dim As String ret
	
    Select Case tile
   	Case tWall: ret = gWall
   	Case tFloor: ret = gFloor
    Case tStairUp: ret = "<"
    Case tStairDown: ret = ">"
   	Case tDoorOpen: ret = "'"
   	Case tDoorClosed: ret = "\"
   	Case Else: ret = "?"
    end select
   
    return ret
End Function

'Returns the color for object.
Function levelObject._getMapGlyphColor(tile As terrainIDs) As UInteger
	dim ret As UInteger
	
    select case tile
        Case tWall: ret = levelWallColor
        Case tFloor: ret = cWhite
        Case tStairUp: ret = cYellow
        Case tStairDown: ret = cYellow
        Case tDoorOpen: ret = cTan
        Case tDoorClosed: ret = cSienna
        Case else: ret = cWhite
    end select
   
    return ret
end function

'Returns a written description of a tile.
function levelObject._getTerrainInfo(x as integer, y as integer) as string
    dim tile as terrainIDs
    dim ret as string
    
    'Must be a tile.
    tile = _level.levelMap(x,y).terrainID
    select case tile
    case tWall: ret = "Wall"
    case tFloor: ret = "Floor"
    case tStairUp: ret = "Stairs Up"
    case tStairDown: ret = "Stairs Down"
    case tDoorOpen: ret = "Open Door"
    case tDoorClosed: ret = "Closed Door"
    case else: ret = "???"
    end select
    
    return ret
end function  

'Generate items for the map.
sub levelObject._generateItems()
    dim as integer i, x, y
    
    'Generate some items for the level.
    for i = 1 to 10
        do
            'Get a spot in the dungeon.
            x = randomRange(2, mapWidth - 1)
            y = randomRange(2, mapHeight - 1)
        'Look for a floor tile that doesn't already have an item.
        loop until (_level.levelMap(x,y).terrainID = tFloor) and (hasItem(x,y) = false)
        generateItem _level.levelInv(x,y), _level.numLevel
    next
end sub


'Draws the map on the screen.
sub levelObject.drawMap()
    dim as integer i, j, w = viewWidth, h = viewHeight, x, y, playerX, playerY, healthPercent
    dim as uinteger tileColor, bColor
    dim as string mTile
    dim as terrainIDs tile
    
    _calculateLOS
    
    'Get the view coordinates.
    i = player.locX - (w / 2)
    j = player.locY - (h / 2)
    if i < 1 then i = 1
    if j < 1 then j = 1
    if i + w > mapWidth then i = mapWidth - w
    if j + h > mapWidth then j = mapWidth - h
    
    'Draw the visible position of the map.
    for x = 1 to w
        for y = 1 to h
            'Clears current location to black.
            placeSpace x + 1, y + 1 
            
            'Get tile ID, glyph, and color
            tile = _level.levelMap(i + x, j + y).terrainID
            mTile = _getMapGlyph(tile)
            tileColor = _getMapGlyphColor(tile)
            
            'Print the tile.
            if _level.levelMap(i + x, j + y).visible = true then
                'Print the item marker.
                if hasItem(i + x, j + y) = true then
                    'Get the item glyph.
                    mTile = _level.levelInv(i + x, j + y).glyph
                    'Get the item color.
                    tileColor = _level.levelInv(i + x, j + y).glyphColor
                endif
                placeGlyph mTile, x + 1, y + 1, tileColor
                
                'If the current location has a monster, print that monster.
                if _level.levelMap(i + x, j + y).hasMonster = true then
                    'Put monster info here.
                endif
            else
                'Not in line of sight? Don't print monsters when not in LOS.
                if _level.levelMap(i + x, j + y).seen = true then
                    if hasItem(i + x, j + y) = true then
                        placeGlyph "?", x + 1, y + 1, cSlateGrayDark
                    else
                        placeGlyph mTile, x + 1, y + 1, cSlateGrayDark
                    endif
                endif
            endif
        next
    next
    
    'Draw the player.
    playerX = player.locX - i
    playerY = player.locY - j
    placeSpace playerX + 1, playerY + 1
    placeGlyph gAdventurer, playerX + 1, playerY + 1, cGreen
    'healthPercent = int((player.cond / player.hits) * 100)
    'if healthPercent > 74 then
    '    placeSpace playerX + 1, playerY + 1
    '    placeGlyph "@", playerX, playerY, cGreen
    'elseif (healthPercent > 24) andalso (healthPercent < 75) then
    '    placeSpace playerX, playerY
    '    placeGlyph "@", playerX, playerY, cYellow
    'else
    '    placeSpace playerX, playerY
    '    placeGlyph "@", playerX, playerY, cRed
    'endif
end sub

'Sets the tile at x,y of map.
sub levelObject.setTile(x as integer, y as integer, newTileID as terrainIDs)
    _level.levelMap(x,y).terrainID = newTileID
end sub

'Adds an item from the map to the given inventory type.
sub levelObject.GetItemFromMap(x As Integer, y As Integer, inv As inventoryType)
   if inv.classID <> iNone then
      clearInventory inv
   endif
   
   inv = _level.levelInv(x, y)
   clearInventory _level.levelInv(x, y)
end sub

'Generate a new dungeon level.
sub levelObject.generateDungeonLevel()
    dim as integer x, y
    
    'Clear level.
    for x = 1 to mapWidth
        for y = 1 to mapHeight
            'Set to wall tile
            _level.levelMap(x,y).terrainID = tWall
            _level.levelMap(x,y).visible = false
            _level.levelMap(x,y).seen = false
            _level.levelMap(x,y).hasMonster = false
            _level.levelMap(x,y).doorInfo.locked = false
            _level.levelMap(x,y).doorInfo.lockDifficulty = 0
            _level.levelMap(x,y).doorInfo.doorStrength = 0
            clearInventory _level.levelInv(x,y)
        next
    next
    _initializeGrid
    _drawMapToArray
    _generateItems
end sub

sub levelObject.putItemOnMap(x as integer, y as integer, inv as inventoryType)
    'Clear the item definition for this space.
    clearInventory _level.levelInv(x,y)
    'Take the item definition in inv and place it into the level's inventory at this space.
    _level.levelInv(x,y) = inv
end sub

'This function returns true if the tile at x,y is blocking.
function levelObject.isBlocking(x as integer, y as integer) as integer
    return _blockingTile(x,y)
end function

function levelObject.isDoorLocked(x as integer, y as integer) as integer
    return _level.levelMap(x,y).doorInfo.locked
end function

function levelObject.getTileID(x as integer, y as integer) as terrainIDs
    return _level.levelMap(x,y).terrainID
end function

function levelObject.getTerrainDescription(x as integer, y as integer) as string
    return _getTerrainInfo(x,y)
end function

function levelObject.getItemDescription(x as integer, y as integer) as string
    dim as string ret = "None"
    
    if _level.levelInv(x,y).classID <> iNone then
        ret = getInventoryItemDescription(_level.levelInv(x,y))
    endif
    
    return ret
end function

'Returns the class ID for the inventory item at x, y.
function levelObject.getInventoryClassID(x As Integer, y As Integer) As classIDs
   return _level.levelInv(x, y).classID
end function

function levelObject.hasItem(x as integer, y as integer) as integer
    'Look at inventory slot. If no class ID, then the slot is empty.
    if _level.levelInv(x,y).classID = iNone then
        return false
    else
        return true
    endif
end function

'This function returns the level environment by looking at the current level's
'wall color. For example, green walls represent a sewer, crimson walls represent
'a sanctum, etc. This method is used because the previous solution of using an
'enum to store environment values did not work properly when it came time to
'randomly select an environment.
function levelObject.getLevelDescription() as string
    dim levelName as string
    
    select case _level.wallColor
    case cTan: levelName = "Library"
    case cGreen: levelName = "Sewer"
    case cRed: levelName = "Volcanic Waste"
    case cPurple: levelName = "Castle"
    case cGray: levelName = "Cave"
    case cCrimson: levelName = "Sanctum"
    case cSienna: levelName = "Mine"
    case else: levelName = "Dungeon"
    end select
    
    return levelName
end function

'GET EMPTY SPOT returns true if an empty spot is found, and returns the spot's
'coordinates as a vector.
function levelObject.getEmptySpot(v as mapVector) as integer
    dim as integer ret = FALSE, hi
    dim as mapVector ev
    dim as terrainIDs tid
    
    'Check character spot.
    ev.vx = player.locX
    ev.vy = player.locY
    hi = hasItem(ev.vx, ev.vy)
    if hi = FALSE then
        ret = TRUE
        v = ev
    else
        'Check each tile around the character.
        for i as compass = north to northwest
            ev.vx = player.locX
            ev.vy = player.locY
            ev += i
            'Get the tile type.
            tid = getTileID(ev.vx, ev.vy)
            'Check to see if it already has an item.
            hi = hasItem(ev.vx, ev.vy)
            'If floor and no item, then found space.
            if (tid = tFloor) and (hi = FALSE) then
                v = ev
                ret = TRUE
                exit for
            endif
        next
    endif
    
    return ret
end function

'Level variable.
dim shared level as levelObject
