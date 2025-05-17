```
return {
  "ryugenxd/gen.nvim",
  name = "gen",
  config = function()
    vim.api.nvim_create_user_command("Gen", function(opts)
    require("gen").edit_current_file(table.concat(opts.fargs, " "))
    end, { nargs = "*" })
  end,
}
```
