local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local I = Cell.iFuncs
local P = Cell.pixelPerfectFuncs
local A = Cell.animations

-- local LibCLHealth = LibStub("LibCombatLogHealth-1.0")

local UnitGUID = UnitGUID
-- local UnitHealth = LibCLHealth.UnitHealth
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitIsUnit = UnitIsUnit
local UnitIsConnected = UnitIsConnected
local UnitIsAFK = UnitIsAFK
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local UnitInRange = UnitInRange
local UnitIsVisible = UnitIsVisible
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local GetTime = GetTime
local GetRaidTargetIndex = GetRaidTargetIndex
local GetReadyCheckStatus = GetReadyCheckStatus
local UnitHasVehicleUI = UnitHasVehicleUI
-- local UnitInVehicle = UnitInVehicle
-- local UnitUsingVehicle = UnitUsingVehicle
local UnitIsCharmed = UnitIsCharmed
local UnitIsPlayer = UnitIsPlayer
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local UnitExists = UnitExists
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InCombatLockdown = InCombatLockdown
local UnitPhaseReason = UnitPhaseReason
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local IsInRaid = IsInRaid
local UnitDetailedThreatSituation = UnitDetailedThreatSituation

local barAnimationType, highlightEnabled, predictionEnabled, absorbEnabled, shieldEnabled, overshieldEnabled

-------------------------------------------------
-- unit button func declarations
-------------------------------------------------
local UnitButton_UpdateAuras, UnitButton_UpdateRole, UnitButton_UpdateLeader, UnitButton_UpdateStatusIcon, UnitButton_UpdateStatusText, UnitButton_UpdateColor
local UnitButton_UpdatePowerMax, UnitButton_UpdatePower, UnitButton_UpdatePowerType

-------------------------------------------------
-- unit button init indicators
-------------------------------------------------
local indicatorsInitialized
local enabledIndicators, indicatorNums, indicatorCustoms = {}, {}, {}
local bigDebuffs = {}

local function UpdateIndicatorParentVisibility(b, indicatorName, enabled)
    if not (indicatorName == "debuffs" or indicatorName == "defensiveCooldowns" or indicatorName == "externalCooldowns" or indicatorName == "dispels") then
        return
    end

    if enabled then
        b.indicators[indicatorName]:Show()
    else
        b.indicators[indicatorName]:Hide()
    end
end

local function UpdateIndicators(layout, indicatorName, setting, value, value2)
    if layout and layout ~= Cell.vars.currentLayout then return end

    F:Debug("|cffff7777UpdateIndicators:|r ", layout, indicatorName, setting, value, value2)
    if not indicatorName then -- init
        wipe(enabledIndicators)
        wipe(indicatorNums)
        F:IterateAllUnitButtons(function(b)
            I:RemoveAllCustomIndicators(b)
        end)

        for _, t in pairs(Cell.vars.currentLayoutTable["indicators"]) do
            -- update enabled
            if t["enabled"] then
                enabledIndicators[t["indicatorName"]] = true
            end
            -- update num
            if t["num"] then
                indicatorNums[t["indicatorName"]] = t["num"]
            end
            -- update aoehealing
            if t["indicatorName"] == "aoeHealing" then
                I:EnableAoEHealing(t["enabled"])
            end
            -- update targetCounter
            if t["indicatorName"] == "targetCounter" then
                I:EnableTargetCounter(t["enabled"])
            end
            -- update targetedSpells
            if t["indicatorName"] == "targetedSpells" then
                I:EnableTargetedSpells(t["enabled"])
                Cell:Fire("UpdateTargetedSpells", nil, t["spells"], t["glow"])
            end
            -- update bigDebuffs
            if t["indicatorName"] == "debuffs" then
                bigDebuffs = F:ConvertTable(t["bigDebuffs"])
            end
            -- update custom
            if t["dispellableByMe"] ~= nil then
                indicatorCustoms[t["indicatorName"]] = t["dispellableByMe"]
            end
            -- if t["castByMe"] ~= nil then
            --     indicatorCustoms[t["indicatorName"]] = t["castByMe"]
            -- end
            if t["hideFull"] ~= nil then
                indicatorCustoms[t["indicatorName"]] = t["hideFull"]
            end
            if t["onlyShowTopGlow"] ~= nil then
                indicatorCustoms[t["indicatorName"]] = t["onlyShowTopGlow"]
            end
            -- update indicators
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[t["indicatorName"]] or I:CreateIndicator(b, t)
                -- update position
                if t["position"] then
                    P:ClearPoints(indicator)
                    P:Point(indicator, t["position"][1], b, t["position"][2], t["position"][3], t["position"][4])
                end
                -- update anchor
                if t["anchor"] then
                    indicator:SetAnchor(t["anchor"])
                end
                -- update frameLevel
                if t["frameLevel"] then
                    indicator:SetFrameLevel(b.widget.overlayFrame:GetFrameLevel()+t["frameLevel"])
                end
                -- update size
                if t["size"] then
                    P:Size(indicator, t["size"][1], t["size"][2])
                end
                -- update thickness
                if t["thickness"] then
                    indicator:SetThickness(t["thickness"])
                end
                -- update border
                if t["border"] then
                    indicator:SetBorder(t["border"])
                end
                -- update height
                if t["height"] then
                    P:Height(indicator, t["height"])
                end
                -- update height
                if t["textWidth"] then
                    indicator:UpdateTextWidth(t["textWidth"])
                end
                -- update alpha
                if t["alpha"] then
                    indicator:SetAlpha(t["alpha"])
                end
                -- update orientation
                if t["orientation"] then
                    indicator:SetOrientation(t["orientation"])
                end
                -- update font
                if t["font"] then
                    indicator:SetFont(unpack(t["font"]))
                end
                -- update format
                if t["format"] then
                    indicator:SetFormat(t["format"])
                    b.func.UpdateHealthText()
                end
                -- update color
                if t["color"] then
                    indicator:SetColor(unpack(t["color"]))
                end
                -- update colors
                if t["colors"] then
                    indicator:SetColors(t["colors"])
                end
                -- update dispel highlight
                if type(t["enableHighlight"]) == "boolean" then
                    indicator:EnableHighlight(t["enableHighlight"])
                end
                -- update duration
                if type(t["showDuration"]) == "boolean" then
                    indicator:ShowDuration(t["showDuration"])
                end
                -- update circled nums
                if type(t["circledStackNums"]) == "boolean" then
                    indicator:SetCircledStackNums(t["circledStackNums"])
                end
                -- update vehicleNamePosition
                if t["vehicleNamePosition"] then
                    indicator:UpdateVehicleNamePosition(t["vehicleNamePosition"])
                end
                -- update custom texture
                if t["customTextures"] then
                    indicator:SetCustomTexture(t["customTextures"])
                    UnitButton_UpdateRole(b)
                end
                -- init
                -- update name visibility
                if t["indicatorName"] == "nameText" then
                    if t["enabled"] then
                        indicator:Show()
                    else
                        indicator:Hide()
                    end
                elseif t["indicatorName"] == "playerRaidIcon" then
                    b.func.UpdatePlayerRaidIcon(t["enabled"])
                elseif t["indicatorName"] == "targetRaidIcon" then
                    b.func.UpdateTargetRaidIcon(t["enabled"])
                else
                    UpdateIndicatorParentVisibility(b, t["indicatorName"], t["enabled"])
                end
            end)
        end
        indicatorsInitialized = true
    else
        -- changed in IndicatorsTab
        if setting == "enabled" then
            enabledIndicators[indicatorName] = value

            if indicatorName == "aoeHealing" then
                I:EnableAoEHealing(value)
            elseif indicatorName == "targetCounter" then
                I:EnableTargetCounter(value)
            elseif indicatorName == "targetedSpells" then
                I:EnableTargetedSpells(value)
            elseif indicatorName == "roleIcon" then
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateRole(b)
                end)
            elseif indicatorName == "leaderIcon" then
                F:IterateAllUnitButtons(function(b)
                    UnitButton_UpdateLeader(b)
                end)
            elseif indicatorName == "playerRaidIcon" then
                F:IterateAllUnitButtons(function(b)
                    b.func.UpdatePlayerRaidIcon(value)
                end)
            elseif indicatorName == "targetRaidIcon" then
                F:IterateAllUnitButtons(function(b)
                    b.func.UpdateTargetRaidIcon(value)
                end)
            elseif indicatorName == "nameText" then
                F:IterateAllUnitButtons(function(b)
                    if value then
                        b.indicators[indicatorName]:Show()
                    else
                        b.indicators[indicatorName]:Hide()
                    end
                end)
            elseif indicatorName == "statusText" then
                F:IterateAllUnitButtons(function(b)
                    b.func.UpdateStatusText()
                end)
            elseif indicatorName == "healthText" then
                F:IterateAllUnitButtons(function(b)
                    b.func.UpdateHealthText()
                end)
            elseif indicatorName == "shieldBar" then
                F:IterateAllUnitButtons(function(b)
                    b.func.UpdateShield()
                end)
            else
                -- refresh
                F:IterateAllUnitButtons(function(b)
                    UpdateIndicatorParentVisibility(b, indicatorName, value)
                    if not value then
                        b.indicators[indicatorName]:Hide() -- hide indicators which is shown right now
                    end
                    UnitButton_UpdateAuras(b)
                end)
            end
        elseif setting == "position" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P:ClearPoints(indicator)
                P:Point(indicator, value[1], b, value[2], value[3], value[4])
            end)
        elseif setting == "anchor" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetAnchor(value)
            end)
        elseif setting == "frameLevel" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetFrameLevel(b.widget.overlayFrame:GetFrameLevel()+value)
            end)
        elseif setting == "size" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P:Size(indicator, value[1], value[2])
                if indicatorName == "debuffs" then
                    -- update debuffs' normal/big icon sizes
                    UnitButton_UpdateAuras(b)
                end
            end)
        elseif setting == "size-border" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P:Size(indicator, value[1], value[2])
                indicator:SetBorder(value[3])
            end)
        elseif setting == "thickness" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetThickness(value)
            end)
        elseif setting == "height" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                P:Height(indicator, value)
            end)
        elseif setting == "textWidth" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:UpdateTextWidth(value)
            end)
        elseif setting == "alpha" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetAlpha(value)
            end)
        elseif setting == "orientation" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetOrientation(value)
            end)
        elseif setting == "font" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetFont(unpack(value))
            end)
        elseif setting == "format" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetFormat(value)
                b.func.UpdateHealthText()
            end)
        elseif setting == "color" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetColor(unpack(value))
            end)
        elseif setting == "colors" then --! NOTE: for customColors。 其他的colors不调用widget.func，不发出通知，因为这些指示器都使用OnUpdate更新颜色。
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetColors(value)
            end)
        elseif setting == "nameColor" then
            F:IterateAllUnitButtons(function(b)
                b.func.UpdateColor()
            end)
        elseif setting == "vehicleNamePosition" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:UpdateVehicleNamePosition(value)
            end)
        elseif setting == "statusColors" then
            F:IterateAllUnitButtons(function(b)
                UnitButton_UpdateStatusText(b)
            end)
        elseif setting == "num" then
            indicatorNums[indicatorName] = value
            -- refresh
            F:IterateAllUnitButtons(function(b)
                UnitButton_UpdateAuras(b)
            end)
        elseif setting == "customTextures" then
            F:IterateAllUnitButtons(function(b)
                local indicator = b.indicators[indicatorName]
                indicator:SetCustomTexture(value)
                UnitButton_UpdateRole(b)
            end)
        elseif setting == "checkbutton" then
            if value == "hideFull" then
                --! 血量文字指示器需要立即被刷新
                indicatorCustoms[indicatorName] = value2
                F:IterateAllUnitButtons(function(b)
                    b.func.UpdateHealthText()
                end)
            elseif value == "enableHighlight" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:EnableHighlight(value2)
                    UnitButton_UpdateAuras(b)
                end)
            elseif value == "showDuration" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:ShowDuration(value2)
                    UnitButton_UpdateAuras(b)
                end)
            elseif value == "circledStackNums" then
                F:IterateAllUnitButtons(function(b)
                    b.indicators[indicatorName]:SetCircledStackNums(value2)
                    UnitButton_UpdateAuras(b)
                end)
            else
                indicatorCustoms[indicatorName] = value2
            end
        elseif setting == "create" then
            F:IterateAllUnitButtons(function(b)
                local indicator = I:CreateIndicator(b, value)
                -- update position
                if value["position"] then
                    P:ClearPoints(indicator)
                    P:Point(indicator, value["position"][1], b, value["position"][2], value["position"][3], value["position"][4])
                end
                -- update anchor
                if value["anchor"] then
                    indicator:SetAnchor(value["anchor"])
                end
                -- update size
                if value["size"] then
                    P:Size(indicator, value["size"][1], value["size"][2])
                end
                -- update orientation
                if value["orientation"] then
                    indicator:SetOrientation(value["orientation"])
                end
                -- update font
                if value["font"] then
                    indicator:SetFont(unpack(value["font"]))
                end
                -- update color
                if value["color"] then
                    indicator:SetColor(unpack(value["color"]))
                end
                -- update colors
                if value["colors"] then
                    indicator:SetColors(value["colors"])
                end
                -- update showDuration
                if value["showDuration"] then
                    indicator:ShowDuration(value["showDuration"])
                end
            end)
        elseif setting == "remove" then
            F:IterateAllUnitButtons(function(b)
                I:RemoveIndicator(b, indicatorName, value)
            end)
        elseif setting == "auras" then
            -- indicator auras changed, hide them all, then recheck whether to show
            F:IterateAllUnitButtons(function(b)
                b.indicators[indicatorName]:Hide()
                UnitButton_UpdateAuras(b)
            end)
        elseif setting == "bigDebuffs" then
            bigDebuffs = F:ConvertTable(value)
            F:IterateAllUnitButtons(function(b)
                UnitButton_UpdateAuras(b)
            end)
        elseif setting == "blacklist" then
            F:IterateAllUnitButtons(function(b)
                UnitButton_UpdateAuras(b)
            end)
        end
    end
