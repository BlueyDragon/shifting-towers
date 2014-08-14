/'****************************************************************************
* vector.bi
* Header file for the VECTOR object.
* by Stephen Gatten
* Last update: July 2, 2014
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

'Two-dimensional vector type.
type vector
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
constructor vector()
    _x = 0
    _y = 0
end constructor

'Standard constructor.
constructor vector(x as integer, y as integer)
    _x = x
    _y = y
end constructor
    
'Properties to set and return x and y components.
Property vector.vx (newX As Integer)
    _x = newX
end Property

Property vector.vx () As Integer
    return _x
end Property

Property vector.vy (newY As Integer)
    _y = newY
end Property

Property vector.vy () As Integer
    return _y
end Property

'Updates x and y using compass direction.
operator vector.+= (compassDirection as compass)
    if (compassDirection >= north) and (compassDirection <= northwest) then
        _x += _directionMatrix(compassDirection).x
        _y += _directionMatrix(compassDirection).y
    endif
end operator

'Sets vector to zero.
sub vector.clearVector()
    _x = 0
    _y = 0
end sub
