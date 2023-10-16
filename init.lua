local storage = minetest.get_mod_storage()
local us = minetest.get_us_time
local globalavg, benchmarks = 0, 0
local runs = 100000

-- https://stackoverflow.com/a/50082540
local function short(number, decimals)
	local power = 10^decimals
	return math.floor(number * power) / power
end

local function v(time)
	if time > 1000 then
		return short(time/1000, 2) .. "ms"
	end
	return short(time, 2) .. "us"
end

local function benchmark(name, func)
	benchmarks = benchmarks + 1
	local min, max = 0, 0
	local before = us()
	for i = 1, runs do
		local b2 = us()
		func(i)
		local took = us()- b2
		if took > max then
			max = took
		elseif took < min or min == 0 then
			min = took
		end
	end
	local after = us() - before
	print("checked funtion " .. name .. ":")
	print("total runtime: " .. v(after) .. "; avg: " .. v(after/runs) .. "; min: " .. v(min) .. "; max: " .. v(max))
	print("--------------------")
	globalavg = globalavg + after
end

minetest.register_chatcommand("bench", {
	func = function(name)
		-- contains
		benchmark("contains - static - nil key", function(i)
			storage:contains("mykey")
		end)

		benchmark("contains - random - nil key", function(i)
			storage:contains(i)
		end)

		storage:set_string("mykey", "abcd")

		benchmark("contains - static - set key", function(i)
			storage:contains("mykey")
		end)

		benchmark("contains - random - set key", function(i)
			storage:contains(i)
		end)

		-- get
		benchmark("get - static - nil key", function(i)
			storage:get("mykey2")
		end)

		benchmark("get - random - nil key", function(i)
			storage:get(i)
		end)

		benchmark("get - static - set key", function(i)
			storage:get("mykey")
		end)

		-- set_int
		benchmark("set - static", function(i)
			storage:set_string("mykey", "myvalue")
		end)

		benchmark("set - random - one key", function(i)
			storage:set_int("mynewkey", i)
		end)

		benchmark("set - random - random keys", function(i)
			storage:set_int(i, i)
		end)

		print("--------------------")
		print("Overall avg " .. v(globalavg/(benchmarks * runs)) .. "!")
	end
})