end
Cell:RegisterCallback("UpdateIndicators", "UnitButton_UpdateIndicators", UpdateIndicators)

-------------------------------------------------
-- unit button
-------------------------------------------------
--[[
unitButton = {
    state = {
        class, color, inRange, isAssistant, isLeader, name, role,
        unit, displayedUnit, health, healthMax, healthPercent, powerType
    },
    widget = {
        background, mouseoverHighlight, targetHighlight, readyCheckHighlight,
        healthBar, healthBarBackground, absorbsBar, shieldBar, incomingHeal, damageFlashTex, overShieldGlow,
        powerBar, powerBarBackground,
        statusTextFrame, statusText, timerText
        overlayFrame, nameText, vehicleText,
        aggroBlink, leaderIcon, statusIcon, readyCheckIcon, roleIcon,
    },
    func = {
        ShowFlash, HideFlash,
        ShowTimer, HideTimer, UpdateTimer,
    },
    indicators = {},
    updateRequired,
    __updateElapsed,
}
]]

-------------------------------------------------
-- auras
-------------------------------------------------
local debuffs_cache = {}
local debuffs_cache_count = {}
local debuffs_current = {}
local debuffs_normal = {}
local debuffs_big = {}
local debuffs_dispel = {}
local debuffs_raid_indices = {} -- store matching raid debuffs indices
local debuffs_raid_refreshing = {} -- store matching raid debuffs refreshing status ([index] = refreshing)
local debuffs_raid_orders = {} -- store matching raid debuffs orders ([index] = order)
local debuffs_glowing_current = {}
local debuffs_glowing_cache = {}
local function UnitButton_UpdateDebuffs(self)
    local unit = self.state.displayedUnit
    if not debuffs_cache[unit] then debuffs_cache[unit] = {} end
    if not debuffs_cache_count[unit] then debuffs_cache_count[unit] = {} end
    if not debuffs_current[unit] then debuffs_current[unit] = {} end
    if not debuffs_normal[unit] then debuffs_normal[unit] = {} end
    if not debuffs_big[unit] then debuffs_big[unit] = {} end
    if not debuffs_dispel[unit] then debuffs_dispel[unit] = {} end
    if not debuffs_raid_indices[unit] then debuffs_raid_indices[unit] = {} end
    if not debuffs_raid_refreshing[unit] then debuffs_raid_refreshing[unit] = {} end
    if not debuffs_raid_orders[unit] then debuffs_raid_orders[unit] = {} end
    if not debuffs_glowing_current[unit] then debuffs_glowing_current[unit] = {} end
    if not debuffs_glowing_cache[unit] then debuffs_glowing_cache[unit] = {} end
    self.state.BGOrb = nil

    -- user created indicators
    I:ResetCustomIndicators(unit, "debuff")

    local startIndex, resurrectionFound, raidDebuffsFound = 1
    local glowType, glowOptions
    local refreshing, countIncreased, justApplied

    for i = 1, 40 do
        -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitDebuff(unit, i)
        if not name then
            break
        end
        
        -- if duration and duration ~= 0 and duration <= 600 then
        if duration then
            if CellDB["appearance"]["iconAnimation"] == "duration" then
                -- print(name, expirationTime-duration+.1>=GetTime()) -- NOTE: startTime ≈ now
                justApplied = abs(expirationTime-GetTime()-duration) <= 0.1
                countIncreased = debuffs_cache_count[unit][spellId] and (count > debuffs_cache_count[unit][spellId]) or false
                refreshing = debuffs_cache[unit][spellId] and (justApplied or countIncreased) or false
            elseif CellDB["appearance"]["iconAnimation"] == "stack" then
                refreshing = debuffs_cache_count[unit][spellId] and (count > debuffs_cache_count[unit][spellId]) or false
            else
                refreshing = false
            end

            if enabledIndicators["debuffs"] and duration <= 600 and not Cell.vars.debuffBlacklist[spellId] then
                if not indicatorCustoms["debuffs"] then -- all debuffs
                    if bigDebuffs[spellId] then  -- isBigDebuff
                        debuffs_big[unit][i] = refreshing
                        startIndex = startIndex + 1
                    elseif startIndex <= indicatorNums["debuffs"]+indicatorNums["raidDebuffs"] then -- normal debuffs, may contain topDebuff
                        debuffs_normal[unit][i] = refreshing
                        startIndex = startIndex + 1
                    end

                elseif I:CanDispel(debuffType) then -- only dispellableByMe
                    if bigDebuffs[spellId] then  -- isBigDebuff
                        debuffs_big[unit][i] = refreshing
                        startIndex = startIndex + 1
                    elseif startIndex <= indicatorNums["debuffs"]+indicatorNums["raidDebuffs"] then -- normal debuffs, may contain topDebuff
                        if I:CanDispel(debuffType) then
                            debuffs_normal[unit][i] = refreshing
                            startIndex = startIndex + 1
                        end
                    end
                end
            end
            
            -- user created indicators
            I:CheckCustomIndicators(unit, self, "debuff", spellId, expirationTime - duration, duration, debuffType or "", icon, count, refreshing)

            -- prepare raidDebuffs
            if enabledIndicators["raidDebuffs"] and I:GetDebuffOrder(name, spellId, count) then
                raidDebuffsFound = true
                tinsert(debuffs_raid_indices[unit], i)
                debuffs_raid_refreshing[unit][i] = refreshing -- store all raidDebuffs
                debuffs_raid_orders[unit][i] = I:GetDebuffOrder(name, spellId, count)

                if not indicatorCustoms["raidDebuffs"] then -- glow all matching debuffs
                    glowType, glowOptions = I:GetDebuffGlow(name, spellId, count)
                    if glowType and glowType ~= "None" then
                        debuffs_glowing_current[unit][glowType] = glowOptions
                        debuffs_glowing_cache[unit][glowType] = true
                    end
                end
            end

            debuffs_cache[unit][spellId] = expirationTime
            debuffs_cache_count[unit][spellId] = count
            debuffs_current[unit][spellId] = i

            if enabledIndicators["dispels"] and debuffType and debuffType ~= "" then
                if indicatorCustoms["dispels"] then -- dispellableByMe
                    if I:CanDispel(debuffType) then debuffs_dispel[unit][debuffType] = true end
                else
                    debuffs_dispel[unit][debuffType] = true
                end
            end

            -- resurrectionIcon
            if spellId == 160029 then
                resurrectionFound = true
                self.indicators.resurrectionIcon:SetTimer(expirationTime - duration, duration)
            end

            -- BG orbs
            if spellId == 121164 then
                self.state.BGOrb = "blue"
            end
            if spellId == 121175 then
                self.state.BGOrb = "purple"
            end
            if spellId == 121176 then
                self.state.BGOrb = "green"
            end
            if spellId == 121177 then
                self.state.BGOrb = "orange"
            end
        end
    end
    
    -- update statusIcon
    UnitButton_UpdateStatusIcon(self)

    if not resurrectionFound then
        self.indicators.resurrectionIcon:Hide()
    end

    -- update raid debuffs
    if raidDebuffsFound then
        startIndex = 1
        self.indicators.raidDebuffs:Show()

        -- sort indices
        -- NOTE: debuffs_raid_orders[unit] = { [index] = debuffOrder } used for sorting
        table.sort(debuffs_raid_indices[unit], function(a, b)
            return debuffs_raid_orders[unit][a] < debuffs_raid_orders[unit][b]
        end)
        wipe(debuffs_raid_orders[unit])
        
        -- show
        local topGlowType, topGlowOptions
        for i = 1, indicatorNums["raidDebuffs"] do
            if debuffs_raid_indices[unit][i] then -- debuffs_raid_indices[unit][i] -> index
                local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitDebuff(unit, debuffs_raid_indices[unit][i])
                self.indicators.raidDebuffs[i]:SetCooldown(expirationTime - duration, duration, debuffType or "", icon, count, debuffs_raid_refreshing[unit][debuffs_raid_indices[unit][i]])
                
                startIndex = startIndex + 1
                -- use debuffs_raid_orders(wiped before) to store debuffs indices shown by raidDebuffs indicator
                debuffs_raid_orders[unit][debuffs_raid_indices[unit][i]] = true

                if i == 1 then -- top
                    topGlowType, topGlowOptions = I:GetDebuffGlow(name, spellId, count)
                end
            end
        end

        -- NOTE: debuffs_raid_indices no longer used after set raidDebuffs
        -- for i = startIndex, #debuffs_raid_indices[unit] do
        --     table.remove(debuffs_raid_indices[unit], startIndex)
        -- end

        -- hide other raid debuff indicators
        for i = startIndex, 3 do
            self.indicators.raidDebuffs[i]:Hide()
        end

        -- update glow
        if not indicatorCustoms["raidDebuffs"] then
            if topGlowType and topGlowType ~= "None" then
                -- to make sure top glow has highest priority
                debuffs_glowing_current[unit][topGlowType] = topGlowOptions
            end
            for t, o in pairs(debuffs_glowing_current[unit]) do
                self.indicators.raidDebuffs:ShowGlow(t, o, true)
            end
            for t, _ in pairs(debuffs_glowing_cache[unit]) do
                if not debuffs_glowing_current[unit][t] then
                    self.indicators.raidDebuffs:HideGlow(t)
                    debuffs_glowing_cache[unit][t] = nil
                end
            end
            wipe(debuffs_glowing_current[unit])
        else
            self.indicators.raidDebuffs:ShowGlow(topGlowType, topGlowOptions)
        end
    else
        self.indicators.raidDebuffs:Hide()
    end

    -- update debuffs
    startIndex = 1
    if enabledIndicators["debuffs"] then
        -- bigDebuffs first
        for debuffIndex, refreshing in pairs(debuffs_big[unit]) do
            local _, icon, count, debuffType, duration, expirationTime = UnitDebuff(unit, debuffIndex)
            if not debuffs_raid_orders[unit][debuffIndex] and startIndex <= indicatorNums["debuffs"] then
                -- start, duration, debuffType, texture, count, refreshing
                self.indicators.debuffs[startIndex]:SetCooldown(expirationTime - duration, duration, debuffType or "", icon, count, refreshing, true)
                startIndex = startIndex + 1
            end
        end
        -- then normal debuffs
        for debuffIndex, refreshing in pairs(debuffs_normal[unit]) do
            local _, icon, count, debuffType, duration, expirationTime = UnitDebuff(unit, debuffIndex)
            if not debuffs_raid_orders[unit][debuffIndex] and startIndex <= indicatorNums["debuffs"] then
                -- start, duration, debuffType, texture, count, refreshing
                self.indicators.debuffs[startIndex]:SetCooldown(expirationTime - duration, duration, debuffType or "", icon, count, refreshing)
                startIndex = startIndex + 1
            end
        end
    end

    -- hide other debuff indicators
    for i = startIndex, 10 do
        self.indicators.debuffs[i]:Hide()
    end

    -- update dispels
    self.indicators.dispels:SetDispels(debuffs_dispel[unit])
    
    -- user created indicators
    I:ShowCustomIndicators(unit, self, "debuff")
    
    -- update debuffs_cache
    for spellId, expirationTime in pairs(debuffs_cache[unit]) do
        -- lost or expired
        if not debuffs_current[unit][spellId] or (expirationTime ~= 0 and GetTime() >= expirationTime) then -- expirationTime == 0: no duration 
            debuffs_cache[unit][spellId] = nil
            debuffs_cache_count[unit][spellId] = nil
        end
    end

    wipe(debuffs_current[unit])
    wipe(debuffs_normal[unit])
    wipe(debuffs_big[unit])
    wipe(debuffs_dispel[unit])
    wipe(debuffs_raid_indices[unit])
    wipe(debuffs_raid_refreshing[unit])
    wipe(debuffs_raid_orders[unit])
