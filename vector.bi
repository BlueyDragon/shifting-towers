/'****************************************************************************
* vector.bi
* Header file for the MAPVECTOR object.
* by Stephen Gatten
* Last update: November 8, 2016
*****************************************************************************'/

'Compass directions.
enum compass
    north
    northeast
    east
    southeast
    south
    southwest
    west
    northwest
end enum

'Coordinates. The mapCoordinate type defines a location in the level array;
'It is the X and Y location of a point.
type mapCoordinate
    x as integer
    y as integer
end type

'Two-dimensional vector type.
type mapVector
    private:
    _x as integer
    _y as integer
    _directionMatrix(north to northwest) as mapCoordinate = {(0,-1),(1,-1),(1,0),(1,1),(0,1),(-1,1),(-1,0),(-1,-1)}
    
    public:
    declare constructor()
    declare constructor(x as integer, y as integer)
    
    declare property vx(newX as integer)
    declare property vx() as integer
    declare property vy(newY as integer)
    declare property vy() as integer
    
    declare operator += (compassDirection as compass)
    
    declare sub clearVector()
end type

'Empty constructor.
constructor mapVector()
    _x = 0
    _y = 0
end constructor

'Standard constructor.
constructor mapVector(x as integer, y as integer)
    _x = x
    _y = y
end constructor
    
'Properties to set and return x and y components.
Property mapVector.vx (newX As Integer)
    _x = newX
end Property

Property mapVector.vx () As Integer
    return _x
end Property

Property mapVector.vy (newY As Integer)
    _y = newY
end Property

Property mapVector.vy () As Integer
    return _y
end Property

'Updates x and y using compass direction.
operator mapVector.+= (compassDirection as compass)
    if (compassDirection >= north) and (compassDirection <= northwest) then
        _x += _directionMatrix(compassDirection).x
        _y += _directionMatrix(compassDirection).y
    endif
end operator

'Sets vector to zero.
sub mapVector.clearVector()
    _x = 0
    _y = 0
end sub
