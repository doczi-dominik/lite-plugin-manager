-- Imports
local core =    require "core"
local common =  require "core.common"
local command = require "core.command"

local plugin_manager = {}

-- Change default enabled here
plugin_manager.enabled = {
  "autocomplete",
  "autoreload",
  "exec",
  "macro",
  "projectsearch",
  "quote",
  "reflow",
  "tabularize",
  "treeview",
  "trimwhitespace"
}

--------------------------------------------------------------------------

local function _to_table(val)
  if type(val) == "string" then
    return true, { val }
  elseif type(val) == "table" then
    return true, val
  end


  return false
end

function plugin_manager.disable(val)
  local ok
  ok, val = _to_table(val)

  if ok then
    for _, plugin in ipairs(val) do
      table.remove(plugin_manager.enabled, plugin)
    end

    return true
  end

  return false
end

function plugin_manager.enable(val)
  local ok
  ok, val = _to_table(val)

  if ok then
    for _, plugin in ipairs(val) do
      table.insert(plugin_manager.enabled, plugin)
    end


    return true
  end

  return false
end

--------------------------------------------------------------------------

local function _load_plugin(plugin_name)
  local plugin_path = "plugins." .. plugin_name

  local success = core.try(require, plugin_path)

  if not success then
    return false
  end

  core.log_quiet("plugin_manager: Loaded plugin %q", plugin_path)

  return true
end

function plugin_manager.load_plugins()
  local no_errors = true

  for _, plugin_name in ipairs(plugin_manager.enabled) do
    if not _load_plugin(plugin_name) then
      no_errors = false
    end
  end

  return no_errors
end

--------------------------------------------------------------------------

local function _get_all_plugins()
  local plugin_files = system.list_dir(EXEDIR .. "/data/plugins")
  local plugin_names = {}

  for _, filename in ipairs(plugin_files) do
    table.insert(plugin_names, (filename:gsub(".lua$", "")))
  end

  return plugin_names
end

command.add(nil, {
  ["plugin-manager:inject-plugin"] = function()
    local plugin_names = _get_all_plugins()

    core.command_view:enter("Select Plugin", function(_, plugin_name)
      if plugin_name then
        if _load_plugin(plugin_name.text) then
          core.log("Succesfully injected plugin: %q!", plugin_name.text)
        else
          core.log("Failed to inject plugin: %q", plugin_name)
        end
      end
    end,

    function(text)
      return common.fuzzy_match(plugin_names, text)
    end)
  end,

  ["plugin-manager:inject-all-plugins"] = function()
    local no_errors = true
    local plugin_names = _get_all_plugins()

    for _, plugin in ipairs(plugin_names) do
      if not _load_plugin(plugin) then
        core.log_quiet("Failed to inject %q during inject-all-plugins", plugin)
        no_errors = false
      end
    end

    if no_errors then
      core.log("Sucessfully injected all plugins!")
    else
      core.log("There was an error injecting the plugins. Check the log for details.")
    end
  end
})

return plugin_manager
