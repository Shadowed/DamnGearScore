DGS = {}
local frame = CreateFrame("Frame")
local playerName = UnitName("player")
local itemSet, setData = {}, {}

DGSData:Load(DGS)

function DGS:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if( string.match(prefix, "GearScore") or string.match(prefix, "^GSY") ) then
		print(string.format("[%s] [%s] from [%s] (%s)", prefix, message, sender, channel))
	end
	
	if( sender == playerName ) then return end
	if( prefix == "GSY_Request" ) then
		SendAddonMessage("GSY_Version", GEARSCORE_VERSION, "WHISPER", sender)
	end
end

function DGS:CreateItemSet(targetLevel)
	table.wipe(itemSet)
	table.wipe(setData)
	
	-- Find items in the database that match the target item level
	for _, slot in pairs(self.CLASS_SLOTS) do
		if( not itemSet[slot] ) then
			local closetID, closetDiff
			for itemLevel, itemID in pairs(self.GEAR_MAP[slot]) do
				if( GetItemInfo(itemID) ) then
					local diff = math.abs(targetLevel - itemLevel)
					local diffPercent = diff / targetLevel
					if( not closetDiff or closetDiff > diffPercent ) then
						closetID = itemID
						closetDiff = diffPercent
					end
				end
			end
			
			if( closetID ) then
				itemSet[slot] = closetID
			end
		end
	end
	
	-- Figure out GearScore
	local average, added = 0, 0
	for slot, itemID in pairs(itemSet) do
		local rarity, itemLevel = select(3, GetItemInfo(itemID))
		rarity = rarity > 4 and 4 or rarity < 2 and 2 or rarity
		
		setData[slot] = math.floor(((itemLevel - self.QUALITY_MAP[rarity][1]) / self.QUALITY_MAP[rarity][2]) * self.SLOT_MODIFIERS[slot] * 1.8618)
		
		average = average + itemLevel
		added = added + 1
	end
	
	local total = 0
	for _, score in pairs(setData) do total = total + score end
	setData.total = total
	setData.average = math.floor(average / added)
end

function DGS:FakeGearData(itemLevel, score, nameFor, nameFrom, race, class, level, guild)
	class = class and self.CLASS_MAP[string.upper(class)] or self.CLASS_MAP[select(2, UnitClass("player"))]
	race = race and self.RACE_MAP[race] or self.RACE_MAP[select(2, UnitRace("player"))]
	
	local comm = {
		string.trim(nameFor), -- name
		score, -- score
		-- yyyymmddhhmm, the 24 - hour is to keep it accurate with the terrible GS format
		string.gsub(date("%Y%m%dHOUR%m"), "HOUR", (24 - date("%H"))), 
		class, -- class
		itemLevel, -- average ilvl
		self.RACE_MAP[select(2, UnitRace("player"))], -- race
		UnitFactionGroup("player") == "Horde" and "H" or "A", -- faction
		"XXX", -- Unknown location (If this was an empty string GS users would get errors viewing this most likely)
		tonumber(level) or UnitLevel("player"), -- level
		guild or (GetGuildInfo("player")) or "", -- guild name
		string.trim(nameFrom), -- scanner name
	}
	
	-- <itemID>:<enchantID>, if no enchant then <enchantID> == 0
	for id=1, 18 do
		local found
		for itemType, slotID in pairs(self.REVERSE_EQUIPS) do
			if( ( ( itemType == "INVTYPE_TRINKET" and ( id == 13 or id == 14 ) )
				or ( itemType == "INVTYPE_FINGER" and ( id == 11 or id == 12 ) )
				or slotID == id )
				and itemSet[itemType] ) then

				table.insert(comm, itemSet[itemType] .. ":0")
				found = true
				break
			end
		end

		if( not found ) then
			table.insert(comm, "0:0")
		end
	end
		
	local message = table.concat(comm, "$") .. "$"
	SendAddonMessage("GSY", message, "GUILD")
	
	local instanceType = select(2, IsInInstance())
	if( instanceType == "arena" or instanceType == "pvp" ) then
		SendAddonMessage("GSY", message, "BATTLEGROUND")
	elseif( GetNumRaidMembers() > 0 ) then
		SendAddonMessage("GSY", message, "RAID")
	elseif( GetNumPartyMembers() > 0 ) then
		SendAddonMessage("GSY", message, "PARTY")
	end
end

frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", function(self, event, ...)
	DGS[event](DGS, ...)
end)

function DGS:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99DGS|r: " .. msg)
end
