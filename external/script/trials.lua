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

local function f_trialslistData(t, str, align, col)
	local t_insert = {}
	str = str .. '<#>'
	for m1, m2 in str:gmatch('(.-)<([^%g <>]+)>') do
		if m1 ~= '' then
			table.insert(t_insert, {glyph = false, text = m1, align = align, col = col})
		end
		if not m2:match('^#[A-Za-z0-9]+$') and not m2:match('^/$') and not m2:match('^#$') then
			table.insert(t_insert, {glyph = true, text = m2, align = align, col = col})
		elseif m2:match('^#[A-Za-z0-9]+$') then
			col = color:fromHex(m2)
		elseif m2:match('^/$') then
			col = {}
		end
	end
	if align == -1 then
		for i = #t_insert, 1, -1 do
			table.insert(t, t_insert[i])
		end
	else
		for i = 1, #t_insert do
			table.insert(t, t_insert[i])
		end
	end
	return t, col
end

function trials.f_trialslistParse()
	trials.t_trialslists = {}
	local t_uniqueRefs = {}
	for player, tbl in ipairs({start.p[1].t_selected, start.p[2].t_selected}) do
		for member, sel in ipairs(tbl) do
			if t_uniqueRefs[sel.ref] == nil then
				t_uniqueRefs[sel.ref] = true
				if sel.trialslistLine == nil then
					sel.trialslistLine = 1
				end
				if start.f_getCharData(sel.ref).trialslist == nil then
					local trialslist = getCharTrialslist(sel.ref)
					if trialslist ~= '' then
						for k, v in main.f_sortKeys(motif.glyphs, function(t, a, b) return string.len(a) > string.len(b) end) do
							trialslist = trialslist:gsub(main.f_escapePattern(k), '<' .. numberToRune(v[1] + 0xe000) .. '>')
						end
						local t = {}
						local col = {}
						for line in trialslist:gmatch('([^\n]*)\n?') do
							line = line:gsub('%s+$', '')
							local subt = {}
							for m in line:gmatch('(	*[^	]+)') do
								local tabs = 0
								m = m:gsub('^(	*)', function(m1)
									tabs = string.len(m1)
									return ''
								end)
								local align = 1 --left align
								if tabs == 1 then
									align = 0 --center align
								elseif tabs > 1 then
									align = -1 --right align
								end
								subt, col = f_trialslistData(subt, m, align, col)
							end
							table.insert(t, subt)
						end
						t[#t] = nil --blank line produced by regexp matching
						start.f_getCharData(sel.ref).trialslist = t
					end
				end
				local pn = player
				if member > 1 then
					pn = pn + (member - 1) * 2
				end
				table.insert(trials.t_trialslists, {
					pn = pn,
					name = start.f_getCharData(sel.ref).name,
					tbl = sel,
					trialslist = start.f_getCharData(sel.ref).trialslist,
				})
			end
		end
	end
	if menu.trialslistChar > #trials.t_trialslists then
		menu.trialslistChar = 1
	end
	if main.debugLog then main.f_printTable(trials.t_trialslists, "debug/t_trialslists.txt") end
end

-- Render
function trials.f_trialslistRender(section, t)
    local cmdList = {}
    -- call trigger here to find out which trial to render
	if t.commandlist ~= nil then
		cmdList = t.commandlist
	else
		table.insert(cmdList, {{glyph = false, text = motif[section].movelist_text_text, align = 1, col = {}}})
	end
	if esc() or main.f_input(main.t_players, {'m'}) then
		sndPlay(motif.files.snd_data, motif[section].cancel_snd[1], motif[section].cancel_snd[2])
		menu.itemname = ''
		return
	elseif main.f_input(main.t_players, {'pal', 's'}) then
		sndPlay(motif.files.snd_data, motif[section].cursor_done_snd[1], motif[section].cursor_done_snd[2])
		menu.itemname = ''
		togglePause(false)
		main.pauseMenu = false
		menu.currentMenu[1] = menu.currentMenu[2]
		return
	elseif main.f_input(main.t_players, {'$B'}) and #menu.t_movelists > 1 then
		sndPlay(motif.files.snd_data, motif[section].cursor_move_snd[1], motif[section].cursor_move_snd[2])
		menu.movelistChar = menu.movelistChar - 1
		if menu.movelistChar < 1 then
			menu.movelistChar = #menu.t_movelists
		end
	elseif main.f_input(main.t_players, {'$F'}) and #menu.t_movelists > 1 then
		sndPlay(motif.files.snd_data, motif[section].cursor_move_snd[1], motif[section].cursor_move_snd[2])
		menu.movelistChar = menu.movelistChar + 1
		if menu.movelistChar > #menu.t_movelists then
			menu.movelistChar = 1
		end
	elseif main.f_input(main.t_players, {'$U'}) and t.tbl.movelistLine > 1 then
		sndPlay(motif.files.snd_data, motif[section].cursor_move_snd[1], motif[section].cursor_move_snd[2])
		t.tbl.movelistLine = t.tbl.movelistLine - 1
	elseif main.f_input(main.t_players, {'$D'}) and t.tbl.movelistLine <= #cmdList - motif[section].movelist_window_visibleitems then
		sndPlay(motif.files.snd_data, motif[section].cursor_move_snd[1], motif[section].cursor_move_snd[2])
		t.tbl.movelistLine = t.tbl.movelistLine + 1
	end
	--draw overlay
	menu[section .. '_movelist_overlay']:draw()
	--draw title
	menu[section .. '_txt_title']:update({text = main.f_itemnameUpper(motif[section].movelist_title_text:gsub('%%s', t.name), motif[section].movelist_title_uppercase == 1)})
	menu[section .. '_txt_title']:draw()
	--draw commands
	local i = 0
	for n = t.tbl.movelistLine, math.min(t.tbl.movelistLine + motif[section].movelist_window_visibleitems + 1, #cmdList) do
		i = i + 1
		local alignOffset = 0
		local lengthOffset = 0
		local align = 1
		local width = 0
		for k, v in ipairs(cmdList[n]) do
			if v.text ~= '' then
				alignOffset = 0
				if v.align == 0 then --center align
					alignOffset = motif[section].movelist_window_width * 0.5
				elseif v.align == -1 then --right align
					alignOffset = motif[section].movelist_window_width
				end
				if v.align ~= align then
					lengthOffset = 0
					align = v.align
				end
				local data = menu[section .. '_txt_text']
				local font_def = main.font_def[motif[section].movelist_text_font[1] .. motif[section].movelist_text_font_height]
				--render glyph
				if v.glyph and motif.glyphs_data[v.text] ~= nil then
					local scaleX = font_def.Size[2] * motif[section].movelist_text_font_scale[2] / motif.glyphs_data[v.text].info.Size[2] * motif[section].movelist_glyphs_scale[1]
					local scaleY = font_def.Size[2] * motif[section].movelist_text_font_scale[2] / motif.glyphs_data[v.text].info.Size[2] * motif[section].movelist_glyphs_scale[2]
					if v.align == -1 then
						alignOffset = alignOffset - motif.glyphs_data[v.text].info.Size[1] * scaleX
					end
					if motif.defaultMenu then main.f_disableLuaScale() end
					animSetScale(motif.glyphs_data[v.text].anim, scaleX, scaleY)
					animSetPos(
						motif.glyphs_data[v.text].anim,
						math.floor(motif[section].movelist_pos[1] + motif[section].movelist_text_offset[1] + motif[section].movelist_glyphs_offset[1] + alignOffset + lengthOffset),
						motif[section].movelist_pos[2] + motif[section].movelist_text_offset[2] + motif[section].movelist_glyphs_offset[2] + main.f_round((font_def.Size[2] + font_def.Spacing[2]) * data.scaleY + motif[section].movelist_text_spacing[2]) * (i - 1)
					)
					animSetWindow(
						motif.glyphs_data[v.text].anim,
						menu[section .. '_t_movelistWindow'][1],
						menu[section .. '_t_movelistWindow'][2],
						menu[section .. '_t_movelistWindow'][3] - menu[section .. '_t_movelistWindow'][1],
						menu[section .. '_t_movelistWindow'][4] - menu[section .. '_t_movelistWindow'][2]
					)
					--animUpdate(motif.glyphs_data[v.text].anim)
					animDraw(motif.glyphs_data[v.text].anim)
					if motif.defaultMenu then main.f_setLuaScale() end
					if k < #cmdList[n] then
						width = motif.glyphs_data[v.text].info.Size[1] * scaleX + motif[section].movelist_glyphs_spacing[1]
					end
				--render text
				else
					data:update({
						text = v.text,
						align = v.align,
						x = math.floor(motif[section].movelist_pos[1] + motif[section].movelist_text_offset[1] + alignOffset + lengthOffset),
						y = motif[section].movelist_pos[2] + motif[section].movelist_text_offset[2] + main.f_round((font_def.Size[2] + font_def.Spacing[2]) * data.scaleY + motif[section].movelist_text_spacing[2]) * (i - 1),
						r = v.col.r or motif[section].movelist_text_font[4],
						g = v.col.g or motif[section].movelist_text_font[5],
						b = v.col.b or motif[section].movelist_text_font[6],
					})
					data:draw()
					if k < #cmdList[n] then
						width = fontGetTextWidth(main.font[data.font .. data.height], v.text) * motif[section].movelist_text_font_scale[1] + motif[section].movelist_text_spacing[1]
					end
				end
				if v.align == 0 then
					lengthOffset = lengthOffset + width / 2
				elseif v.align == -1 then
					lengthOffset = lengthOffset - width
				else
					lengthOffset = lengthOffset + width
				end
			end
		end
	end
	----draw scroll arrows
	--if #cmdList > motif[section].movelist_window_visibleitems then
	--	if t.tbl.movelistLine > 1 then
	--		animUpdate(motif[section].movelist_arrow_up_data)
	--		animDraw(motif[section].movelist_arrow_up_data)
	--	end
	--	if t.tbl.movelistLine <= #cmdList - motif[section].movelist_window_visibleitems then
	--		animUpdate(motif[section].movelist_arrow_down_data)
	--		animDraw(motif[section].movelist_arrow_down_data)
	--	end
	--end
end
return trials