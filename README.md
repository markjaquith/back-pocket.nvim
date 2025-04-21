# back-pocket.nvim

Back Pocket is a simple Neovim plugin that provides a command palette for commands that you find yourself using sometimes, but not frequently enough to assign or memorize a keybinding for. Or maybe you do use them a lot, but you don't need to run them quickly enough to justify a keybinding.

Human brains can only remember so much, so it makes sense to have "tiers". Short keybindings for things you use all the time (your front pocket), and a place to put infrequently-used or lesser-importance items (your back pocket).

## Requirements

- Neovim 0.11 or later
- snacks.nvim (Used for the command palette)

## Installation

### Lazy.nvim

```lua
{
  "markjaquith/back-pocket.nvim",
  lazy = true,
  keys = {
    {
      '<leader>p', -- Customize your keybinding here
      function()
        require('back-pocket').choose()
      end,
      desc = 'Open Back Pocket command palette',
    },
  },
  config = {
    title = 'Back Pocket',

      -- `items` can be a table, or a function that returns a table
      -- If you provide a function, it will be called with a context table
      -- that has the following:
      --
      --   - get_git_branch()
      --   - in_git_repo()
      --   - get_github_url()
      --   - copy(text)
      --   - file
      --   - path
      --   - relative_path
      --   - absolute_path
    items = function(ctx)
      local items = {
        {
          name = 'Greet',
          description = 'Example command that greets the user',
          command = function () vim.notify('Hello, world!') end,
        }
      }

      local git_items = {
        {
          name = 'Copy Git Branch Name',
          text = ctx.get_git_branch(),
          command = function()
            ctx.copy(ctx.get_git_branch())
          end,
        },
      }

      if ctx.in_git_repo() then
        table.insert(items, {
          name = 'Git Status',
          description = 'Show git status',
          command = function() vim.cmd('Git') end,
        })
      end
    end,
  },
}
```

## License

back-pocket.nvim is licensed under the MIT License. See LICENSE for more information.
