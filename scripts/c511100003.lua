-- Darkness Singularity
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon 1 from hand + 1 with same Level from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.handfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.gyfilter(c,e,tp,lv)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end

		-- 🔶 Check if exists 1 in hand and 1 in GY with same Level
		local hg=Duel.GetMatchingGroup(s.handfilter,tp,LOCATION_HAND,0,nil,e,tp)
		local gy=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_GRAVE,0,nil)
		for hc in aux.Next(hg) do
			local lv=hc:GetLevel()
			if lv>0 and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) then
				return true
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local hgroup=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local hcard=hgroup:GetFirst()
	if not hcard then return end

	local lv=hcard:GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ggroup=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	local gcard=ggroup:GetFirst()
	if not gcard then return end

	-- 🔶 Special Summon both at once
	if Duel.SpecialSummonStep(hcard,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		Duel.SpecialSummonStep(gcard,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SpecialSummonComplete()
end
