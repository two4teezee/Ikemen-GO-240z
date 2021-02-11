local trials = {}

--;===========================================================
--; TRIALS LIST
--;===========================================================
--; Intent: 
--; -In pause menu, use trial.name 
--; -Push trial.lineX.text/glyph to lifebar.go for display
--; --line1. text and line1.glyph are display on the same line
--; -use stateno for on-hit validation
--
--# SAMPLE TRIALS LIST============================================================
--#
--# [Trial 1 Def]
--# trial.steps = 1                   ;int > 0
--# trial.name = Raging Demon         ;string
--#
--# trial.line1.text = Raging Demon         ;string
--# trial.line1.glyph = XX_F_AZ             ;same as movelist glyphs
--# trial.line1.stateno = 
--# trial.line1.anim =
--#
--# [Trial 2 Def]
--# trial.steps = 3                                   ;int > 0
--# trial.name = Standard Issue Shoto Three Piece     ;string
--#
--# trial.line1.text = Jumping Roundhouse             ;string
--# trial.line1.glyph = _UF_C                         ;same as movelist glyphs
--# trial.line1.stateno = 
--# trial.line1.anim =
--#
--# trial.line2.text = Crouching Forward              ;string
--# trial.line2.glyph = _D_+^B                        ;same as movelist glyphs
--# trial.line2.stateno = 
--# trial.line2.anim =
--#
--# trial.line3.text = Fierce Hadoken                 ;string
--# trial.line3.glyph = _QCF+^Z                       ;same as movelist glyphs
--# trial.line3.stateno = 
--# trial.line3.anim =

local function f_trialschecker(t, str, col)
	if ~gameMode("Trials") then
		return false
	end
	
	#set current attack of trial list
	--rootmapset{map:"T_list";value:1}

	#what trial attack am I index
	--var(1):=root,numhelper(70731);

	#special var if exists 
	--var(5):=-1;
	--var(7):=-1;

	#set stateno requirement of attack
	var(2) := currenttrialStateno();

	local throwcheck = false
	local animcheck = false
	
	--ignorehitpause if root,stateno=var(2) && 
	--(root,hitpausetime>1&&root,movehit||enemynear,map(projhit)&&!enemynear,hitshakeover||var(8)>0 &&root,time=1) && 
	--(root,map(SpVer)=var(5) || var(5)=-1) && (root,anim=var(7)||var(7)=-1) && root,map(T_list)=var(1) && !var(4) {

	if stateno() == currenttrialStateno() && 
	(hitpausetime() > 1 && movehit() || projhit() && ~enemynear,hitshakeover() || ~throwcheck && time() == 1) && 
	(anim() == currenttrialAnimno() || ~animcheck) then -- (root,map(SpVer)=var(5) || var(5)=-1) && 
		
		ct = currenttrialStep() + 1
		
		if ct >= currenttrialNumofsteps() then
			currenttrialAdd(currenttrial()+1,1)
		elseif ct < currenttrialNumofsteps() then
			currenttrialAdd(currenttrial(),currenttrialStep()+1)
		end
end

return trials