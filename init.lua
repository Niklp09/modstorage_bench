local storage = minetest.get_mod_storage()
local us = minetest.get_us_time

local function benchmark(name, func)
	local min, max = 0, 0
	local before = us()
	for i = 1, 100000 do
		local b2 = us()
		func(i)
		local took = us()- b2
		if took > max then
			max = took
		elseif took < min then
			min = took
		end
	end
	local after = us() - before
	print("checked funtion " .. name .. ":")
	print("avg: " .. after/100000 .. "us; min: " .. min .. "us; max: " .. max)
	print("--------------------")
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
	end
})
