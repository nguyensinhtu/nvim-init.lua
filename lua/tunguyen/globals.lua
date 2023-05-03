function get_setup(name)
  return function()
    require("setup." .. name)
  end
end
