--Paranormal Future Control
--scripted by BG

local s,id=GetID()
function s.initial_effect(c)
	-- Activate on opponent's normal draw in Draw Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end

-- Filter: any monster that can be returned to Deck
function s.tdfilter1(c)
	return c:IsMonster() and c:IsAbleToDeck()
end

-- Filter: DARK Spellcaster/Magical Knight
function s.spfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsRace(RACE_SPELLCASTER|RACE_MAGICALKNIGHT)
end

-- Condition: Opponent's normal draw in Draw Phase
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r==REASON_RULE and Duel.GetTurnPlayer()==1-tp
end

-- Target: Return exactly 3 monsters you control to Deck
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter1,tp,LOCATION_MZONE,0,3,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_MZONE)
end

-- Operation
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- Return 3 monsters you control to Deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.tdfilter1,tp,LOCATION_MZONE,0,3,3,nil)
	if #tg<3 then return end
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

	-- Opponent cannot Special Summon Level 10 or lower monsters face-up this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsLevelBelow(10) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- Check DARK Spellcaster/Magical Knight condition
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil)
	if g:GetClassCount(Card.GetLevel) >= 7 then
		-- Opponent cannot declare attacks with Level 10 or lower monsters this turn
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetTarget(function(e,c) return c:IsLevelBelow(10) end)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)

		-- Opponent cannot activate effects of Level 10 or lower monsters this turn
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(0,1)
		e3:SetValue(function(e,re,tp)
			local rc=re:GetHandler()
			return re:IsActiveType(TYPE_MONSTER) and rc:IsOnField() and rc:IsFaceup() and rc:IsLevelBelow(10)
		end)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
