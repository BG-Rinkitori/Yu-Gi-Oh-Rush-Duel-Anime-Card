--彩光のリフ
--Darkness Magic 549
--scripted by YoshiDuels



local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end

-- Filter for non-DARK Spellcaster monsters (used to make sure ALL monsters in GY are correct)
function s.cfilter(c)
	return c:IsMonster() and (not c:IsAttribute(ATTRIBUTE_DARK) or not c:IsRace(RACE_SPELLCASTER))
end

-- Filter for DARK Spellcaster monsters
function s.spfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER)
end

-- Activation condition
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- Opponent controls a face-up Level 7 or higher monster
	local opp_high_level = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelAbove,7),tp,0,LOCATION_MZONE,1,nil)
	-- Player has only DARK Spellcaster monsters in Graveyard (and at least 1)
	local has_dark_spellcasters = Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil)
	local no_wrong_monsters = not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
	return opp_high_level and has_dark_spellcasters and no_wrong_monsters
end

-- Draw target (basic 1 card draw)
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- Draw operation
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT) > 0 then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)
		local ct=g:GetClassCount(Card.GetCode) -- different names
		if ct>=4 and Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
