-- physics polygon intersection
display.setStatusBar(display.HiddenStatusBar)

require("physics")
physics.start()
physics.setGravity(0,0)
physics.setDrawMode("hybrid")

sWidth, sHeight = display.contentWidth, display.contentHeight

require("wall")
require("clipper")

newWall{ name="left", }
newWall{ name="right", }
newWall{ name="top", }
newWall{ name="bottom", }
	
-- draw polygon with the form {x,y},{x,y},...}
function drawLines(poly, c, grp, thickness)
	for i=1, #poly-1 do
		local line = display.newLine(grp, poly[i].x, poly[i].y, poly[i+1].x, poly[i+1].y)
		line.strokeWidth = thickness or 15
		line.stroke = {c.r/255,c.g/255,c.b/255}
	end
	line = display.newLine(grp, poly[1].x, poly[1].y, poly[#poly].x, poly[#poly].y)
	line.strokeWidth = thickness or 15
	line.stroke = {c.r/255,c.g/255,c.b/255}
end

-- converts a polgyon made from {x,y} pairs to a Box2D shape poly
function pairPolyToBoxPoly( shape )
	local output = {}
	for i=1, #shape do
		output[#output+1] = shape[i].x
		output[#output+1] = shape[i].y
	end
	return output
end

-- returns a display object's polygon in world coordinates
function localToContentPoly( self, poly )
	local output = {}
	for i=1, #poly do
		local pt = poly[i]
		local x, y = self:localToContent( pt.x, pt.y )
		output[i] = {x=x,y=y}
	end
	return output
end

-- polygons two test for intersection
shape = {{x=-100, y=-100}, {x=100, y=-100}, {x=100, y=100}, {x=-100, y=100}}

-- create bodies
one = display.newGroup()
two = display.newGroup()
physics.addBody(one,{bounce=1, filter={groupIndex=-1}, shape=pairPolyToBoxPoly(shape)})
physics.addBody(two,{bounce=1, filter={groupIndex=-1}, shape=pairPolyToBoxPoly(shape)})
one.shape = shape
two.shape = shape
one.x, one.y = 200, 200
two.x, two.y = 200, 400
one.localToContentPoly = localToContentPoly
two.localToContentPoly = localToContentPoly
mult = 2
one:applyLinearImpulse(math.random(-5,5)*mult, math.random(-5,5)*mult, one.x, one.y-10)
two:applyLinearImpulse(math.random(-5,5)*mult, math.random(-5,5)*mult, two.x, two.y+10)

-- intersection layer
overlay = display.newGroup()

-- check for intersections
function enterFrame()
	overlay:removeSelf()
	overlay = display.newGroup()
	local a, b = one:localToContentPoly( one.shape ), two:localToContentPoly( two.shape )
	local list, hits = isPolygonIntersection( a, b )
	if (hits) then
		drawLines( list, {r=255,g=0,b=0}, overlay, 20 )
	end
end
Runtime:addEventListener("enterFrame",enterFrame)