end

local buffs_cache = {}
local buffs_cache_count = {}
local buffs_cache_castByMe = {}
local buffs_cache_count_castByMe = {}
local buffs_current = {}
local buffs_current_castByMe = {}
local function UnitButton_UpdateBuffs(self)
    local unit = self.state.displayedUnit
    if not buffs_cache[unit] then buffs_cache[unit] = {} end
    if not buffs_cache_count[unit] then buffs_cache_count[unit] = {} end
    if not buffs_current[unit] then buffs_current[unit] = {} end
    self.state.BGFlag = nil

    -- user created indicators
    I:ResetCustomIndicators(unit, "buff")

    local refreshing, countIncreased, justApplied
    local defensiveFound, externalFound, tankActiveMitigationFound, drinkingFound = 1, 1, false, false
    for i = 1, 40 do
        -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitBuff(unit, i)
        if not name then
            break
        end
        
        if duration then
            if CellDB["appearance"]["iconAnimation"] == "duration" then
                justApplied = abs(expirationTime-GetTime()-duration) <= 0.1
                countIncreased = buffs_cache_count[unit][spellId] and (count > buffs_cache_count[unit][spellId]) or false
                refreshing = buffs_cache[unit][spellId] and (justApplied or countIncreased) or false
            elseif CellDB["appearance"]["iconAnimation"] == "stack" then
                refreshing = buffs_cache_count[unit][spellId] and (count > buffs_cache_count[unit][spellId]) or false
            else
                refreshing = false
            end

            -- defensiveCooldowns
            if enabledIndicators["defensiveCooldowns"] and I:IsDefensiveCooldown(name) and defensiveFound <= indicatorNums["defensiveCooldowns"] then
                -- start, duration, debuffType, texture, count, refreshing
                self.indicators.defensiveCooldowns[defensiveFound]:SetCooldown(expirationTime - duration, duration, nil, icon, count, refreshing)
                defensiveFound = defensiveFound + 1
            end

            -- externalCooldowns
            if enabledIndicators["externalCooldowns"] and I:IsExternalCooldown(name, source, unit) and externalFound <= indicatorNums["externalCooldowns"] then
                -- start, duration, debuffType, texture, count, refreshing
                self.indicators.externalCooldowns[externalFound]:SetCooldown(expirationTime - duration, duration, nil, icon, count, refreshing)
                externalFound = externalFound + 1
            end

            -- tankActiveMitigation
            if enabledIndicators["tankActiveMitigation"] and I:IsTankActiveMitigation(name) then
                self.indicators.tankActiveMitigation:SetCooldown(expirationTime - duration, duration)
                tankActiveMitigationFound = true
            end

            -- drinking
            if enabledIndicators["statusText"] and I:IsDrinking(name) then
                if not self.indicators.statusText:GetStatus() then
                    self.indicators.statusText:SetStatus("DRINKING")
                    self.indicators.statusText:Show()
                end
                drinkingFound = true
            end

            -- user created indicators
            I:CheckCustomIndicators(unit, self, "buff", spellId, expirationTime - duration, duration, nil, icon, count, refreshing, false)

            -- check BG flags for statusIcon
            if spellId == 156621 then
                self.state.BGFlag = "alliance"
            end
            if spellId == 156618 then
                self.state.BGFlag = "horde"
            end
            
            buffs_cache[unit][spellId] = expirationTime
            buffs_cache_count[unit][spellId] = count
            buffs_current[unit][spellId] = i
        end
    end

    -- update statusIcon
    UnitButton_UpdateStatusIcon(self)
    
    -- hide other defensiveCooldowns
    for i = defensiveFound, 5 do
        self.indicators.defensiveCooldowns[i]:Hide()
    end
    
    -- hide other externalCooldowns
    for i = externalFound, 5 do
        self.indicators.externalCooldowns[i]:Hide()
    end
    
    -- hide tankActiveMitigation
    if not tankActiveMitigationFound then
        self.indicators.tankActiveMitigation:Hide()
    end
    
    -- hide drinking
    if not drinkingFound and self.indicators.statusText:GetStatus() == "DRINKING" then
        self.indicators.statusText:Hide()
        self.indicators.statusText:SetStatus()
    end
    
    -- update buffs_cache
    for spellId, expirationTime in pairs(buffs_cache[unit]) do
        -- lost or expired
        if not buffs_current[unit][spellId] or (expirationTime ~= 0 and GetTime() >= expirationTime) then
            buffs_cache[unit][spellId] = nil
            buffs_cache_count[unit][spellId] = nil
        end
    end
    wipe(buffs_current[unit])

    -- cast by me ---------------------------------------------------------------------
    if not buffs_cache_castByMe[unit] then buffs_cache_castByMe[unit] = {} end
    if not buffs_cache_count_castByMe[unit] then buffs_cache_count_castByMe[unit] = {} end
    if not buffs_current_castByMe[unit] then buffs_current_castByMe[unit] = {} end
    for i = 1, 40 do
        -- name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, ...
        local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId = UnitBuff(unit, i, "PLAYER")
        if not name then
            break
        end

        if duration then
            if CellDB["appearance"]["iconAnimation"] == "duration" then
                justApplied = abs(expirationTime-GetTime()-duration) <= 0.1
                countIncreased = buffs_cache_count_castByMe[unit][spellId] and (count > buffs_cache_count_castByMe[unit][spellId]) or false
                refreshing = buffs_cache_castByMe[unit][spellId] and (justApplied or countIncreased) or false
            elseif CellDB["appearance"]["iconAnimation"] == "stack" then
                refreshing = buffs_cache_count_castByMe[unit][spellId] and (count > buffs_cache_count_castByMe[unit][spellId]) or false
            else
                refreshing = false
            end
            
            I:CheckCustomIndicators(unit, self, "buff", spellId, expirationTime - duration, duration, nil, icon, count, refreshing, true)
            
            buffs_cache_castByMe[unit][spellId] = expirationTime
            buffs_cache_count_castByMe[unit][spellId] = count
            buffs_current_castByMe[unit][spellId] = i
        end
    end

    -- update buffs_cache
    for spellId, expirationTime in pairs(buffs_cache_castByMe[unit]) do
        -- lost or expired
        if not buffs_current_castByMe[unit][spellId] or (expirationTime ~= 0 and GetTime() >= expirationTime) then
            buffs_cache_castByMe[unit][spellId] = nil
            buffs_cache_count_castByMe[unit][spellId] = nil
        end
    end
    wipe(buffs_current_castByMe[unit])
    -----------------------------------------------------------------------------------

    I:ShowCustomIndicators(unit, self, "buff")
