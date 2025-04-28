-- Card Name: The Weather Painter Drought
-- By EXC
local s,id=GetID()

function s.initial_effect(c)
    --Xyz Summon: 2+ Level 3 "The Weather" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_THE_WEATHER),3,2,nil,nil,Xyz.InfiniteMats)
    c:EnableReviveLimit()

    -- If this card is Special Summoned
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1)
    e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	c:RegisterEffect(e1)

    -- SP and Destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, cid)
    e2:SetCost(s.cost)
	e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    --Register when removed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(s.spreg)
	c:RegisterEffect(e3)
	    --Special Summon itself
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
s.listed_series={SET_THE_WEATHER}

-------------------------

function s.attachfilter(c,xyzc,tp)
	return c:IsSetCard(SET_THE_WEATHER) and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil,c,tp):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		Duel.Overlay(c,tc)
	end
end

---------------------------

function s.spfilter2(c,e,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter3(c,e,tp,tc)
	return c:IsAttribute(tc:GetAttribute()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(SET_THE_WEATHER) and not c:IsCode(tc:GetCode())
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetOverlayCount()>0 end
	local og=c:GetOverlayGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=og:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.spfilter2(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.dfilter(c,e,tp,tc)
    return c:IsFaceup() and c:IsAttribute(tc:GetAttribute())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,tc)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
            local g2 = Duel.GetMatchingGroup(s.dfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil, e, tp, tc)
            if #g2>0 and Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then -- str4: "Destroy 1 Monster with that attribute?"
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
                local dc = Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,tc)
                Duel.Destroy(dc, REASON_EFFECT)
            end
        end
	end
end

-----------------------------

function s.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(SET_THE_WEATHER) then
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,2)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(id)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end