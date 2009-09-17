local Config = {}

local config = LibStub("AceConfig-3.0")
local dialog = LibStub("AceConfigDialog-3.0")
local registry = LibStub("AceConfigRegistry-3.0")
local options
local fakeData = {}

local function resetFakeData()
	fakeData.nameFor = UnitName("player")
	fakeData.nameFrom = "God"
	fakeData.faction = UnitFactionGroup("player") == "Horde" and "H" or "A"
	fakeData.race = DGS.RACE_MAP[select(2, UnitRace("player"))]
	fakeData.class = DGS.CLASS_MAP[select(2, UnitClass("player"))]
end

local function loadOptions()
	options = {}
	options.type = "group"
	options.name = "DamnGearScore"
	options.handler = Config
	
	local classTable, raceTable = {}, {}
	for token, abbrev in pairs(DGS.RACE_MAP) do raceTable[abbrev] = token end
	for token, abbrev in pairs(DGS.CLASS_MAP) do classTable[abbrev] = token end
		
	options.general = {
		type = "group",
		name = "General",
		childGroups = "tab",
		args = {
			fake = {
				order = 1,
				type = "group",	
				name = "Fake Score",
				set = function(info, value) fakeData[info[#(info)]] = value end,
				get = function(info) return fakeData[info[#(info)]] end,
				args = {
					nameFor = {
						order = 1,
						type = "input",
						name = "Score for",
						desc = "Who the faked score should be for, if you enter your own name then it will create a fake score for you.",
					},
					nameFrom = {
						order = 2,
						type = "input",
						name = "Scanned by",
						desc = "Name of the person who scanned the score, you can enter any name you like! Currently this cannot be traced, if you enter someone elses name then nobody will know it came from you.",	
					},
					sep = {
						order = 3,
						type = "description",
						name = "",
					},
					faction = {
						order = 4,
						type = "select",
						name = "Faction",
						desc = "Faction that this data came from.",	
						value = {["H"] = "Horde", ["A"] = "Alliance"},
					},
					race = {
						order = 5,
						type = "select",
						name = "Race",
						desc = "Race to show the character as being.",
						values = raceTable,	
					},
					class = {
						order = 6,
						type = "select",
						name = "Class",
						desc = "Class to show the character as being.",
					},
					sep = {
						order = 7,
						type = "description"	
					},
					armorType = {
						order = 7,
						type = "select",
						name = "Armor type",
						desc = "Type of armor the set should be built off of	
					},
				},
			}.	
		},
	}
end

-- Slash commands
SLASH_DGS1 = "/damngearscore"
SLASH_DGS2 = "/dgs"
SLASH_DGS3 = "/damngear"
SlashCmdList["DGS"] = function(msg)
	if( not options ) then
		loadOptions()
		
		config:RegisterOptionsTable("DamnGearScore", options)
		dialog:SetDefaultSize("DamnGearScore", 300, 500)
	end

	dialog:Open("DamnGearScore")
end