end

-------------------------------------------------
-- functions
-------------------------------------------------
local function UpdateUnitHealthState(self)
    local unit = self.state.displayedUnit

    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)

    self.state.health = health
    self.state.healthMax = healthMax
    self.state.healthPercent = health / healthMax

    self.state.wasDead = self.state.isDead
    self.state.isDead = health == 0
    if self.state.wasDead ~= self.state.isDead then
        UnitButton_UpdateStatusText(self)
    end

    if enabledIndicators["healthText"] and healthMax ~= 0 and health ~= 0 then
        if health == healthMax then
            if not indicatorCustoms["healthText"] then
                self.indicators.healthText:SetHealth(health, healthMax)
                self.indicators.healthText:Show()
            else
                self.indicators.healthText:Hide()
            end
        else
            self.indicators.healthText:SetHealth(health, healthMax)
            self.indicators.healthText:Show()
        end
    else
        self.indicators.healthText:Hide()
    end
end

-------------------------------------------------
-- power filter funcs
-------------------------------------------------
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1")
local function GetRole(b)
    if b.state.role and b.state.role ~= "NONE" then
        return b.state.role
    end

    local info = LGIST:GetCachedInfo(b.state.guid)
    if not info then return end
    return info.spec_role
end

local function ShouldShowPowerBar(b)
    if not b.state.guid then
        return true
    end

    local class, role
    if b.state.inVehicle then
        class = "VEHICLE"
    elseif string.find(b.state.guid, "^Player") then
        class = b.state.class
        role = GetRole(b)
    elseif string.find(b.state.guid, "^Pet") then
        class = "PET"
    elseif string.find(b.state.guid, "^Creature") then
        class = "NPC"
    end
    
    if class then
        if type(Cell.vars.currentLayoutTable["powerFilters"][class]) == "boolean" then
            return Cell.vars.currentLayoutTable["powerFilters"][class]
        else
            if role then
                return Cell.vars.currentLayoutTable["powerFilters"][class][role]
            else
                return true -- show power if role not found
            end
        end
    end

    return true
end

local function ShowPowerBar(b, h)
    b:RegisterEvent("UNIT_POWER_FREQUENT")
    b:RegisterEvent("UNIT_MAXPOWER")
    b:RegisterEvent("UNIT_DISPLAYPOWER")
    b.widget.powerBar:Show()
    b.widget.powerBarLoss:Show()
    b.widget.gapTexture:Show()

    P:ClearPoints(b.widget.healthBar)
    P:Point(b.widget.healthBar, "TOPLEFT", b, "TOPLEFT", 1, -1)
    P:Point(b.widget.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, h + 2)

    if b:IsShown() then
        -- update now
        UnitButton_UpdatePowerMax(b)
        UnitButton_UpdatePower(b)
        UnitButton_UpdatePowerType(b)
    end
end

