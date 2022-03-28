-- Shatur/neovim-session-manager
require('session_manager').setup {
  autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
  autosave_last_session = false,
}
