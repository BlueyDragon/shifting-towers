'Room dimensions
#define roomSizeMin 4
#define roomSizeMax 8

'Total number of rooms
#define numberOfRoomsMin 20
#define numberOfRoomsMax 50

'Empty cell flag
#define emptycell 0

'Total level size, in blocks
#define mapWidth 100
#define mapHeight 100

'Grid cell size
const cellSize = 10

'Grid dimensions
const gridWidth = mapWidth \ cellSize
const gridHeight = mapHeight \ cellSize

'Coordinate type. Defines a location in the level array, the X and Y location of a point.
type mapCoordinate
    x as integer
    y as integer
end type

'Room dimension type. Defines the dimensions of a room and its center. 
type roomDimension
    rWidth as integer
    rHeight as integer
    rCenter as mapCoordinate
end type

'Room information type. Records the coordinates and size of a room, used to populate a list of rooms in the level.
type roomType
    rd as roomDimension         'Room width and height.
    topLeft as mapCoordinate    'Defines the rectangle of the room.
    bottomRight as mapCoordinate
end type

'Grid cell structure. Represents a cell within the grid, used to link cells and rooms together.
type cellType
    cellCoordinate as mapCoordinate 'The cell position.
    room as integer                 'Room ID, index into room array
end type

dim shared rooms(1 to numberOfRoomsMax) as roomType
dim shared grid(1 to gridWidth, 1 to gridHeight) as cellType    'Defines grid used to carve rooms
dim shared as integer numberOfRooms

'INITIALIZE GRID sets up the grid and room arrays for a level.
sub InitializeGrid
    dim as integer i, j, x, y, gx = 1. gy = 1

    'Clear the room array by zeroing everything out. Remember that "coord" types
    'always have an X AND a Y variable
    for i = 1 to numberOfRoomsMax
        rooms(i).roomDimension.rWidth = 0
        rooms(i).roomDimension.rHeight = 0
        rooms(i).roomDimension.rCenter.x = 0
        rooms(i).roomDimension.rCenter.y = 0
        rooms(i).topLeft.x = 0
        rooms(i).topLeft.y = 0
        rooms(i).bottomRight.x = 0
        rooms(i).bottomRight.y = 0
    next

    'Decide how many rooms to be in this level, then set their sizes.
    numberOfRooms = RandomRange(numberOfRoomsMin, numberOfRoomsMax)
    for i = 1 to numberOfRooms
        rooms(i).roomDimension.rWidth = RandomRange(roomSizeMin, roomSizeMax)
        rooms(i).roomDimension.rHeight = RandomRange(roomSizeMin, roomSizeMax)
    next

    'Clear the grid array.
    for i = 1 To gridWidth 
   	    for j = 1 To gridHeight
    		grid(i, j).cellCoordinate.x = gx
    		grid(i, j).cellCoordinate.y = gy
     		grid(i, j).room = emptycell
     		gy += cellSize
   	    next
   	    gy = 1
   	    gx += cellSize
    next

    'Add rooms to the grid.
    for i = 1 to numberOfRooms
        'Find an empty spot in the grid.
        do
            x = RandomRange(2, gridWidth - 1)
            y = RandomRange(2, gridHeight - 1)
        loop until grid(x,y).room = emptycell

        'Calculate room center.
        rooms(i).roomDimension.rCenter.x = grid(x,y).cellCoordinate.x + (rooms(i).roomDimension.rWidth \ 2)
        rooms(i).roomDimension.rCenter.y = grid(x,y).cellCoordinate.y + (rooms(i).roomDimension.rHeight \ 2)

        'Set the room's rectangle.
        rooms(i).topLeft.x = grid(x,y).cellCoordinate.x
        rooms(i).topLeft.y = grid(x,y).cellCoordinate.y
        rooms(i).bottomRight.x = grid(x,y).cellCoordinate.x + rooms(i).roomDimension.rWidth + 1
	    rooms(i).bottomRight.y = grid(x,y).cellCoordinate.y + rooms(i).roomDimension.rHeight + 1
   	
        'Save the room index
   	    grid(x, y).room = i
    next
end sub

'DRAW MAP TO ARRAY transfers the grid data to the map array once the rooms have been defined.
sub DrawMapToArray
    dim as integer i, x, y, pr, rr, rl, ru, kr

    'Draw the first room to map array
    for x = rooms(1).topLeft.x + 1 to rooms(1).bottomRight.x - 1
        for y = rooms(1).topLeft.y + 1 to rooms(1).bottomRight.y - 1
            level.lmap(x,y).terrainID = tFloor
        next
    next

    'Draw the rest of the rooms to the map array and connect them.
    for i = 2 to numberOfRooms
        for x = rooms(i).topLeft.x + 1 to rooms(i).bottomRight.x - 1
            for y = rooms(i).topLeft.y + 1 to rooms(i).bottomRight.y - 1
                level.lmap(x,y).terrainID = tFloor
            next
        next

        ConnectRooms i, i - 1
    next
end sub

'CONNECT ROOMS draws passable terrain between two rooms. It uses the "Manhattan distance 
'algorithm" to walk the level array from the "source" room to the "target" room, drawing the
'cooridor (of tFloor) as it goes along.
sub ConnectRooms(source as integer, target as integer)
    dim as integer index, x, y, located
    dim as mapCoordinate currentCell, lastCell

    currentCell = rooms(source).roomDimension.rCenter
    lastCell = rooms(target).roomDimension.rCenter

    x = currentCell.x
    y = currentCell.y

    'Check to see whether the target room x coordinate is left or right
    'of the source room x coordinate.
    'If the target is to the right
    if x < lastCell.x then
        located = FALSE

        'We move to the right (+1) until the X matches
        do
            x += 1
            if level.lmap(x, currentCell.y).terrainID = tWall then located = TRUE
            if (level.lmap(x, currentCell.y).terrainID = tFloor) AND (located = TRUE) then
                exit sub
            endif

            level.lmap(x, currentCell.y).terrainID = tFloor
        loop until x = lastCell.x
    endif

    'If the target is to the left
    if x > lastCell.x then
        located = FALSE

        'We move to the left (-1) until the X matches
        do
            x -= 1
            if level.lmap(x, currentCell.y).terrainID = tWall then located = TRUE
            if (level.lmap(x, currentCell.y).terrainID = tFloor) AND (located = TRUE) then
                exit sub
            endif

            level.lmap(x, currentCell.y).terrainID = tFloor
        loop until x = lastCell.x
    endif

    'Once we have the X coordinates matched, we do the same for the Y coordinates.
    'If the target is to the right
    if y < lastCell.y then
        located = FALSE

        'We move to the right (+1) until the X matches
        do
            y += 1
            if level.lmap(x,y).terrainID = tWall then located = TRUE
            if (level.lmap(x,y).terrainID = tFloor) AND (located = TRUE) then
                exit sub
            endif

            level.lmap(x,y).terrainID = tFloor
        loop until y = lastCell.y
    endif

    'If the target is to the right
    if y > lastCell.y then
        located = FALSE

        'We move to the right (-1) until the Y matches
        do
            y -= 1
            if level.lmap(x,y).terrainID = tWall then located = TRUE
            if (level.lmap(x,y).terrainID = tFloor) AND (located = TRUE) then
                exit sub
            endif

            level.lmap(x,y).terrainID = tFloor
        loop until y = lastCell.y
    endif

end sub