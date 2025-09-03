-- 
--Darkness Restrain
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent normal/special summons a monster, change all monster to face-down def position
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

end
--check if opponent summon a monster level 7 or higher, and that card can be set/change position and not a maximum mode
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLevelAbove(7) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function s.filter(c)
	return c:IsRace(RACE_SPELLCASTER)and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
	--change all opponent's monsters to face-down def position
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
