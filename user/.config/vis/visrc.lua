-- load standard vis module, providing parts of the Lua API
require('vis')

local highlight = require('plugins/vis-annotation/init')

highlight.keywords = {
    NOCOMMIT  = 'fore:cyan,underlined,bold,blink',
    FIXME     = 'fore:red,underlined,bold',
    NOTE      = 'fore:green,underlined,bold',
    TODO      = 'fore:magenta,underlined,bold',
    IMPORTANT = 'fore:yellow,underlined,bold',
    BUG       = 'fore:red,bold,reverse'
}


vis.events.subscribe(vis.events.INIT, function()
	-- Your global configuration options
	-- vis:command('set number')
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win) -- luacheck: no unused args
	-- Your per window configuration options e.g.
	vis:map(vis.modes.NORMAL,		'<C-v>',	':set layout v<Enter>')
	vis:map(vis.modes.NORMAL,		'<C-h>',	':set layout h<Enter>')
	vis:map(vis.modes.VISUAL,		'Y',		'"+y')
	vis:map(vis.modes.VISUAL_LINE,	'Y',		'"+y')
	vis:command('set number')
	vis:command('set rnu on')
	vis:command('set ai off')
	vis:command('set theme gruvbox')
	vis:command('set showtabs')
	vis:command('set tabwidth 4')
	-- vis:command('set autoindent')
	-- vis:command('set shownewlines on')
end)
