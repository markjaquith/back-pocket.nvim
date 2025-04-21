local M = {}

local config = {
	items = {},
	title = 'Back Pocket',
}

M.setup = function(opts)
	config = vim.tbl_deep_extend('force', config, opts or {})
end

M.choose = function()
	local Snacks = require 'snacks'
	local file = vim.fn.expand '%:t'
	local path = vim.fn.expand '%:p'
	local relative_path = path:gsub(vim.fn.getcwd(), ''):sub(2)
	local absolute_path = relative_path
	local home = vim.env.HOME
	if path:sub(1, #home) == home then
		absolute_path = '~' .. path:sub(#home + 1)
	end

	local function copy(text, msg)
		msg = msg or text
		vim.fn.setreg('+', text)
		Snacks.notify(msg, { title = 'Clipboard' })
	end

	local function in_git_repo()
		vim.fn.system('git rev-parse --git-dir > /dev/null 2>&1')

		return vim.v.shell_error == 0
	end

	local function get_git_branch()
		if not in_git_repo() then return '' end
		return vim.fn.system('git rev-parse --abbrev-ref HEAD'):gsub('%s+$', '')
	end

	local function get_github_url()
		if not in_git_repo() then return nil end

		local remote_list = vim.fn.systemlist('git config --get remote.origin.url')

		if vim.v.shell_error ~= 0 or #remote_list == 0 then return nil end

		local remote = remote_list[1]

		-- Improved parsing for different git URL formats (SSH, HTTPS)
		local user_repo = remote:match('.*[:/]([^/]+/[^/]+)%.git$') or remote:match('.*[:/]([^/]+/[^/]+)$')

		if not user_repo then return nil end

		local branch = get_git_branch()
		if branch == '' then return 'main' end

		local line = vim.fn.line '.'
		return string.format('https://github.com/%s/blob/%s/%s#L%d', user_repo, branch, relative_path, line)
	end

	local context = {
		copy = copy,
		get_github_url = get_github_url,
		file = file,
		path = path,
		relative_path = relative_path,
		absolute_path = absolute_path,
		get_git_branch = get_git_branch,
		in_git_repo = in_git_repo,
	}

	local items
	if type(config.items) == 'function' then
		items = config.items(context)
	else
		items = config.items
	end

	local items_table = {}
	local max_name_length = 0

	for i, item in ipairs(items) do
		max_name_length = math.max(max_name_length, #item.name)
		table.insert(items_table,
			{ idx = i, score = i, name = item.name, text = item.name .. ' ' .. item.text, display_text = item.text })
	end

	Snacks.picker {
		title = config.title,
		items = items_table,
		format = function(item)
			local spacing = string.rep(' ', max_name_length - #item.name + 2)
			return {
				{ item.name,         'SnacksItemName' },
				{ spacing },
				{ item.display_text, 'Comment' },
			}
		end,
		layout = 'select',
		confirm = function(picker, item)
			picker:close()
			items[item.idx].command()
		end,
	}
end

return M
