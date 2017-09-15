-- http://rosettacode.org/wiki/Sutherland-Hodgman_polygon_clipping#Lua

-- copies the points from a list of coords, table of points or display group into a new table of {x,y} points
local function copyToPointsTable( points )
	local tbl = {}
	
	local count = points.numChildren
	if (count == nil) then
		count = #points
	end
	
	local isCoords = (type(points[1]) == "number")
	local step = 1
	if (isCoords) then
		step = 2
	end
	
	for i=1, count, step do
		if (isCoords) then
			tbl[#tbl+1] = {x=points[i],y=points[i+1]}
		else
			tbl[#tbl+1] = {x=points[i].x,y=points[i].y}
		end
	end
	
	return tbl
end

--[[
	Description:
		Takes two polygons of the form {{x,y},{x,y},...} and determines if they intersect.
		Accepts parameters as display groups, tables of points {x,y} or lists of coords {x,y,x,y,...}
	
	Parameters:
		subjectPolygon: first polygon to intersect with the second
		clipPolygon: second polygon to intersect with the first
	
	Returns:
		Polygon of points of intersection between the two input polygons.
		True if the two do intersect, false if they are not touching.
	
	Example:
		subjectPolygon = {{x=50, y=150}, {x=200, y=50}, {x=350, y=150}, {x=350, y=300}, {x=250, y=300}, {x=200, y=250}, {x=150, y=350}, {x=100, y=250}, {x=100, y=200}}
		clipPolygon = {{x=100, y=100}, {x=300, y=100}, {x=300, y=300}, {x=100, y=300}}
		outputList, intersects = clip(subjectPolygon, clipPolygon)
	
	Ref:
		http://rosettacode.org/wiki/Sutherland-Hodgman_polygon_clipping#Lua
]]--
function isPolygonIntersection( subjectPolygon, clipPolygon )
	local subjectPolygon = copyToPointsTable( subjectPolygon )
	local clipPolygon = copyToPointsTable( clipPolygon )
	
	local function inside(p, cp1, cp2)
		return (cp2.x-cp1.x)*(p.y-cp1.y) > (cp2.y-cp1.y)*(p.x-cp1.x)
	end
	
	local function intersection(cp1, cp2, s, e)
		local dcx, dcy = cp1.x-cp2.x, cp1.y-cp2.y
		local dpx, dpy = s.x-e.x, s.y-e.y
		local n1 = cp1.x*cp2.y - cp1.y*cp2.x
		local n2 = s.x*e.y - s.y*e.x
		local n3 = 1 / (dcx*dpy - dcy*dpx)
		local x = (n1*dpx - n2*dcx) * n3
		local y = (n1*dpy - n2*dcy) * n3
		return {x=x, y=y}
	end
	
	local outputList = subjectPolygon
	local cp1 = clipPolygon[#clipPolygon]
	
	for _, cp2 in ipairs(clipPolygon) do  -- WP clipEdge is cp1,cp2 here
		local inputList = outputList
		outputList = {}
		local s = inputList[#inputList]
		for _, e in ipairs(inputList) do
			if inside(e, cp1, cp2) then
				if not inside(s, cp1, cp2) then
					outputList[#outputList+1] = intersection(cp1, cp2, s, e)
				end
				outputList[#outputList+1] = e
			elseif inside(s, cp1, cp2) then
				outputList[#outputList+1] = intersection(cp1, cp2, s, e)
			end
			s = e
		end
		cp1 = cp2
	end
	
	return outputList, #outputList > 0
end
