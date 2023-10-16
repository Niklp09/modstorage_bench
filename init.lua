local mod_storage = minetest.get_mod_storage()
local get_time = minetest.get_us_time

local iterations = 100000
local batches = 3
local round_results = true
local benchmarks, duration

local function round(number, decimal_places)
	local multiplier = 10^(decimal_places or 0)
	return math.floor(number * multiplier + 0.5) / multiplier
end

local function pt(time)
	if round_results then
		if time > 1000000 then
			return round(time / 1000000, 2).."s"
		elseif time > 1000 then
			return round(time / 1000, 2).."ms"
		else
			return round(time, 2).."us"
		end
	else
		return time.."us"
	end
end

local function run_test(name, param_count, func)
	benchmarks = benchmarks + 1
	local dur, min, max, took = 0, 999999999, 0, 0
	for i = 1, iterations do
		local param1 = "abc"..i
		if param_count == 1 then
			took = get_time()
			func(param1)
			took = get_time() - took
		elseif param_count == 2 then
			local param2 = "xyz"..i
			took = get_time()
			func(param1, param2)
			took = get_time() - took
		else
			error("Invalid param_count: "..tostring(param_count))
		end
		if took < min then min = took end
		if took > max then max = took end
		dur = dur + took
	end
	duration = duration + dur
	print(name..": "..
		"   TIME: "..pt(dur)..
		"   MIN: "..pt(min)..
		"   MAX: "..pt(max)..
		"   AVG: "..pt(dur / iterations))
end

local function run_tests()
	for i = 1, batches do
		mod_storage:from_table({}) -- clear mod_storage
		benchmarks = 0
		duration = 0
		print("BATCH "..i..": test results with "..tostring(iterations).." iterations per function:")
		run_test("mod_storage:set_int()", 2, function(...) mod_storage:set_string(...) end)
		run_test("mod_storage:get_int()", 1, function(...) mod_storage:set_string(...) end)
		run_test("mod_storage:set_string()", 2, function(...) mod_storage:set_string(...) end)
		run_test("mod_storage:get_string()", 1, function(...) mod_storage:get_string(...) end)
		run_test("mod_storage:contains()", 1, function(...) mod_storage:contains(...) end)
		print(benchmarks.." benchmarks done")
		local avg_dur = duration / (benchmarks * iterations)
		print("Overall time spend for modstorage: "..pt(duration).." average duration per call: "..pt(avg_dur))
	end
	mod_storage:from_table({}) -- clear mod_storage again
end

minetest.register_chatcommand("test_modstorage_speed", {
	privs = { server = true },
	func = function(player_name)
		minetest.chat_send_player(player_name, "Starting modstorage speed test...")
		run_tests()
		return true, "Done "..benchmarks.." benchmarks in "..batches.." batches. Check console for results."
	end
})