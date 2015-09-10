local load_time_start = os.clock()



local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[member_mod] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
