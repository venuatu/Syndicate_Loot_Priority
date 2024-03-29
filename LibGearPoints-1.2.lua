-- lib gear points stub for RCLootCouncil-EPGP
local MAJOR_VERSION = "LibGearPoints-1.2"
local MINOR_VERSION = 10210 -- bundled version is 10200
if _G.LibStub then
  local lib, _ = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
  if not lib then return end
  local guild = GetGuildInfo('player')
  local realm = GetRealmName()

  local function in_syndicate()
    if guild == nil then
      guild = GetGuildInfo('player')
    end
    if realm == nil then
      realm = GetRealmName()
    end
    return guild == 'Syndicate' or realm == 'Yojamba'
  end

  local l13 = LibStub("LibGearPoints-1.3", true)

  function lib:GetNumRecentItems()
    return l13:GetNumRecentItems()
  end

  function lib:GetRecentItemLink(i)
    return l13:GetRecentItemLink(i)
  end

  --- Return the currently set quality threshold.
  function lib:GetQualityThreshold()
    return l13:GetQualityThreshold()
  end

  --- Set the minimum quality threshold.
  -- @param itemQuality Lowest allowed item quality.
  function lib:SetQualityThreshold(itemQuality)
    return l13:SetQualityThreshold(itemQuality)
  end

  function lib:GetValue(item)
    if not item then return end

    local _, itemLink, rarity, ilvl, _, _, _, _, equipLoc = GetItemInfo(item)
    if not itemLink then return end

    if not in_syndicate() then
      local gp1, c1 = l13:GetValue(item)
      if not gp1 then return end
      return gp1, c1, ilvl, rarity, equipLoc
    end

    local iid = itemLink:match("item:(%d+):")
    local gp = SYN:RCEPGP(iid)

    return gp, 0, ilvl, rarity, equipLoc
  end

  local ace = LibStub("AceAddon-3.0", true)
  if not ace then return end

  local addon = ace:GetAddon("RCLootCouncil", true)
  if not addon then return end
  local RCEPGP = addon:GetModule("RCEPGP", true)
  if not RCEPGP then return end
  local RCVotingFrame = addon:GetModule("RCVotingFrame")
  local LibDialog = LibStub("LibDialog-1.0")
  local SynVF = RCEPGP:NewModule("SyndicateVotingFrame", "AceComm-3.0", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")


  local RCLootCouncilML = addon:GetModule("RCLootCouncilML")
  RCLootCouncilML.LootTableCompare = function (a, b) if a.gp and b.gp then return a.gp > b.gp end return 0 end

  local session = 1

  local function GetMenuInfo(name)
    local lootTable = RCVotingFrame:GetLootTable()
    if lootTable and lootTable[session] and lootTable[session].candidates
    and name and lootTable[session].candidates[name] then
      local data = lootTable[session].candidates[name]
      local responseGP = RCEPGP:GetResponseGP(data.response, data.isTier, data.isRelic)
      local editboxGP = RCVotingFrame:GetFrame().gpEditbox:GetNumber()
      local gp = RCEPGP:GetFinalGP(responseGP, editboxGP)
      local item = lootTable[session].link
      return data, name, item, responseGP, gp, nil
    else -- Error occurs
      return nil, "UNKNOWN", "UNKNOWN", "UNKNOWN", 0, 0 -- nil protection
    end
  end

  SynVF.rightClickEntries = {
    {
      {
        pos = 4,
        notCheckable = true,
        func = function(lootname)
          local data, player, link = GetMenuInfo(lootname)
          local item = SYN:find_class_item(link, data.class:lower())
          if not item then return end
          local gp = item['gp']
          local _, itemlink = GetItemInfo(item['id'])

          local responseGP = RCEPGP:GetResponseGP(data.response, data.isTier, data.isRelic)
          gp = RCEPGP:GetFinalGP(responseGP, gp)

          SendChatMessage(SYN:strconcat('Awarding ', itemlink or item['name'], ' (', gp, ' GP) instead of ', link), 'GUILD')

          local args = RCVotingFrame:GetAwardPopupData(session, player, data)
          args.gp = gp
          LibDialog:Spawn("RCEPGP_CONFIRM_AWARD", args)
        end,
        text = function(lootname)
          local data, _, link = GetMenuInfo(lootname)
          local itemname = 'unknown'
          local item = SYN:find_class_item(link, data.class)
          local gp = '0'
          if item then
            gp = item['gp']
            itemname = item['name']
          end
          local responseGP = RCEPGP:GetResponseGP(data.response, data.isTier, data.isRelic)
          gp = RCEPGP:GetFinalGP(responseGP, gp)
          return 'Award ' .. itemname .. ' (' .. gp .. ' GP, ' .. responseGP .. ')'
        end,
        disabled = function(lootname)
          local data, _, link = GetMenuInfo(lootname)
          local item = SYN:find_class_item(link, data.class:lower())
          return not item
          -- return (not EPGP:CanIncGPBy(item, gp)) and gp and (gp ~= 0)
        end,
      }
    }
  }

  local function apply_ep_awards()
    if not _G['EPGP'] then
      print('synhook didnt see epgp classic')
      return
    end
    EPGP:GetModule('gptooltip').db.profile.enabled = false
    local bossprof = EPGP:GetModule('boss').db.profile
    bossprof.bossreward = {
      [649] = 1600,--maulgar
      [650] = 1800,--gruul
      [651] = 1800,--magtheridon
      [623] = 1800,--Hydross
      [624] = 1800,--Lurker
      [625] = 1800,--Leotheras
      [626] = 1800,--Fathom
      [627] = 1800,--Tidewalker
      [628] = 2100,--Vashj
      [730] = 1800,--Al'ar
      [731] = 1800,--Void Reaver
      [732] = 1800,--Solarian
      [733] = 2100,--Kael'thas
    }
    bossprof.enabled = true
    bossprof.autoreward = true
  end

  function SynVF:OnInitialize()
    if not in_syndicate() then return end
    if not RCVotingFrame.scrollCols then -- RCVotingFrame hasn't been initialized.
      return self:ScheduleTimer("OnInitialize", 0.5)
    end
    RCEPGP.db.columns.bid = false
    RCEPGP.db.columns.bidTimesPR = false
    self:RegisterMessage("RCSessionChangedPre", "OnMessageReceived")
    RCEPGP:AddRightClickMenu(_G["RCLootCouncil_VotingFrame_RightclickMenu"], RCVotingFrame.rightClickEntries, self.rightClickEntries)
    apply_ep_awards()
    self.initialize = true
  end

  function SynVF:OnMessageReceived(msg, ...)
    if msg == "RCSessionChangedPre" then
      local s = unpack({...})
      session = s
      -- self:Update()
    end
  end

end
