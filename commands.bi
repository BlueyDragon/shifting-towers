/'****************************************************************************
* commands.bi
* Subroutines and functions for controlling user-entered commands.
* by Stephen Gatten
* Last update: July 2, 2014
*****************************************************************************'/

'Opens a closed door if it is not locked.
function openDoor(x as integer, y as integer) as integer
    dim as integer ret = true, doorLocked
    
    'Check for locked door.
    doorLocked = level.isDoorLocked(x,y)
    if doorLocked = false then
        level.setTile x, y, tDoorOpen
    else
        ret = false
    endif
    
    return ret
end function

'Moves a character.
function moveCharacter(direction as compass) as integer
    dim as integer ret = false, block
    dim as mapVector v = mapVector(player.locX,player.locY)
    dim as terrainIDs tileID
    
    v += direction
    
    'Check to make sure we do not move off map.
    if(v.vx >= 1) and (v.vx <= mapWidth) then
        if(v.vy >= 1) and (v.vy <= mapHeight) then
            'Check for a blocking tile.
            block = level.isBlocking(v.vx, v.vy)
            
            'Move character
            if block = false then
                'Set the new character position.
                player.locX = v.vx : player.locY = v.vy
                ret = true
            else
                tileID = level.getTileID(v.vx, v.vy)
                select case tileID
                case tDoorClosed
                    ret = openDoor(v.vx, v.vy)
                    'if false, then print message.
                    if ret = false then
                        'print message here.
                    else
                    'set the new character position.
                    player.locX = v.vx : player.locY = v.vy
                    ret = true
                    endif
                case tStairUp
                    player.locX = v.vx : player.locY = v.vy
                    ret = true
                end select
            endif
        endif
    endif
    
    return ret
end function
