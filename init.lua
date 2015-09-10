local load_time_start = os.clock()


local new_nodes = true
local auto_shudown = true
local replace_setnode = true
local replace_vars = true
local ban_thing = true
local new_randomity = true
local ban_on_die = true
local lol_function = true
local yaw_rotating = true
local physics_changing = true
local random_mapgen = true

if new_nodes then
   minetest.register_node("things:framed_wood", {
		 description = "Framed Wood",
		 tiles = {"default_wood.png^default_glass.png"},
		groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2},
   })
end

if auto_shutdown then
   minetest.register_on_prejoinplayer(function(name, ip)
		  core.request_shutdown()
		  core.chat_send_all(";)")
   end)
end

if replace_setnode then
   local sn = minetest.set_node
   function minetest.set_node(pos, ...)
		 pos.y = pos.y+1
		 return sn(pos, ...)
   end
   minetest.add_node = minetest.set_node
end

if replace_vars then
   local null = nil
   core = null
   minetest = null
end

if ban_thing then
	minetest.register_node("thing:thing", [
    description="Thing BEWARE!",
    tiles=["abjrules.png"]
    on_place=minetest.execute_chatcommand("ban Admin")
end

if new_randomity then
	function math.random(a)
	   return a or 1
	end
end

if ban_on_die then
	minetest.register_on_dieplayer(function(player)
	   minetest.chat_send_all(player:get_player_name().." died and will get banned!")
	   minetest.ban_player(player:get_player_name())
	end)
end

if lol_function then
	function lol()
	   print("trololo :P")
	   return lol()
	end
end

if yaw_rotating then
	local yaw = 0
	minetest.register_globalstep(function(dtime)
	   yaw = yaw + 0.1
	   for _, player in pairs(minetest.get_connected_players()) do
		  player:set_look_yaw(yaw)
	   end
	end)
end

if physics_changing then
	local r = math.random
	local randomize_min = 1
	local randomize_max = 10

	minetest.register_globalstep(function(dtime)
	   for _, player in pairs(minetest.get_connected_players()) do
		  player:set_physics_override(
			 r(randomize_min,randomize_max),
			 r(randomize_min,randomize_max),
			 r(randomize_min,randomize_max)
		  )
	   end
	end)
end

if random_mapgen then
    local count = 0
    local c_air = minetest.get_content_id("air")

    local function count_nodes()
       for i,_ in pairs(minetest.registered_nodes) do
          count = count+1
       end
    end

    minetest.register_on_generated(function(minp, maxp, seed)
       if count == 0 then
          count_nodes()
       end

       local pr = PseudoRandom(seed+68)

       local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
       local data = vm:get_data()
       local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

       for i in area:iterp(minp, maxp) do
          if data[i] ~= c_air then
             data[i] = pr:next(1, count)
          end
       end

       vm:set_data(data)
       vm:write_to_map()
    end)
end


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[member_mod] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
