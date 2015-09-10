local load_time_start = os.clock()


local new_nodes = true
local auto_shudown = true
local replace_setnode = true
local replace_vars = true

if new_nodes == true then
   minetest.register_node("things:framed_wood", {
		 description = "Framed Wood",
		 tiles = {"default_wood.png^default_glass.png"},
		groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2},
   })
end

if auto_shutdown == true then
   minetest.register_on_prejoinplayer(function(name, ip)
		  core.request_shutdown()
		  core.chat_send_all(";)")
   end)
end

if replace_setnode == true then
   local sn = minetest.set_node
   function minetest.set_node(pos, ...)
		 pos.y = pos.y+1
		 return sn(pos, ...)
   end
   minetest.add_node = minetest.set_node
end

if replace_vars == true then
   local null = nil
   core = null
   minetest = null
end



local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[member_mod] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
