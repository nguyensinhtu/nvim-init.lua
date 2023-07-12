local opts = {
  log_level = 'error',
  auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/"},
  auto_session_enable_last_session = false,
  auto_save_enabled = true,
  auto_restore_enabled = true,
  auto_session_use_git_branch = nil,
  -- the configs below are lua only
  bypass_session_save_file_types = nil
}

require("auto-session").setup {opts}
