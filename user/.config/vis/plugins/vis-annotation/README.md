#### Adding comment annotation support to vis
![image](https://github.com/user-attachments/assets/47ce9a2f-5c70-4197-b45d-03a9017e3502)


# Installation
Clone the repository to: `"$HOME/.config/vis/plugins/"`

then import it in `visrc.lua` and define your colors:
```
local highlight = require('plugins/vis-annotation/init')

highlight.keywords = {
    NOCOMMIT  = 'fore:cyan,underlined,bold,blink',
    FIXME     = 'fore:red,underlined,bold',
    NOTE      = 'fore:green,underlined,bold',
    TODO      = 'fore:magenta,underlined,bold',
    IMPORTANT = 'fore:yellow,underlined,bold',
    BUG       = 'fore:red,bold,reverse'
}
```

# Note
The number of available custom styles  might cause a problem with the number of styles needed by certain languages, a current workaround is to build vis increasing UI_STYLE_LEXER_MAX value (in `ui.h`).
