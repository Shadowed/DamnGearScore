dofile("rawdata.lua")

--[[
-- This will scan all locally cached items and categorize them, then they get parsed and will be used as the base for calculating new sets
TestLog = {}
local data = {}
local validArmor = {["Cloth"] = 1, ["Leather"] = 1, ["Mail"] = 1, ["Plate"] = 1, ["Shields"] = true, ["Librams"] = true, ["Idols"] = true, ["Totems"] = true, ["Bows"] = true, ["One-Handed Maces"] = true, ["Two-Handed Maces"] = true, ["Miscellaneous"] = true, ["Sigils"] = true, ["Wands"] = true, ["Two-Handed Axes"] = true, ["Two-Handed Swords"] = true, ["One-Handed Axes"] = true, ["One-Handed Swords"] = true, ["Polearms"] = true, ["Staves"] = true, ["Thrown"] = true, ["Crossbows"] = true, ["Guns"] = true, ["Daggers"] = true}

for i=1, 100000 do
   local name, link, quality, iLvl, _, _, armorType, _, slot = GetItemInfo(i)
   if( name and validArmor[armorType] and iLvl > 120 ) then
      data[armorType] = data[armorType] or {}
      data[armorType][slot] = data[armorType][slot] or {}
      
      if( not data[armorType][slot][iLvl] ) then
         data[armorType][slot][iLvl] = i .. ":" .. name
      end
   end
end

data.Cloak = CopyTable(data.Cloth.INVTYPE_CLOAK)
data.Cloth.INVTYPE_CLOAKS = nil
TestLog = data
]]

local file = io.open("items.lua", "w")
file:write("DGSData.items = {\n")

for itemType, list in pairs(TestLog) do
	file:write(string.format("	[\"%s\"] = {\n", itemType))
	for equipLocation, items in pairs(list) do
		file:write(string.format("		[\"%s\"] = {\n", equipLocation))
			
		local sortedList = {}
		for itemLevel in pairs(items) do table.insert(sortedList, itemLevel) end
		table.sort(sortedList, function(a, b) return a < b end)

		for _, itemLevel in pairs(sortedList) do
			local itemID, itemName = string.match(items[itemLevel], "^([0-9]+):(.+)")
			file:write(string.format("			[%s] = %s, -- %s\n", itemLevel, itemID, itemName))
		end
		file:write("		},\n")
	end
	
	file:write("	},\n")
end

file:write("}\n")
file:flush()
file:close()
