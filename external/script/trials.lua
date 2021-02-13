launchFight{}
setMatchNo(-1)
trials = {}

--;===========================================================
--; TRIALS SUCCESS CHECKER
--;===========================================================
function trials.trialschecker()
	local throwcheck = false
	local animcheck = false
	if trialinfo('currenttrialanimno') ~= -2147483648 then animcheck = true end

	--uncomment this to debug your trials file or the trials checker
	--print(trialinfo('numoftrials'))
	--print(trialinfo('currenttrial'))
	--print(trialinfo('currenttrialstep'))
	--print(trialinfo('currenttrialname'))
	--print(trialinfo('currenttrialnumofsteps'))
	--print(trialinfo('currenttrialstateno'))
	--print(trialinfo('currenttrialanimno'))

	--Gating Criteria:
	-- you'll want to change this if you're doing something odd with your chars 
	-- 1) stateno matches, AND
	-- 2) optional animcheck passed AND
	-- 		3a) move hit OR
	-- 		3b) throwcheck passed OR
	-- 		3c) projectile hit OR
	-- 		2d) ???
	if (stateno() == trialinfo('currenttrialstateno')) and (anim() == trialinfo('currenttrialanimno') or not(animcheck)) and (hitpausetime() > 1 and movehit()) then -- or (not(throwcheck) and (time() == 1))) then -- or (projhit() and hitshakeover()) or (root,map(SpVer)=var(5) || var(5)=-1) && 
		--continue if currenttrial is less than max trial
		if trialinfo('currenttrial') <= trialinfo('numoftrials') then

			--currenttrialstep initializes at 0
			ncts = trialinfo('currenttrialstep') + 1
			cts = trialinfo('currenttrialnumofsteps')

			--if next current step is 1 (first step so combocount is 0) or if next current step is greater than 1 and combocount is greater than 0... trial attempt is valid!
			if ncts == 1 or (ncts > 1 and combocount() > 0) then
				-- if next current step is equal to number of steps, trial is complete, move to next trial
				if ncts >= cts  then
					currenttrialAdd(trialinfo('currenttrial')+1,0)
				-- otherwise, move to next trial step
				elseif ncts < cts then
					currenttrialAdd(trialinfo('currenttrial'),ncts)
				end
			--if next current step is greater than 1 but combocount is n 0... combo dropped, trial attempt failed!
			elseif (ncts > 1 and combocount() == 0) then
				currenttrialAdd(trialinfo('currenttrial'),0)
			end
		end
	elseif combocount() == 0 then
		--gating criteria failed, trial attempt failed
		currenttrialAdd(trialinfo('currenttrial'),0)
	end
end