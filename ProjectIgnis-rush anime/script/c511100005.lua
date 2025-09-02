--Sevens Paranormal Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)   
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={160301001}

-- GY requirement: 7+ DARK Spellcaster and/or Magical Knight with different names in GY
function s.gyfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
		and (c:IsRace(RACE_SPELLCASTER) or c:IsRace(RACE_MAGICALKNIGHT))
		and c:IsType(TYPE_MONSTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetClassCount(Card.GetCode) >= 7
end

-- Filter for Sevens Road Magician in hand (cost)
function s.cfilter7RM(c)
	return c:IsCode(160301001) and c:IsAbleToDeckAsCost()
end

-- Extra Deck filter: Fusion that lists the material mc and lists 7RM
function s.spfilter(c,e,tp,mc)
	if Duel.GetLocationCountFromEx(tp,tp,mc,c)<=0 then return false end
	local mustg=aux.GetMustBeMaterialGroup(tp,nil,tp,c,nil,REASON_FUSION)
	return c:IsType(TYPE_FUSION) and c:IsLevelAbove(9)
		and c:ListsCodeAsMaterial(mc:GetCode())
		and c:ListsCodeAsMaterial(160301001)
		and (#mustg==0 or (#mustg==1 and mustg:IsContains(mc)))
end

-- Material filter: candidate monsters in hand that can be used (and have at least one matching Fusion)
function s.matfilter(c,tp)
	if not c:IsMonster() or not c:IsCanBeFusionMaterial() then return false end
	return Duel.IsExistingMatchingCard(function(fc) return s.spfilter(fc,nil,tp,c) end, tp, LOCATION_EXTRA, 0, 1, nil)
end

-- Restriction: selected materials must have different names (codes)
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode) == #sg
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- need at least 1 Sevens Road Magician in hand for cost, and at least 3 distinct valid materials in hand
		local has7rm = Duel.IsExistingMatchingCard(s.cfilter7RM,tp,LOCATION_HAND,0,1,nil)
		local mg = Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND,0,nil,tp)
		return has7rm and mg:GetClassCount(Card.GetCode) >= 3
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- cost: shuffle 1 Sevens Road Magician from hand into Deck
	if not Duel.IsExistingMatchingCard(s.cfilter7RM,tp,LOCATION_HAND,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local costc = Duel.SelectMatchingCard(tp,s.cfilter7RM,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if not costc or Duel.SendtoDeck(costc,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end

	-- select 1–3 different materials from hand (by code)
	local mg_all = Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND,0,nil,tp)
	if mg_all:GetClassCount(Card.GetCode) < 1 then return end
	local sel = aux.SelectUnselectGroup(mg_all,e,tp,1,3,s.rescon,1,tp,HINTMSG_CONFIRM)
	if not sel or #sel==0 then return end
	Duel.ConfirmCards(1-tp,sel)

	-- for each selected material, perform an Eye-of-Timaeus style Fusion Summon
	for mc in aux.Next(sel) do
		if Duel.GetLocationCountFromEx(tp,tp,mc)<=0 then break end
		local fusg = Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,mc)
		if #fusg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local fc = fusg:Select(tp,1,1,nil):GetFirst()
			if fc then
				fc:SetMaterial(Group.FromCards(mc))
				-- send the chosen material to Deck instead of GY
				Duel.SendtoDeck(mc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				fc:CompleteProcedure()
			end
		end
	end
end
