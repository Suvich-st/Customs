--苦あれば楽あり
--The Silver Lining
--scripted by EXC
local s,id=GetID()

function s.initial_effect(c)
    -- You can only control 1 "The Silver Lining".
    c:SetUniqueOnField(1,0,id)
    --Activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- Activate once only
    e1:SetCost(s.acost)
	e1:SetOperation(s.aoperation)
	c:RegisterEffect(e1)

    --Grant effect to "The Weather" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.announcecost)
	e2:SetTarget(s.ntg)
	e2:SetOperation(s.nop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)

end
s.listed_series={SET_THE_WEATHER}

------------------------------------------------------------------

function s.scfilter(c)
	return c:IsSetCard(SET_THE_WEATHER) and c:IsAbleToRemoveAsCost(c)
end
function s.sfilter(c,tp)
	return c:IsSetCard(SET_THE_WEATHER) and c:IsAbleToHand() and not c:IsForbidden() and not c:IsCode(id)
end
function s.sspfilter(c,tp)
	return c:IsSetCard(SET_THE_WEATHER) and c:IsAbleToHand() and not c:IsForbidden() and not c:IsCode(id) and c:IsSpellTrap()
end
function s.smfilter(c,tp)
	return c:IsSetCard(SET_THE_WEATHER) and c:IsAbleToHand() and not c:IsForbidden() and not c:IsCode(id) and not c:IsSpellTrap()
end
function s.scheck(sg,e,tp,mg)
	return sg:CheckDifferentProperty(Card.GetType) and sg:FilterCount(Card.IsSpellTrap,nil)==1
end


function s.acost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local sspg=Duel.GetMatchingGroup(s.sspfilter,tp,LOCATION_DECK,0,c)
    local smg=Duel.GetMatchingGroup(s.smfilter,tp,LOCATION_DECK,0,c)
    local cg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c)
	if chk==0 then return true end
    if #sspg>0 and #smg>0 and #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c)
        if #g>0 then
	        Duel.Remove(g,POS_FACEUP,REASON_COST)
            e:SetLabel(1)
        else
            e:SetLabel(0)
        end
    else
        e:SetLabel(0)
    end
end
function s.aoperation(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,c)
    if #sg>=2 and e:GetLabel()==1 then
        local hg=aux.SelectUnselectGroup(sg,e,tp,2,2,s.scheck,1,tp,aux.Stringid(id,2))
        if #hg==2 then
            Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
            Duel.SendtoHand(hg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,hg)
        end
    end
end

----------------------------------------------------

function s.eftg(e,c)
	local g=e:GetHandler():GetColumnGroup(1,1)
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(SET_THE_WEATHER) and c:GetSequence()<5 and g:IsContains(c)
end

----------------------------------------------------
function s.nfilter(c)
	return c:IsFaceup() and not c:IsNonEffectMonster() and not c:IsDisabled()
end

function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_THE_WEATHER)
end

function s.announcecost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,c,tp)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
        and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c)
		and Duel.IsExistingMatchingCard(s.nfilter,tp,0,LOCATION_ONFIELD,1,c) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.nfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.nfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.nfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.nop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsNonEffectMonster() and not tc:IsDisabled() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end