local M = {}
-- Using @rnpnr's highlight patch w/ a little tweak
-- to only match annotations within comments
-- (IMPORTANT: this is a fast-dirty tweak, review later)

local lpeg_pattern
local get_keywords = function(win, tokens)
	if not lpeg_pattern then
		local lpeg = vis.lpeg
		local keywords = M.keywords

		-- Build the LPeg pattern for all keywords
		local words
		for tag, _ in pairs(keywords) do
			if words then
				words = words + lpeg.P(tag)
			else
				words = lpeg.P(tag)
			end
		end
		if not words then return end
		local cap = (1 - words)^0 * (lpeg.Cp() * words * lpeg.Cp())
		lpeg_pattern = lpeg.Ct(cap * ((1 - words) * cap)^0)
	end

	local kwt = {}
	for i = 1, #tokens, 2 do
		local token_type = tokens[i]
		local token_end = tokens[i + 1]
		local token_start = (tokens[i - 1] or 1) - 1
		local txt = win.file:content(token_start, token_end)

		-- I only need tokens of type 'comment' to have their annotation highlighted
		if token_type == 'comment' then
			local kws = lpeg_pattern:match(txt)
			if kws then
				local j = 1
				repeat
					local kw_start = kws[j] + token_start
					local kw_end = kws[j + 1] + token_start - 1
					local kw = txt:sub(kws[j], kws[j + 1] - 1)
					table.insert(kwt, {kw_start, kw_end, kw})
					j = j + 2
				until j > #kws
			end
		end
	end

	return kwt
end

local last_data
local last_modified_toks
local wrap_lexer = function(win)
	if not M.keywords then return end
	if not win.syntax or not vis.lexers.load then return end

	local vlexer = vis.lexers.load(win.syntax, nil, true)
	if not vlexer or not vlexer.lex then return end
	local old_lex_func = vlexer.lex

	-- Append new tags to lexer
	for tag, style in pairs(M.keywords) do
		local tid = vlexer._TAGS[tag]
		if not tid then
			-- NOTE: _TAGS needs to be ordered and _TAGS[tag] needs
			-- to equal the numerical table index of tag in _TAGS
			-- why? ask the scintillua authors ¯\_(ツ)_/¯
			table.insert(vlexer._TAGS, tag)
			tid = #vlexer._TAGS
			vlexer._TAGS[tag] = tid
			assert(tid < win.STYLE_LEXER_MAX)
		end
		win:style_define(tid, style)
	end

	vlexer.lex = function(lexer, data, index)
		local tokens = old_lex_func(lexer, data, index)
		local new_tokens = {}

		local kwt
		if last_data ~= data then
			kwt = get_keywords(win, tokens)
			if not kwt then return tokens end
			last_data = data
		else
			return last_modified_toks
		end

		local i = 1
		for _, kwp in ipairs(kwt) do repeat
			if i > #tokens - 1 then break end
			local token_type = tokens[i]
			local token_start = (tokens[i - 1] or 1) - 1
			local token_end = tokens[i + 1]
			local kws = kwp[1]
			local kwe = kwp[2]

			if token_end < kws then
				table.insert(new_tokens, token_type)
				table.insert(new_tokens, token_end)
				i = i + 2
			else
				if token_type == 'comment' then
					-- if kw is within token we need to split
					-- the initial part of token off
					if kws - 1 > token_start then
						table.insert(new_tokens, token_type)
						table.insert(new_tokens, kws)
					end
					table.insert(new_tokens, kwp[3])
					if token_end < kwe then
						table.insert(new_tokens, token_end + 1)
						i = i + 2
					else
						table.insert(new_tokens, kwe + 1)
					end
				else
					table.insert(new_tokens, token_type)
					table.insert(new_tokens, token_end)
					i = i + 2
				end
			end
		until (not token_end or token_end >= kwe) end

		-- copy over remaining tokens
		for j = i, #tokens, 1 do
			table.insert(new_tokens, tokens[j])
		end

		last_modified_toks = new_tokens
		return new_tokens
	end
end

vis.events.subscribe(vis.events.WIN_OPEN, wrap_lexer)

return M

