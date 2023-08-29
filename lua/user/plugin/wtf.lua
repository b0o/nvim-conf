-- piersolenski/wtf.nvim
local private = require 'user.private'

require('wtf').setup {
  -- -- Default AI popup type
  -- popup_type = "popup" | "horizontal" | "vertical",
  -- -- An alternative way to set your OpenAI api key
  openai_api_key = private.openai_api_key,
  -- -- ChatGPT Model
  openai_model_id = 'gpt-4',
  -- -- Set your preferred language for the response
  -- language = "english",
  -- -- Any additional instructions
  -- additional_instructions = "Start the reply with 'OH HAI THERE'",
  -- -- Default search engine, can be overridden by passing an option to WtfSeatch
  -- search_engine = "google" | "duck_duck_go" | "stack_overflow" | "github",
  search_engine = 'duck_duck_go',
}
