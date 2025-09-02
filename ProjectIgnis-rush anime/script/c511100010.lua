--Paranormal Advent
--Scripted by BG
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,3,REASON_EFFECT)~=3 then return end
	local g=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if g:GetCount()~=3 then return end
	local mg=g:Filter(s.spfilter,nil,e,tp)
	if mg:GetCount()==0 then return end
	if g:GetClassCount(Card.GetLevel)~=3 then return end
	
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=mg:Select(tp,1,1,nil)
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			local tc=sg:GetFirst()
			local gy=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_SPELLCASTER)
			gy=gy:Filter(Card.IsAttribute,nil,ATTRIBUTE_DARK)
			local lvcount=gy:GetClassCount(Card.GetLevel)
			if lvcount>0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(lvcount*500)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end
