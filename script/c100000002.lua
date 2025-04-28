-- Card Name: The Weather Painter
-- By EXC
local s,id=GetID()

function s.initial_effect(c)
    --Link Summon procedure "The Weather" monsters
	Link.AddProcedure(c,s.matfilter,1,1)
	c:EnableReviveLimit()
	--You can only Special Summon "The Weather Painter" once per turn
	c:SetSPSummonOnce(id)
	--Cannot be Link Material the turn it's Link Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(s.lkcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--GY/Banishment to Hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.regcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	--Set "The Weather Forecast"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.plcost)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)

end
s.listed_series={SET_THE_WEATHER}

-------------------------

function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(SET_THE_WEATHER,lc,sumtype,tp) and not c:IsType(TYPE_LINK,lc,sumtype,tp)
end

-------------------------

function s.lkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsLinkSummoned()
end

-------------------------

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end

function s.thfilter(c)
	return c:IsSetCard(SET_THE_WEATHER) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-------------------------

function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.plfilter(c,alt,tp)
	return not c:IsForbidden() and ((c:IsCode(18720257) and c:IsSSetable()) or (alt and c:IsSetCard(SET_THE_WEATHER) and c:IsSpellTrap() and c:CheckUniqueOnField(tp)))
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()&ZONES_MMZ
	local alt=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,18720257),tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil,alt,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,nil,nil,zone)>0 end
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone()&ZONES_MMZ
	local alt=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,18720257),tp,LOCATION_ONFIELD,0,1,nil)
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE,nil,nil,zone)>0 then
		Duel.MoveSequence(c,math.log(zone,2))
		local sc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil,alt,tp):GetFirst()
		if alt then Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD) else Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET) end
		if Card.IsCode(sc,18720257) then
			Duel.SSet(tp,sc)
		else
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()&ZONES_MMZ
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,nil,nil,zone)>0 end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone()&ZONES_MMZ
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE,nil,nil,zone)>0 then
		Duel.MoveSequence(c,math.log(zone,2))
		if c:IsFaceup() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			local att=c:AnnounceAnotherAttribute(tp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
			e1:SetValue(att)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end