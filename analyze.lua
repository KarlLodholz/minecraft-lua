local r = require("robot")
local c = require("component")
local shell = require("shell")
local g = c.geolyzer

local args, options = shell.parse(...)
local ax, ay, az = args[1]-1, args[2]-1, args[3]-1

local bld = {}
-- initialize the array
for i = 0, ax do
    bld[i] = {}
    for j = 0, ay do
        bld[i][j] = {}
        for k = 0, az do
            bld[i][j][k] = 0
        end
    end
end

bldIdx = {} --will be 2d array exmple:bldIdx["minecraft: stone"]{quantity, blx_idx}
blx_idx = 1 -- 0 is air


local function forward(sleep)
    while(not r.forward())
    do
        r.swing()
        if(sleep == true) then
            os.sleep(2)
        end
    end
end


local function turn(v) -- v=0 --> right // v=1 --> left
    if(v==0) then
        r.turnRight()
    else
        r.turnLeft()
    end
end


local function anlyznstr(x,y,z)
    -- analyze block and store value
    if(r.detect()) then
        local blk = g.analyze(3)
        local i, _ = string.find(blk.name, ":")
        local blk_name = string.sub(blk.name,i+1)
        print(blk.name)
        if(blk.properties.variant) then 
            blk_name = blk_name..":"..blk.properties.variant
        end

        if(bldIdx[blk_name] == nil) then-- if not yet indexed in the index table
            bldIdx[blk_name] = {0,blx_idx} --{quantity, block index}
            blx_idx = blx_idx + 1
        end
        --update build map
        bld[x][y][z] = bldIdx[blk_name][2]
        --increment bldIdx cnt
        bldIdx[blk_name][1] = bldIdx[blk_name][1] + 1
        --remove block infront of robot
        r.swing()
    end
    --move robot forward but keep trying until it works, maybe the chicken will move
    forward(nil)
end

-- main
local function main()
    
    for k = 0, az do
        for i = 0, ax do
            for j = 0, ay do
                anlyznstr(i*(((k+1)%2)*2-1) + ax*(k%2), j*(((i+1)%2)*2-1) + ay*(i%2) ,k)
            end
            -- break if done with path
            if(k == az and i == ax) then break end
            
            forward(nil)
            turn((ax*k+i)%2)
            if(i == ax) then
                while(not r.up()) do
                    r.swingUp()
                end
            else
                forward(nil)
            end
            turn((ax*k+i)%2)
        end
    end
    
    for n,t in pairs(bldIdx) do
        print(t[1],n)
    end
end

main()
