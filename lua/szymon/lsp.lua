-- Version of 05.09.2022.
-- Add additional capabilities supported by nvim-cmp

local nnoremap = require("szymon.keymap").nnoremap
local inoremap = require("szymon.keymap").inoremap
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')

-- Setup the rust-analyzer separately as it is managed by the rust-nvim plugin.
local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

local on_attach = function(client)
      -- Activate completion
      require'completion'.on_attach(client)

      -- Mappings
      nnoremap('<c-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>')
      nnoremap('K', '<Cmd>lua vim.lsp.buf.hover()<CR>')
      nnoremap('gd', '<Cmd>lua vim.lsp.buf.declaration()<CR>')
      nnoremap('gD', '<cmd>lua vim.lsp.buf.implementation()<CR>')
      nnoremap('gr', '<cmd>lua vim.lsp.buf.references()<CR>')
      nnoremap('<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>')
      nnoremap('<leader>ls', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
      inoremap('<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')

      -- autoformat only for haskell
      if vim.api.nvim_buf_get_option(0, 'filetype') == 'haskell' then
          vim.api.nvim_command[[
              autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]
      end
end

-- Enable language servers with the additional completion features from nvim-cmp
local servers = { 'clangd', 'pyright', 'tsserver', 'hls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
		on_attach = on_attach,
    capabilities = capabilities,
		settings = {
			haskell = {
					hlintOn = true,
					formattingProvider = "fourmolu"
			}
		}
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}