PowerMiniStats = CreateFrame("Frame", "PowerMiniStats", UIParent);

if ( not PowerMiniStats:IsUserPlaced() ) then
   PowerMiniStats:SetPoint("CENTER", -100, 0);
end

PowerMiniStats:SetSize(200, 53);
PowerMiniStats:EnableMouse(true);
PowerMiniStats:SetMovable(true);
PowerMiniStats:SetUserPlaced(true);
PowerMiniStats:SetClampedToScreen(true);
PowerMiniStats:RegisterForDrag("LeftButton")

PowerMiniStats:SetScript("OnDragStart", function(self, button)
      if ( IsAltKeyDown() ) then
         PowerMiniStats:StartMoving()
      end
end)

PowerMiniStats:SetScript("OnDragStop", function(self, button)
      PowerMiniStats:StopMovingOrSizing()
end)

for _, text in pairs({"Crit", "Haste", "Mastery", "Power", "MultiStrike"}) do
   local label = "PMStats_"..text.."_Label";
   local value = "PMStats_"..text.."_Text";
   label = PowerMiniStats:CreateFontString(label, "ARTWORK", "GameFontHighlightSmall");
   value = PowerMiniStats:CreateFontString(value, "ARTWORK", "GameFontHighlightLarge");
   label:SetText(text);
   label:SetPoint("BOTTOMLEFT", value, "TOPLEFT", 0, 2);
end

PMStats_Crit_Text:SetFont(STANDARD_TEXT_FONT, 10);
PMStats_Haste_Text:SetFont(STANDARD_TEXT_FONT, 10);
PMStats_Mastery_Text:SetFont(STANDARD_TEXT_FONT, 10);
PMStats_MultiStrike_Text::SetFont(STANDARD_TEXT_FONT, 10);

PMStats_Crit_Text:SetPoint("BOTTOMLEFT", PowerMiniStats, "BOTTOMLEFT");
PMStats_Haste_Text:SetPoint("BOTTOMLEFT", PMStats_Crit_Text, "BOTTOMLEFT", 40, 0);
PMStats_Mastery_Text:SetPoint("BOTTOMLEFT", PMStats_Haste_Text, "BOTTOMLEFT", 40, 0);
PMStats_MultiStrike_Text::SetPoint("BOTTOMLEFT", PMStats_Mastery_Text, "BOTTOMLEFT", 40, 0);
PMStats_Power_Text:SetPoint("BOTTOMLEFT", PMStats_Crit_Text, "TOPLEFT", 0, 15);

local time = 0;
PowerMiniStats:SetScript("OnUpdate", function(self, elapsed)
      if ( time < GetTime() ) then
         time = GetTime()+0.3;
         local _, class = UnitClass("player");
         local spec = GetSpecialization();
         local crit, haste, power, multi;
         if (( class == "WARLOCK" )
            or ( class == "MAGE" )
            or (( class == "PRIEST" ) and ( spec == 3 ))
            or (( class == "DRUID" ) and ( spec == 1))
            or (( class == "SHAMAN" ) and ( spec == 1 ))) then
            PMStats_Power_Label:SetText("Spell Power");
            crit = GetSpellCritChance(2);
            power = GetSpellBonusDamage(2);
            for i = 3, 7 do
               crit = min(crit, GetSpellCritChance(i));
               power = min(power, GetSpellBonusDamage(i));
            end
            haste = UnitSpellHaste("player");
            multi = GetMultistrike();
         elseif ((( class == "PRIEST" ) and ( spec ~= 3 ))
            or (( class == "DRUID" ) and ( spec == 4 ))
            or (( class == "MONK" ) and ( spec == 2 ))
            or (( class == "PALADIN" ) and ( spec == 1 ))
            or (( class == "SHAMAN" ) and ( spec == 3 ))) then
            PMStats_Power_Label:SetText("Healing Power");
            crit = GetSpellCritChance(2);
            for i = 3, 7 do
               crit = min(crit, GetSpellCritChance(i));
            end
            haste = UnitSpellHaste("player");
            power = GetSpellBonusHealing();
            multi = GetMultistrike();
         elseif ( class == "HUNTER" ) then
            PMStats_Power_Label:SetText("Ranged Power");
            crit = GetRangedCritChance();
            haste = GetRangedHaste();
            if ( GetOverrideAPBySpellPower() ~= nil ) then
               power = GetSpellBonusDamage(2);
               for i = 3, 7 do
                  power = min(power, GetSpellBonusDamage(i));
               end
               power = min(power, GetSpellBonusHealing())*GetOverrideAPBySpellPower();
            else
               local base, buff, debuff = UnitRangedAttackPower("player");
               power = max(base+buff+debuff, 0);
            end
         else
            PMStats_Power_Label:SetText("Melee Power");
            crit = GetCritChance();
            haste = GetMeleeHaste();
            multi = GetMultistrike();
            if ( GetOverrideAPBySpellPower() ~= nil ) then
               power = GetSpellBonusDamage(2);
               for i = 3, 7 do
                  power = min(power, GetSpellBonusDamage(i));
               end
               power = min(power, GetSpellBonusHealing())*GetOverrideAPBySpellPower();
            else
               local base, buff, debuff = UnitAttackPower("player");
               power = max(base+buff+debuff, 0);
            end
         end
         PMStats_Crit_Text:SetFormattedText("%.1F%%", crit);
         PMStats_Haste_Text:SetFormattedText("%.1F%%", haste);
         PMStats_MultiStrike_Text:SetFormattedText("%.1F%%", multi);
         if ( UnitLevel("player") < 80 ) then
            PMStats_Mastery_Label:Hide();
            PMStats_Mastery_Text:Hide();
         else
            PMStats_Mastery_Label:Show();
            PMStats_Mastery_Text:Show();
            PMStats_Mastery_Text:SetFormattedText("%.1F%%", GetMasteryEffect());
         end
         PMStats_Power_Text:SetText(AbbreviateLargeNumbers(power));
      end
end);