local function HidePowerBar(b)
    b:UnregisterEvent("UNIT_POWER_FREQUENT")
    b:UnregisterEvent("UNIT_MAXPOWER")
    b:UnregisterEvent("UNIT_DISPLAYPOWER")
    b.widget.powerBar:Hide()
    b.widget.powerBarLoss:Hide()
    b.widget.gapTexture:Hide()

    P:ClearPoints(b.widget.healthBar)
    P:Point(b.widget.healthBar, "TOPLEFT", b, "TOPLEFT", 1, -1)
    P:Point(b.widget.healthBar, "BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
end

-- local roleUpdater = CreateFrame("Frame")
-- function roleUpdater:UnitUpdated(event, guid, unit, info)
--     if Cell.vars.currentLayoutTable and Cell.vars.currentLayoutTable["powerHeight"] ~= 0 then
--         local b = F:GetUnitButtonByGUID(guid)
--         if not b then return end

--         if ShouldShowPowerBar(b) then
--             ShowPowerBar(b, Cell.vars.currentLayoutTable["powerHeight"])
--         else
--             HidePowerBar(b)
--         end
--     end
-- end
-- LGIST.RegisterCallback(roleUpdater, "GroupInSpecT_Update", "UnitUpdated")

-------------------------------------------------
-- unit button functions
-------------------------------------------------
local function UnitButton_UpdateTarget(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    if UnitIsUnit(unit, "target") then
        if highlightEnabled then self.widget.targetHighlight:Show() end
    else
        self.widget.targetHighlight:Hide()
    end
end

UnitButton_UpdateRole = function(self)
    local unit = self.state.unit
    if not unit then return end

    local roleIcon = self.indicators.roleIcon

    if enabledIndicators["roleIcon"] then
        local role = UnitGroupRolesAssigned(unit)
        self.state.role = role

        roleIcon:SetRole(role)
    else
        roleIcon:Hide()
    end
end

UnitButton_UpdateLeader = function(self, event)
    local unit = self.state.unit
    if not unit then return end
    
    local leaderIcon = self.indicators.leaderIcon

    if enabledIndicators["leaderIcon"] then
        if InCombatLockdown() or event == "PLAYER_REGEN_DISABLED" then
            leaderIcon:Hide()
            return
        end

        local isLeader = UnitIsGroupLeader(unit)
        self.state.isLeader = isLeader
        local isAssistant = UnitIsGroupAssistant(unit) and IsInRaid()
        self.state.isAssistant = isAssistant
        
        leaderIcon:SetIcon(isLeader, isAssistant)
    else
        leaderIcon:Hide()
    end
end

local function UnitButton_UpdatePlayerRaidIcon(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    local playerRaidIcon = self.indicators.playerRaidIcon

    local index = GetRaidTargetIndex(unit)

    if enabledIndicators["playerRaidIcon"] then
        if index then
            SetRaidTargetIconTexture(playerRaidIcon.tex, index)
            playerRaidIcon:Show()
        else
            playerRaidIcon:Hide()
        end
    else
        playerRaidIcon:Hide()
    end
end

local function UnitButton_UpdateTargetRaidIcon(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    local targetRaidIcon = self.indicators.targetRaidIcon

    local index = GetRaidTargetIndex(unit.."target")

    if enabledIndicators["targetRaidIcon"] then
        if index then
            SetRaidTargetIconTexture(targetRaidIcon.tex, index)
            targetRaidIcon:Show()
        else
            targetRaidIcon:Hide()
        end
    else
        targetRaidIcon:Hide()
    end
end

local READYCHECK_STATUS = {
    ready = {t = READY_CHECK_READY_TEXTURE, c = {0, 1, 0, 1}},
    waiting = {t = READY_CHECK_WAITING_TEXTURE, c = {1, 1, 0, 1}},
    notready = {t = READY_CHECK_NOT_READY_TEXTURE, c = {1, 0, 0, 1}},
}
local function UnitButton_UpdateReadyCheck(self)
    local unit = self.state.unit
    if not unit then return end
    
    local status = GetReadyCheckStatus(unit)
    self.state.readyCheckStatus = status

    if status then
        -- self.widget.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS[status].c))
        -- self.widget.readyCheckHighlight:Show()
        self.indicators.readyCheckIcon:SetTexture(READYCHECK_STATUS[status].t)
        self.indicators.readyCheckIcon:Show()
    else
        -- self.widget.readyCheckHighlight:Hide()
        self.indicators.readyCheckIcon:Hide()
    end
end

local function UnitButton_FinishReadyCheck(self)
    if self.state.readyCheckStatus == "waiting" then
        -- self.widget.readyCheckHighlight:SetVertexColor(unpack(READYCHECK_STATUS.notready.c))
        self.indicators.readyCheckIcon:SetTexture(READYCHECK_STATUS.notready.t)
    end
    C_Timer.After(6, function()
        -- self.widget.readyCheckHighlight:Hide()
        self.indicators.readyCheckIcon:Hide()
    end)
end

UnitButton_UpdatePowerMax = function(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    local value = UnitPowerMax(unit)
    if value > 0 then
        if barAnimationType == "Smooth" then
            self.widget.powerBar:SetMinMaxSmoothedValue(0, value)
        else
            self.widget.powerBar:SetMinMaxValues(0, value)
        end
        self.widget.powerBar:Show()
        self.widget.powerBarLoss:Show()
    else
        self.widget.powerBar:Hide()
        self.widget.powerBarLoss:Hide()
    end
end

UnitButton_UpdatePower = function(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    if barAnimationType == "Smooth" then
        self.widget.powerBar:SetSmoothedValue(UnitPower(unit))
    else
        self.widget.powerBar:SetValue(UnitPower(unit))
    end
end

UnitButton_UpdatePowerType = function(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    local r, g, b, lossR, lossG, lossB
    local a = Cell.loaded and CellDB["appearance"]["lossAlpha"] or 1

    if not UnitIsConnected(unit) then
        r, g, b = 0.5, 0.5, 0.5
        lossR, lossG, lossB = r*0.2, g*0.2, b*0.2
    else
        r, g, b, lossR, lossG, lossB, self.state.powerType = F:GetPowerColor(unit, self.state.class)
    end

    self.widget.powerBar:SetStatusBarColor(r, g, b)
    self.widget.powerBarLoss:SetVertexColor(lossR, lossG, lossB)
end

local function UnitButton_UpdateHealthMax(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self)

    if barAnimationType == "Smooth" then
        self.widget.healthBar:SetMinMaxSmoothedValue(0, self.state.healthMax)
    else
        self.widget.healthBar:SetMinMaxValues(0, self.state.healthMax)
    end

    if Cell.loaded and (CellDB["appearance"]["barColor"][1] == "Gradient" or CellDB["appearance"]["lossColor"][1] == "Gradient") then
        UnitButton_UpdateColor(self)
    end
end

local function UnitButton_UpdateHealth(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    UpdateUnitHealthState(self)
    local healthPercent = self.state.healthPercent
    
    if barAnimationType == "Flash" then
        self.widget.healthBar:SetValue(self.state.health)
        local diff = healthPercent - (self.state.healthPercentOld or healthPercent)
        if diff >= 0 then
            self.func.HideFlash()
        elseif diff <= -0.05 and diff >= -1 then --! player (just joined) UnitHealthMax(unit) may be 1 ====> diff == -maxHealth
            self.func.ShowFlash(abs(diff), healthPercent)
        end
    elseif barAnimationType == "Smooth" then
        self.widget.healthBar:SetSmoothedValue(self.state.health)
    else
        self.widget.healthBar:SetValue(self.state.health)
    end

    if Cell.loaded and (CellDB["appearance"]["barColor"][1] == "Gradient" or CellDB["appearance"]["lossColor"][1] == "Gradient") then
        UnitButton_UpdateColor(self)
    end

    self.state.healthPercentOld = healthPercent
end

local function UnitButton_UpdateHealPrediction(self)
    if not predictionEnabled then
        self.widget.incomingHeal:Hide()
        return
    end

    local unit = self.state.displayedUnit
    if not unit then return end

    local value = UnitGetIncomingHeals(unit) or 0
    if value == 0 then 
        self.widget.incomingHeal:Hide()
        return
    end

    UpdateUnitHealthState(self)

    local barWidth = self.widget.healthBar:GetWidth()
    local incomingHealWidth = value / self.state.healthMax * barWidth
    local lostHealthWidth = barWidth * (1 - self.state.healthPercent)

    if lostHealthWidth == 0 then
        self.widget.incomingHeal:Hide()
    else
        if lostHealthWidth > incomingHealWidth then
            self.widget.incomingHeal:SetWidth(incomingHealWidth)
        else
            self.widget.incomingHeal:SetWidth(lostHealthWidth)
        end
        self.widget.incomingHeal:Show()
    end
end

local function UnitButton_UpdateShieldAbsorbs(self)
    local unit = self.state.displayedUnit
    if not unit then return end
    
    local value = UnitGetTotalAbsorbs(unit)
    if value > 0 then
        UpdateUnitHealthState(self)
        local barWidth = self.widget.healthBar:GetWidth()
        local shieldPercent = value / self.state.healthMax

        if enabledIndicators["shieldBar"] then
            self.indicators.shieldBar:Show()
            self.indicators.shieldBar:SetValue(shieldPercent)
            self.widget.shieldBar:Hide()
            self.widget.overShieldGlow:Hide()
        else
            self.indicators.shieldBar:Hide()
            if shieldPercent + self.state.healthPercent > 1 then -- overshield
                local p = 1 - self.state.healthPercent
                if p ~= 0 then
                    if shieldEnabled then
                        self.widget.shieldBar:SetWidth(p * barWidth)
                        self.widget.shieldBar:Show()
                    else
                        self.widget.shieldBar:Hide()
                    end
                else
                    self.widget.shieldBar:Hide()
                end
                if overshieldEnabled then
                    self.widget.overShieldGlow:Show()
                else
                    self.widget.overShieldGlow:Hide()
                end
            else
                if shieldEnabled then
                    self.widget.shieldBar:SetWidth(shieldPercent * barWidth)
                    self.widget.shieldBar:Show()
                else
                    self.widget.shieldBar:Hide()
                end
                self.widget.overShieldGlow:Hide()
            end
        end
    else
        self.indicators.shieldBar:Hide()
        self.widget.shieldBar:Hide()
        self.widget.overShieldGlow:Hide()
    end
end

local function UnitButton_UpdateHealAbsorbs(self)
    if not absorbEnabled then
        self.widget.absorbsBar:Hide()
        return
    end

    local unit = self.state.displayedUnit
    if not unit then return end
    
    local value = UnitGetTotalHealAbsorbs(unit)
    if value > 0 then
        UpdateUnitHealthState(self)

        local barWidth = self.widget.healthBar:GetWidth()
        local absorbsPercent = value / self.state.healthMax
        if absorbsPercent > self.state.healthPercent then
            absorbsPercent = self.state.healthPercent
        end
        self.widget.absorbsBar:SetWidth(absorbsPercent * barWidth)
        self.widget.absorbsBar:Show()
    else
        self.widget.absorbsBar:Hide()
    end
end

UnitButton_UpdateAuras = function(self)
    if not indicatorsInitialized then return end

    local unit = self.state.displayedUnit
    if not unit then return end

    UnitButton_UpdateDebuffs(self)
    UnitButton_UpdateBuffs(self)
end

local function UnitButton_UpdateThreat(self)
    local unit = self.state.displayedUnit
    if not unit then return end
    -- if not unit or not UnitExists(unit) then return end

    local status = UnitThreatSituation(unit)
    if status and status >= 2 then
        if enabledIndicators["aggroBlink"] then
            self.indicators.aggroBlink:ShowAggro(GetThreatStatusColor(status))
        end
        if enabledIndicators["aggroBorder"] then
            self.indicators.aggroBorder:ShowAggro(GetThreatStatusColor(status))
        end
    else
        self.indicators.aggroBlink:Hide()
        self.indicators.aggroBorder:Hide()
    end
end

local function UnitButton_UpdateThreatBar(self)
    if not enabledIndicators["aggroBar"] then 
        self.indicators.aggroBar:Hide()
        return
    end

    local unit = self.state.displayedUnit
    if not unit then return end

    -- isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation(unit, mobUnit)
    local _, status, scaledPercentage, rawPercentage = UnitDetailedThreatSituation(unit, "target")
    if status then
        self.indicators.aggroBar:Show()
        self.indicators.aggroBar:SetSmoothedValue(scaledPercentage)
        self.indicators.aggroBar:SetStatusBarColor(GetThreatStatusColor(status))
    else
        self.indicators.aggroBar:Hide()
    end
end

local function UnitButton_UpdateInRange(self)
    local unit = self.state.displayedUnit
    if not unit then return end

    local inRange, checked = UnitInRange(unit)
    if not checked then
        inRange = UnitIsVisible(unit)
    end

    self.state.inRange = inRange
    if Cell.loaded then
        if self.state.inRange ~= self.state.wasInRange then
            if inRange then
                A:FrameFadeIn(self, 0.25, self:GetAlpha(), 1)
            else
                A:FrameFadeOut(self, 0.25, self:GetAlpha(), CellDB["appearance"]["outOfRangeAlpha"])
            end
        end
        self.state.wasInRange = inRange
        -- self:SetAlpha(inRange and 1 or CellDB["appearance"]["outOfRangeAlpha"])
    end
end

local function UnitButton_UpdateVehicleStatus(self)
    local unit = self.state.unit
    if not unit then return end

    if UnitHasVehicleUI(unit) then -- or UnitInVehicle(unit) or UnitUsingVehicle(unit) then
        self.state.inVehicle = true
        if unit == "player" then
            self.state.displayedUnit = "vehicle"
        else
            local prefix, id, suffix = strmatch(unit, "([^%d]+)([%d]*)(.*)")
            self.state.displayedUnit = prefix.."pet"..id..suffix
        end
        self.indicators.nameText:UpdateVehicleName()
    else
        self.state.inVehicle = nil
        self.state.displayedUnit = self.state.unit
        self.indicators.vehicleText:SetText("")
    end
    
    if Cell.loaded and Cell.vars.currentLayoutTable["powerHeight"] ~= 0 then
        if ShouldShowPowerBar(self) then
            ShowPowerBar(self, Cell.vars.currentLayoutTable["powerHeight"])
        else
            HidePowerBar(self)
        end
    end
end

UnitButton_UpdateStatusIcon = function(self)
    local unit = self.state.unit
    if not unit then return end

    local icon = self.indicators.statusIcon
    if UnitHasIncomingResurrection(unit) then
        icon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        icon:Show()
    elseif UnitIsPlayer(unit) and UnitPhaseReason(unit) and not self.state.inVehicle then
        -- https://wow.gamepedia.com/API_UnitPhaseReason
        icon:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:Show()
    elseif self.state.BGFlag then
        icon:SetAtlas("nameplates-icon-flag-"..self.state.BGFlag)
        icon:Show()
    elseif self.state.BGOrb then
        icon:SetAtlas("nameplates-icon-orb-"..self.state.BGOrb)
        icon:Show()
    else
        icon:Hide()
    end
end

UnitButton_UpdateStatusText = function(self)
    local statusText = self.indicators.statusText
    if not enabledIndicators["statusText"] then
        statusText:Hide()
        statusText:SetStatus()
        return
    end

    local unit = self.state.unit
    if not unit then return end

    self.state.guid = UnitGUID(unit) -- update!
    if not self.state.guid then return end

    if not UnitIsConnected(unit) and UnitIsPlayer(unit) then
        statusText:Show()
        statusText:SetStatus("OFFLINE")
        statusText:ShowTimer()
    elseif UnitIsAFK(unit) then
        statusText:Show()
        statusText:SetStatus("AFK")
        statusText:ShowTimer()
    elseif UnitIsFeignDeath(unit) then
        statusText:Show()
        statusText:SetStatus("FEIGN")
        statusText:HideTimer(true)
    elseif UnitIsDeadOrGhost(unit) then
        statusText:Show()
        statusText:HideTimer(true)
        if UnitIsGhost(unit) then
            statusText:SetStatus("GHOST")
        else
            statusText:SetStatus("DEAD")
        end
    elseif C_IncomingSummon.HasIncomingSummon(unit) then
        statusText:Show()
        statusText:HideTimer()
        local status = C_IncomingSummon.IncomingSummonStatus(unit)
        if status == Enum.SummonStatus.Pending then
            statusText:SetStatus("PENDING")
        elseif status == Enum.SummonStatus.Accepted then
            statusText:SetStatus("ACCEPTED")
            C_Timer.After(6, function() UnitButton_UpdateStatusText(self) end)
        elseif status == Enum.SummonStatus.Declined then
            statusText:SetStatus("DECLINED")
            C_Timer.After(6, function() UnitButton_UpdateStatusText(self) end)
        end
    elseif statusText:GetStatus() == "DRINKING" then
        -- update colors
        statusText:Show()
        statusText:SetStatus("DRINKING")
    else
        statusText:Hide()
        statusText:HideTimer(true)
        statusText:SetStatus()
    end
end

local function UnitButton_UpdateName(self)
    local unit = self.state.unit
    if not unit then return end

    self.state.name = UnitName(unit)
    self.state.class = select(2, UnitClass(unit))
    self.state.guid = UnitGUID(unit)

    self.indicators.nameText:UpdateName()
end

UnitButton_UpdateColor = function(self)
    local unit = self.state.unit
    if not unit then return end

    self.state.class = select(2, UnitClass(unit)) --! update class or it may be nil
    local nameText = self.indicators.nameText

    local barR, barG, barB
    local lossR, lossG, lossB
    local barA, lossA = 1, 1
    
    if Cell.loaded then
        if Cell.vars.currentLayoutTable["indicators"][1]["nameColor"][1] == "Class Color" then
            nameText:SetTextColor(F:GetClassColor(self.state.class))
        else
            nameText:SetTextColor(unpack(Cell.vars.currentLayoutTable["indicators"][1]["nameColor"][2]))
        end
        barA =  CellDB["appearance"]["barAlpha"]
        lossA =  CellDB["appearance"]["lossAlpha"]
    else
        nameText:SetTextColor(1, 1, 1)
    end

    if UnitIsPlayer(unit) then -- player
        if not UnitIsConnected(unit) then
            barR, barG, barB = .4, .4, .4
            lossR, lossG, lossB = .4, .4, .4
            nameText:SetTextColor(F:GetClassColor(self.state.class))
        elseif UnitIsCharmed(unit) then
            barR, barG, barB = .5, 0, 1
            lossR, lossG, lossB = barR*.2, barG*.2, barB*.2
            nameText:SetTextColor(F:GetClassColor(self.state.class))
        elseif self.state.inVehicle then
            barR, barG, barB, lossR, lossG, lossB = F:GetHealthColor(self.state.healthPercent, 0, 1, 0.2)
        else
            barR, barG, barB, lossR, lossG, lossB = F:GetHealthColor(self.state.healthPercent, F:GetClassColor(self.state.class))
        end
    elseif string.find(unit, "pet") then -- pet
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthColor(self.state.healthPercent, 0.5, 0.5, 1)
        if Cell.loaded and Cell.vars.currentLayoutTable["indicators"][1]["nameColor"][1] == "Class Color" then
            nameText:SetTextColor(.5, .5, 1)
        end
    else -- npc
        barR, barG, barB, lossR, lossG, lossB = F:GetHealthColor(self.state.healthPercent, 0, 1, 0.2)
    end

    -- local r, g, b = RAID_CLASS_COLORS["DEATHKNIGHT"]:GetRGB()
    self.widget.healthBar:SetStatusBarColor(barR, barG, barB, barA)
    self.widget.healthBarLoss:SetVertexColor(lossR, lossG, lossB, lossA)
    self.widget.incomingHeal:SetVertexColor(barR, barG, barB)
end

local function UnitButton_UpdateAll(self)
    if not self:IsVisible() then return end

    UnitButton_UpdateVehicleStatus(self)
    UnitButton_UpdateName(self)
    UnitButton_UpdateHealthMax(self)
    UnitButton_UpdateHealth(self)
    UnitButton_UpdateHealPrediction(self)
    UnitButton_UpdateStatusText(self)
    UnitButton_UpdateColor(self)
    UnitButton_UpdateTarget(self)
    UnitButton_UpdatePlayerRaidIcon(self)
    UnitButton_UpdateTargetRaidIcon(self)
    UnitButton_UpdateShieldAbsorbs(self)
    UnitButton_UpdateHealAbsorbs(self)
    UnitButton_UpdateInRange(self)
    UnitButton_UpdateRole(self)
    UnitButton_UpdateLeader(self)
    UnitButton_UpdateReadyCheck(self)
    UnitButton_UpdateThreat(self)
    UnitButton_UpdateThreatBar(self)
    UnitButton_UpdateStatusIcon(self)
    UnitButton_UpdateAuras(self)

    if Cell.loaded then
        if Cell.vars.currentLayoutTable["powerHeight"] ~= 0 then
            -- 单位按钮显示、专精、载具发生变化时
            if ShouldShowPowerBar(self) then
                ShowPowerBar(self, Cell.vars.currentLayoutTable["powerHeight"])
            else
                HidePowerBar(self)
            end
        end
    else
        UnitButton_UpdatePowerType(self)
        UnitButton_UpdatePowerMax(self)
        UnitButton_UpdatePower(self)
    end
end

-------------------------------------------------
-- unit button events
-------------------------------------------------
local function UnitButton_RegisterEvents(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    
    self:RegisterEvent("UNIT_HEALTH")
    self:RegisterEvent("UNIT_MAXHEALTH")
    
    self:RegisterEvent("UNIT_POWER_FREQUENT")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("UNIT_DISPLAYPOWER")
    
    self:RegisterEvent("UNIT_AURA")
    
    self:RegisterEvent("UNIT_HEAL_PREDICTION")
    self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    self:RegisterEvent("UNIT_EXITED_VEHICLE")
    
    self:RegisterEvent("INCOMING_SUMMON_CHANGED")
    self:RegisterEvent("UNIT_FLAGS") -- afk
    self:RegisterEvent("UNIT_FACTION") -- mind control
    
    self:RegisterEvent("UNIT_CONNECTION") -- offline
    self:RegisterEvent("PLAYER_FLAGS_CHANGED") -- afk
    self:RegisterEvent("UNIT_NAME_UPDATE") -- unknown target
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA") --? update status text

    -- self:RegisterEvent("PARTY_LEADER_CHANGED") -- GROUP_ROSTER_UPDATE
    -- self:RegisterEvent("PLAYER_ROLES_ASSIGNED") -- GROUP_ROSTER_UPDATE
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    self:RegisterEvent("PLAYER_TARGET_CHANGED")

    if Cell.loaded then
        if enabledIndicators["playerRaidIcon"] then
            self:RegisterEvent("RAID_TARGET_UPDATE")
        end
    else
        self:RegisterEvent("RAID_TARGET_UPDATE")
    end
    if Cell.loaded then
        if enabledIndicators["targetRaidIcon"] then
            self:RegisterEvent("UNIT_TARGET")
        end
    else
        self:RegisterEvent("UNIT_TARGET")
    end
    
    self:RegisterEvent("READY_CHECK")
    self:RegisterEvent("READY_CHECK_FINISHED")
    self:RegisterEvent("READY_CHECK_CONFIRM")
    
    self:RegisterEvent("UNIT_PHASE") -- warmode, traditional sources of phasing such as progress through quest chains
    self:RegisterEvent("PARTY_MEMBER_DISABLE")
    self:RegisterEvent("PARTY_MEMBER_ENABLE")
    self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    
    -- self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED")
    -- self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED")
    
    -- self:RegisterEvent("UNIT_PET")
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE") -- pet summoned far away
    
    -- LibCLHealth.RegisterCallback(self, "COMBAT_LOG_HEALTH", function(event, unit, eventType)
    -- 	-- eventType - either nil when event comes from combat log, or "UNIT_HEALTH" to indicate events that can carry  update to death/ghost states
    -- 	-- print(event, unit, health)
    -- 	UnitButton_UpdateHealth(self)
    -- end)

    UnitButton_UpdateAll(self)
end

local function UnitButton_UnregisterEvents(self)
    self:UnregisterAllEvents()
end

local function UnitButton_OnEvent(self, event, unit)
    if unit and (self.state.displayedUnit == unit or self.state.unit == unit) then
        if  event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_CONNECTION" then
            self.updateRequired = 1
        
        elseif event == "UNIT_NAME_UPDATE" then
            UnitButton_UpdateName(self)
        
        elseif event == "UNIT_MAXHEALTH" then
            UnitButton_UpdateHealthMax(self)
            UnitButton_UpdateHealth(self)
            UnitButton_UpdateHealPrediction(self)
            UnitButton_UpdateShieldAbsorbs(self)
            UnitButton_UpdateHealAbsorbs(self)
            
        elseif event == "UNIT_HEALTH" then
            UnitButton_UpdateHealth(self)
            UnitButton_UpdateHealPrediction(self)
            UnitButton_UpdateShieldAbsorbs(self)
            UnitButton_UpdateHealAbsorbs(self)
            -- UnitButton_UpdateStatusText(self)
    
        elseif event == "UNIT_HEAL_PREDICTION" then
            UnitButton_UpdateHealPrediction(self)
    
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateShieldAbsorbs(self)
    
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            UnitButton_UpdateHealAbsorbs(self)
    
        elseif event == "UNIT_MAXPOWER" then
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)
    
        elseif event == "UNIT_POWER_FREQUENT" then
            UnitButton_UpdatePower(self)
    
        elseif event == "UNIT_DISPLAYPOWER" then
            UnitButton_UpdatePowerMax(self)
            UnitButton_UpdatePower(self)
            UnitButton_UpdatePowerType(self)
    
        elseif event == "UNIT_AURA" then
            UnitButton_UpdateAuras(self)
    
        elseif event == "UNIT_TARGET" then
            UnitButton_UpdateTargetRaidIcon(self)
            
        elseif event == "PLAYER_FLAGS_CHANGED" or event == "UNIT_FLAGS" or event == "INCOMING_SUMMON_CHANGED" then
            UnitButton_UpdateStatusText(self)
            
        elseif event == "UNIT_FACTION" then
            UnitButton_UpdateColor(self) -- mind control
            
        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            UnitButton_UpdateThreat(self)

        elseif event == "INCOMING_RESURRECT_CHANGED" or event == "UNIT_PHASE" or event == "PARTY_MEMBER_DISABLE" or event == "PARTY_MEMBER_ENABLE" then
            UnitButton_UpdateStatusIcon(self)
    
        elseif event == "READY_CHECK_CONFIRM" then
            UnitButton_UpdateReadyCheck(self)

        elseif event == "UNIT_PORTRAIT_UPDATE" then -- pet summoned far away
            if self.state.healthMax == 0 then
                self.updateRequired = 1
            end
        end

    else
        if event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" then
            self.updateRequired = 1

        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
            UnitButton_UpdateLeader(self, event)
    
        elseif event == "PLAYER_TARGET_CHANGED" then
            UnitButton_UpdateTarget(self)
            UnitButton_UpdateThreatBar(self)
        
        elseif event == "UNIT_THREAT_LIST_UPDATE" then
            UnitButton_UpdateThreatBar(self)
    
        elseif event == "RAID_TARGET_UPDATE" then
            UnitButton_UpdatePlayerRaidIcon(self)
            UnitButton_UpdateTargetRaidIcon(self)
    
        elseif event == "READY_CHECK" then
            UnitButton_UpdateReadyCheck(self)
    
        elseif event == "READY_CHECK_FINISHED" then
            UnitButton_FinishReadyCheck(self)
        
        elseif event == "ZONE_CHANGED_NEW_AREA" then
            UnitButton_UpdateStatusText(self)

        -- elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" or event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
        -- 	VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED
        end
    end
end

local function UnitButton_OnAttributeChanged(self, name, value)
    if name == "unit" then
        if not value or value ~= self.state.unit then
            wipe(self.state)
        end

        if type(value) == "string" then
            self.state.unit = value
            self.state.displayedUnit = value
            if string.find(value, "raid") then Cell.unitButtons.raid.units[value] = self end
            -- for omnicd
            if string.match(value, "raid%d") then
                local i = string.match(value, "%d")
                _G["CellRaidFrameMember"..i] = self
                self.unitid = value
            end

            -- reset debuffs
            if debuffs_cache[self.state.unit] then wipe(debuffs_cache[self.state.unit]) end
            if debuffs_cache_count[self.state.unit] then wipe(debuffs_cache_count[self.state.unit]) end
            if debuffs_current[self.state.unit] then wipe(debuffs_current[self.state.unit]) end
            if debuffs_normal[self.state.unit] then wipe(debuffs_normal[self.state.unit]) end
            if debuffs_big[self.state.unit] then wipe(debuffs_big[self.state.unit]) end
            if debuffs_dispel[self.state.unit] then wipe(debuffs_dispel[self.state.unit]) end
            if debuffs_glowing_current[self.state.unit] then wipe(debuffs_glowing_current[self.state.unit]) end
            if debuffs_glowing_cache[self.state.unit] then wipe(debuffs_glowing_cache[self.state.unit]) end
            -- reset buffs
            if buffs_cache[self.state.unit] then wipe(buffs_cache[self.state.unit]) end
            if buffs_cache_castByMe[self.state.unit] then wipe(buffs_cache_castByMe[self.state.unit]) end
            if buffs_cache_count[self.state.unit] then wipe(buffs_cache_count[self.state.unit]) end
            if buffs_cache_count_castByMe[self.state.unit] then wipe(buffs_cache_count_castByMe[self.state.unit]) end
            if buffs_current[self.state.unit] then wipe(buffs_current[self.state.unit]) end
            if buffs_current_castByMe[self.state.unit] then wipe(buffs_current_castByMe[self.state.unit]) end
        end
    end
end

-------------------------------------------------
-- unit button show/hide/enter/leave
-------------------------------------------------
local function UnitButton_OnShow(self)
    -- self.updateRequired = nil -- prevent UnitButton_UpdateAll twice. when convert party <-> raid, GROUP_ROSTER_UPDATE fired.
    UnitButton_RegisterEvents(self)
    -- Cell:Fire("UpdateClampRectInsets")
end

local function UnitButton_OnHide(self)
    UnitButton_UnregisterEvents(self)
    -- Cell:Fire("UpdateClampRectInsets")
    if self.state.unit then
        -- reset debuffs
        if debuffs_cache[self.state.unit] then wipe(debuffs_cache[self.state.unit]) end
        if debuffs_cache_count[self.state.unit] then wipe(debuffs_cache_count[self.state.unit]) end
        if debuffs_current[self.state.unit] then wipe(debuffs_current[self.state.unit]) end
        if debuffs_normal[self.state.unit] then wipe(debuffs_normal[self.state.unit]) end
        if debuffs_big[self.state.unit] then wipe(debuffs_big[self.state.unit]) end
        if debuffs_dispel[self.state.unit] then wipe(debuffs_dispel[self.state.unit]) end
        if debuffs_glowing_current[self.state.unit] then wipe(debuffs_glowing_current[self.state.unit]) end
        if debuffs_glowing_cache[self.state.unit] then wipe(debuffs_glowing_cache[self.state.unit]) end
        -- reset buffs
        if buffs_cache[self.state.unit] then wipe(buffs_cache[self.state.unit]) end
        if buffs_cache_castByMe[self.state.unit] then wipe(buffs_cache_castByMe[self.state.unit]) end
        if buffs_cache_count[self.state.unit] then wipe(buffs_cache_count[self.state.unit]) end
        if buffs_cache_count_castByMe[self.state.unit] then wipe(buffs_cache_count_castByMe[self.state.unit]) end
        if buffs_current[self.state.unit] then wipe(buffs_current[self.state.unit]) end
        if buffs_current_castByMe[self.state.unit] then wipe(buffs_current_castByMe[self.state.unit]) end
    end
    F:RemoveElementsExceptKeys(self.state, "unit", "displayedUnit")
end

local function UnitButton_OnEnter(self)
    if highlightEnabled then self.widget.mouseoverHighlight:Show() end
    
    local unit = self.state.displayedUnit
    if not unit then return end
    
    F:ShowTooltips(self, "unit", unit)
end

local function UnitButton_OnLeave(self)
    self.widget.mouseoverHighlight:Hide()
    GameTooltip:Hide()
end

-- local function UnitButton_OnSizeChanged(self)
-- 	if self.state.name then
-- 		F:UpdateTextWidth(self.widget.nameText, self.state.name)
        
-- 		if self.state.inVehicle then
-- 			F:UpdateTextWidth(self.widget.vehicleText, UnitName(self.state.displayedUnit))
-- 		end
-- 	end
-- end

local function UnitButton_OnTick(self)
    local e = (self.__tickCount or 0) + 1
    if e >= 2 then -- every 0.5 second
        e = 0
        local guid = UnitGUID(self.state.displayedUnit or "")
        if guid ~= self.__displayedGuid then
            -- unit entity changed
            F:RemoveElementsExceptKeys(self.state, "unit", "displayedUnit")
            self.__displayedGuid = guid
            self.updateRequired = 1
        end
    end
    self.__tickCount = e

    UnitButton_UpdateInRange(self)
    
    if self.updateRequired then
        self.updateRequired = nil
        UnitButton_UpdateAll(self)
    end
end

local function UnitButton_OnUpdate(self, elapsed)
    local e = (self.__updateElapsed or 0) + elapsed
    if e > 0.25 then
        UnitButton_OnTick(self)
        e = 0
    end
    self.__updateElapsed = e
end

-------------------------------------------------
-- unit button init
-------------------------------------------------
-- local startTimeCache, statusCache = {}, {}
local startTimeCache = {}

-- Layer(statusTextFrame) -- frameLevel:27 ----------
-- ARTWORK 
--	statusText, timerText
-------------------------------------------------
-- Layer(overlayFrame) -- frameLevel:7 ----------
-- OVERLAY
--	-7 readyCheckIcon, statusIcon
-- ARTWORK 
--	top nameText, statusText, timerText, vehicleText
--	-7 playerRaidIcon, roleIcon, leaderIcon
-------------------------------------------------

-- Layer(healthBar) -- frameLevel:5 -----------------
-- ARTWORK 
--	-5 overShieldGlow
--	-6 incomingHeal, damageFlash, absorbsBar
--	-7 shieldBar
-------------------------------------------------

-- Layer(button) -- frameLevel:3 -----------------
-- OVERLAY 
-- ARTWORK 
--	-6 healthBar, powerBar
--	-7 healthBarBackground, powerBarBackground
-- BORDER
--	0 background(button)
-- BACKGROUND
--	0 readyCheckHighlight
--	-1 mouseoverHighlight
--	-2 targetHighlight
-------------------------------------------------
-- BACKGROUND BORDER ARTWORK OVERLAY HIGHLIGHT

function F:UnitButton_OnLoad(button)
    local name = button:GetName()

    button.widget = {}
    button.state = {}
    button.func = {}
    button.indicators = {}

    -- background
    -- local background = button:CreateTexture(name.."Background", "BORDER")
    -- button.widget.background = background
    -- background:SetAllPoints(button)
    -- background:SetTexture("Interface\\BUTTONS\\WHITE8X8.BLP")
    -- background:SetVertexColor(0, 0, 0, 1)

    -- backdrop
    button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
    button:SetBackdropColor(0, 0, 0, 1)
    button:SetBackdropBorderColor(0, 0, 0, 1)
    
    -- healthbar
    local healthBar = CreateFrame("StatusBar", name.."HealthBar", button)
    button.widget.healthBar = healthBar
    -- healthBar:SetPoint("TOPLEFT", 1, -1)
    -- healthBar:SetPoint("BOTTOMRIGHT", -1, 4)
    P:Point(healthBar, "TOPLEFT", button, "TOPLEFT", 1, -1)
    P:Point(healthBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 4)
    healthBar:SetStatusBarTexture(Cell.vars.texture)
    healthBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)
    healthBar:SetFrameLevel(5)
    
    -- hp loss
    local healthBarLoss = button:CreateTexture(name.."HealthBarLoss", "ARTWORK", nil , -7)
    button.widget.healthBarLoss = healthBarLoss
    -- healthBarLoss:SetPoint("TOPRIGHT", healthBar)
    -- healthBarLoss:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    P:Point(healthBarLoss, "TOPRIGHT", healthBar)
    P:Point(healthBarLoss, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    healthBarLoss:SetTexture(Cell.vars.texture)

    -- powerbar
    local powerBar = CreateFrame("StatusBar", name.."PowerBar", button)
    button.widget.powerBar = powerBar
    -- powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
    -- powerBar:SetPoint("BOTTOMRIGHT", -1, 1)
    P:Point(powerBar, "TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1)
    P:Point(powerBar, "BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
    powerBar:SetStatusBarTexture(Cell.vars.texture)
    powerBar:GetStatusBarTexture():SetDrawLayer("ARTWORK", -6)

    local gapTexture = button:CreateTexture(nil, "BORDER")
    button.widget.gapTexture = gapTexture
    -- gapTexture:SetPoint("BOTTOMLEFT", powerBar, "TOPLEFT")
    -- gapTexture:SetPoint("BOTTOMRIGHT", powerBar, "TOPRIGHT")
    -- gapTexture:SetHeight(1)
    P:Point(gapTexture, "BOTTOMLEFT", powerBar, "TOPLEFT")
    P:Point(gapTexture, "BOTTOMRIGHT", powerBar, "TOPRIGHT")
    P:Height(gapTexture, 1)
    gapTexture:SetColorTexture(0, 0, 0, 1)

    -- power loss
    local powerBarLoss = button:CreateTexture(name.."PowerBarLoss", "ARTWORK", nil , -7)
    button.widget.powerBarLoss = powerBarLoss
    -- powerBarLoss:SetPoint("TOPRIGHT", powerBar)
    -- powerBarLoss:SetPoint("BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    P:Point(powerBarLoss, "TOPRIGHT", powerBar)
    P:Point(powerBarLoss, "BOTTOMLEFT", powerBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    powerBarLoss:SetTexture(Cell.vars.texture)

    button.func.SetPowerHeight = function(height)
        if height == 0 then
            HidePowerBar(button)
        else
            if ShouldShowPowerBar(button) then
                ShowPowerBar(button, height)
            else
                HidePowerBar(button)
                height = 0
            end
        end
    end
    
    -- incoming heal
    local incomingHeal = healthBar:CreateTexture(name.."IncomingHealBar", "ARTWORK", nil, -6)
    button.widget.incomingHeal = incomingHeal
    P:Point(incomingHeal, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    P:Point(incomingHeal, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    incomingHeal:SetTexture(Cell.vars.texture)
    incomingHeal:SetAlpha(.4)
    incomingHeal:Hide()

    -- shield bar
    local shieldBar = healthBar:CreateTexture(name.."ShieldBar", "ARTWORK", nil, -7)
    button.widget.shieldBar = shieldBar
    P:Point(shieldBar, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    P:Point(shieldBar, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    shieldBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
    shieldBar:SetHorizTile(true)
    shieldBar:SetVertTile(true)
    shieldBar:SetVertexColor(1, 1, 1, .4)
    shieldBar:Hide()

    -- over-shield glow
    local overShieldGlow = healthBar:CreateTexture(name.."OverShieldGlow", "ARTWORK", nil, -5)
    button.widget.overShieldGlow = overShieldGlow
    overShieldGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    overShieldGlow:SetBlendMode("ADD")
    P:Point(overShieldGlow, "BOTTOMLEFT", healthBar, "BOTTOMRIGHT", -4, 0)
    P:Point(overShieldGlow, "TOPLEFT", healthBar, "TOPRIGHT", -4, 0)
    overShieldGlow:SetWidth(8)
    overShieldGlow:Hide()

    -- absorbs bar
    local absorbsBar = healthBar:CreateTexture(name.."AbsorbsBar", "ARTWORK", nil, -6)
    button.widget.absorbsBar = absorbsBar
    P:Point(absorbsBar, "TOPRIGHT", healthBar:GetStatusBarTexture())
    P:Point(absorbsBar, "BOTTOMRIGHT", healthBar:GetStatusBarTexture())
    absorbsBar:SetTexture("Interface\\AddOns\\Cell\\Media\\shield.tga", "REPEAT", "REPEAT")
    absorbsBar:SetHorizTile(true)
    absorbsBar:SetVertTile(true)
    absorbsBar:SetVertexColor(.6, .1, .1, .9)
    absorbsBar:SetBlendMode("ADD")
    absorbsBar:Hide()

    button.func.UpdateShields = function()
        predictionEnabled = CellDB["appearance"]["healPrediction"]
        absorbEnabled = CellDB["appearance"]["healAbsorb"]
        shieldEnabled = CellDB["appearance"]["shield"]
        overshieldEnabled = CellDB["appearance"]["overshield"]

        UnitButton_UpdateHealPrediction(button)
        UnitButton_UpdateHealAbsorbs(button)
        UnitButton_UpdateShieldAbsorbs(button)
    end

    -- bar animation
    -- flash
    local damageFlashTex = healthBar:CreateTexture(name.."DamageFlash", "ARTWORK", nil, -6)
    button.widget.damageFlashTex = damageFlashTex
    damageFlashTex:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    damageFlashTex:SetVertexColor(1, 1, 1, 0.7)
    P:Point(damageFlashTex, "TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT")
    P:Point(damageFlashTex, "BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT")
    damageFlashTex:Hide()

    -- damage flash animation group
    local damageFlashAG = damageFlashTex:CreateAnimationGroup()
    local alpha = damageFlashAG:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0.7)
    alpha:SetToAlpha(0)
    alpha:SetDuration(0.2)
    damageFlashAG:SetScript("OnPlay", function(self)
        damageFlashTex:Show()
    end)
    damageFlashAG:SetScript("OnFinished", function(self)
        damageFlashTex:Hide()
    end)

    button.func.ShowFlash = function(lostPercent, currentPercent)
        local barWidth = healthBar:GetWidth()
        damageFlashTex:SetWidth(barWidth * lostPercent)
        -- damageFlashTex:Show()
        damageFlashAG:Play()
    end

    button.func.HideFlash = function()
        damageFlashAG:Finish()
    end

    -- smooth
    Mixin(healthBar, SmoothStatusBarMixin)
    Mixin(powerBar, SmoothStatusBarMixin)

    button.func.UpdateAnimation = function()
        barAnimationType = CellDB["appearance"]["barAnimation"]
        if aType ~= "Flash" then
            damageFlashAG:Finish()
        end
    end

    button.func.SetTexture = function(tex)
        healthBar:SetStatusBarTexture(tex)
        healthBarLoss:SetTexture(tex)
        powerBar:SetStatusBarTexture(tex)
        powerBarLoss:SetTexture(tex)
        incomingHeal:SetTexture(tex)
        damageFlashTex:SetTexture(tex)
    end

    button.func.UpdateColor = function()
        UnitButton_UpdateColor(button)
        UnitButton_UpdatePowerType(button)
        button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
    end

    -- target highlight
    local targetHighlight = CreateFrame("Frame", name.."TargetHighlight", button, "BackdropTemplate")
    button.widget.targetHighlight = targetHighlight
    targetHighlight:EnableMouse(false)
    targetHighlight:SetFrameLevel(6)
    -- targetHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
    -- P:Point(targetHighlight, "TOPLEFT", button, "TOPLEFT", -1, 1)
    -- P:Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    targetHighlight:Hide()
    
    -- mouseover highlight
    local mouseoverHighlight = CreateFrame("Frame", name.."MouseoverHighlight", button, "BackdropTemplate")
    button.widget.mouseoverHighlight = mouseoverHighlight
    mouseoverHighlight:EnableMouse(false)
    mouseoverHighlight:SetFrameLevel(7)
    -- mouseoverHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
    -- P:Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT", -1, 1)
    -- P:Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    mouseoverHighlight:Hide()

    button.func.UpdateHighlightColor = function()
        targetHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["targetColor"]))
        mouseoverHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["mouseoverColor"]))
    end
    
    button.func.UpdateHighlightSize = function()
        local size = CellDB["appearance"]["highlightSize"]
        
        if size ~= 0 then
            highlightEnabled = true
            
            P:ClearPoints(targetHighlight)
            P:ClearPoints(mouseoverHighlight)

            -- update point
            if size < 0 then
                size = abs(size)
                P:Point(targetHighlight, "TOPLEFT", button, "TOPLEFT")
                P:Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT")
                P:Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT")
                P:Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT")
            else
                P:Point(targetHighlight, "TOPLEFT", button, "TOPLEFT", -size, size)
                P:Point(targetHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", size, -size)
                P:Point(mouseoverHighlight, "TOPLEFT", button, "TOPLEFT", -size, size)
                P:Point(mouseoverHighlight, "BOTTOMRIGHT", button, "BOTTOMRIGHT", size, -size)
            end

            -- update thickness
            targetHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(size)})
            mouseoverHighlight:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(size)})

            -- update color
            targetHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["targetColor"]))
            mouseoverHighlight:SetBackdropBorderColor(unpack(CellDB["appearance"]["mouseoverColor"]))

            UnitButton_UpdateTarget(button) -- 0->!0 show highlight again
        else
            highlightEnabled = false
            targetHighlight:Hide()
            mouseoverHighlight:Hide()
        end
    end

    -- readyCheck highlight
    -- local readyCheckHighlight = button:CreateTexture(name.."ReadyCheckHighlight", "BACKGROUND")
    -- button.widget.readyCheckHighlight = readyCheckHighlight
    -- readyCheckHighlight:SetPoint("TOPLEFT", -1, 1)
    -- readyCheckHighlight:SetPoint("BOTTOMRIGHT", 1, -1)
    -- readyCheckHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    -- readyCheckHighlight:Hide()

    --* overlayFrame
    local overlayFrame = CreateFrame("Frame", name.."OverlayFrame", button)
    button.widget.overlayFrame = overlayFrame
    overlayFrame:SetFrameLevel(8) -- button:GetFrameLevel() == 4
    overlayFrame:SetAllPoints(button)

    -- aggro bar
    local aggroBar = Cell:CreateStatusBar(overlayFrame, 18, 2, 100, true)
    button.indicators.aggroBar = aggroBar
    -- aggroBar:SetPoint("BOTTOMLEFT", overlayFrame, "TOPLEFT", 1, 0)
    aggroBar:Hide()

    -- raidIcons
    button.func.UpdatePlayerRaidIcon = function(enabled)
        UnitButton_UpdatePlayerRaidIcon(button)
        if enabled then
            button:RegisterEvent("RAID_TARGET_UPDATE")
        else
            button:UnregisterEvent("RAID_TARGET_UPDATE")
        end
    end
    button.func.UpdateTargetRaidIcon = function(enabled)
        UnitButton_UpdateTargetRaidIcon(button)
        if enabled then
            button:RegisterEvent("UNIT_TARGET")
        else
            button:UnregisterEvent("UNIT_TARGET")
        end
    end

    -- healthText
    button.func.UpdateHealthText = function()
        if button.state.displayedUnit then
            UpdateUnitHealthState(button)
        end
    end

    -- statusText
    button.func.UpdateStatusText = function()
        UnitButton_UpdateStatusText(button)
    end

    -- statusText
    button.func.UpdateShield = function()
        UnitButton_UpdateShieldAbsorbs(button)
    end

    -- indicators
    I:CreateNameText(button)
    I:CreateStatusText(button)
    I:CreateHealthText(button)
    I:CreateStatusIcon(button)
    I:CreateRoleIcon(button)
    I:CreateLeaderIcon(button)
    I:CreateReadyCheckIcon(button)
    I:CreateAggroBlink(button)
    I:CreateAggroBorder(button)
    I:CreatePlayerRaidIcon(button)
    I:CreateTargetRaidIcon(button)
    I:CreateShieldBar(button)
    I:CreateAoEHealing(button)
    I:CreateDefensiveCooldowns(button)
    I:CreateExternalCooldowns(button)
    I:CreateTankActiveMitigation(button)
    I:CreateDebuffs(button)
    I:CreateDispels(button)
    I:CreateRaidDebuffs(button)
    I:CreateTargetedSpells(button)
    I:CreateTargetCounter(button)

    -- events
    button:SetScript("OnAttributeChanged", UnitButton_OnAttributeChanged) -- init
    button:HookScript("OnShow", UnitButton_OnShow)
    button:HookScript("OnHide", UnitButton_OnHide) -- use _onhide for click-castings
    button:HookScript("OnEnter", UnitButton_OnEnter) -- SecureHandlerEnterLeaveTemplate
    button:HookScript("OnLeave", UnitButton_OnLeave) -- SecureHandlerEnterLeaveTemplate
    button:SetScript("OnUpdate", UnitButton_OnUpdate)
    button:SetScript("OnEvent", UnitButton_OnEvent)
    -- button:SetScript("OnSizeChanged", UnitButton_OnSizeChanged)
    button:RegisterForClicks("AnyDown")

    -- pixel perfect
    button.func.UpdatePixelPerfect = function()
        button:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = P:Scale(1)})
        button:SetBackdropColor(0, 0, 0, CellDB["appearance"]["bgAlpha"])
        button:SetBackdropBorderColor(0, 0, 0, 1)
        P:Resize(button)

        P:Repoint(healthBar)
        P:Repoint(healthBarLoss)
        P:Repoint(powerBar)
        P:Repoint(powerBarLoss)
        P:Repoint(gapTexture)
        P:Resize(gapTexture)

        P:Repoint(incomingHeal)
        P:Repoint(shieldBar)
        P:Repoint(overShieldGlow)
        P:Repoint(absorbsBar)
        P:Repoint(damageFlashTex)
        
        button.func.UpdateHighlightSize()

        -- indicators
        for _, i in pairs(button.indicators) do
            if i.UpdatePixelPerfect then
               i:UpdatePixelPerfect() 
            end
        end
    end

    -- FIXME: fix boss 678
    button.func.UpdateHealth = UnitButton_UpdateHealth
    button.func.UpdateHealthMax = UnitButton_UpdateHealthMax
    button.func.UpdateAuras = UnitButton_UpdateAuras
end