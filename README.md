# minimal_nvim_config

A minimal, dependency-light Neovim configuration built entirely on native Neovim 0.11+ APIs. No plugin framework, no abstraction layer — just Lua, `vim.pack`, and LSP features that ship with the editor.

---

## Philosophy

Most Neovim configs pull in lazy.nvim, luasnip, nvim-cmp, lualine, and a dozen other plugins to replicate features that newer versions of Neovim already provide natively. This config does not. The goal is:

- Use the editor's own completion, signature help, inlay hints, and codelens
- Keep the plugin list short enough that you can read every line in one sitting
- Make the blink.cmp toggle obvious for anyone who wants a richer completion UI later

---

## Requirements

| Requirement | Minimum version | Notes |
|---|---|---|
| Neovim | 0.11+ | `vim.pack`, `vim.lsp.completion`, `vim.snippet` are all 0.11+ APIs |
| Node.js | 18+ | Required by Mason to download some LSP servers |
| Git | Any recent | `vim.pack` clones plugins via git |
| A Nerd Font | Any patched font | Icons in the completion menu and statusline require one |
| `ripgrep` | Any | Required by Telescope live grep (`<leader>fg`) |

Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com) and set it as your terminal font. JetBrainsMono Nerd Font is what this config was built with, but any works.

---

## Installation

**1. Back up any existing config**

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
```

**2. Clone the repo**

```bash
git clone https://github.com/Hateem-Arshad/minimal_nvim_config ~/.config/nvim
```

**3. Open Neovim**

```bash
nvim
```

On first launch, `vim.pack` will clone all plugins automatically. You will see download activity in the status area. Wait for it to finish — this takes 30–60 seconds depending on your connection.

**4. Install LSP servers**

Once plugins are loaded, run:

```
:MasonToolInstall
```

Then open `:Mason` to verify servers are installed. On a fresh machine, Mason will auto-install everything in `ensure_installed` (basedpyright, clangd, lua_ls, bashls, sqls, stylua, shfmt).

**5. Install Treesitter parsers**

```
:TSUpdate
```

Parsers for all configured languages will download. `auto_install = true` means parsers also install automatically when you first open a file of a new type.

---

## File Structure

```
~/.config/nvim/
├── init.lua                    ← Entry point. Loads all modules in order.
├── lsp/
│   ├── basedpyright.lua        ← Python LSP settings (type checking, inlay hints)
│   └── lua_ls.lua              ← Lua LSP settings (vim global awareness)
├── lua/
│   ├── core/
│   │   ├── lsp.lua             ← Completion engine, signature help, LspAttach behaviour
│   │   ├── activation.lua      ← Mason setup, server list, formatter list
│   │   └── diagnostics.lua     ← Diagnostic display (virtual lines, signs, float)
│   ├── config/
│   │   ├── options.lua         ← vim.opt settings (tabs, search, UI, files)
│   │   ├── keymaps.lua         ← Keybindings and mapleader
│   │   ├── statusline.lua      ← Custom statusline (mode, diagnostics, position)
│   │   └── autocmd.lua         ← Autocommands (format options, etc.)
│   └── plugins/
│       ├── themes.lua          ← Catppuccin theme setup
│       ├── treesitter.lua      ← Treesitter highlight, indent, textobjects
│       ├── telescope.lua       ← Telescope fuzzy finder setup and keymaps
│       └── blink.lua           ← blink.cmp config (inactive — see Switching to blink)
└── nvim-pack-lock.json         ← Plugin version lockfile (managed by vim.pack)
```

---

## Plugin List

| Plugin | Purpose |
|---|---|
| `nvim-lspconfig` | Provides LSP server default configurations |
| `mason.nvim` | Downloads and manages LSP server binaries |
| `mason-lspconfig.nvim` | Bridges Mason installs to Neovim's LSP client |
| `mason-tool-installer.nvim` | Ensures formatters (stylua, shfmt) are installed |
| `catppuccin/nvim` | Theme (Frappé flavour by default) |
| `nvim-treesitter` | Syntax highlighting and indentation |
| `nvim-treesitter-textobjects` | Function/class text objects (`af`, `if`, `ac`, `ic`) |
| `telescope.nvim` | Fuzzy finder for files, grep, buffers, help |
| `plenary.nvim` | Lua utility library required by Telescope |
| `blink.cmp` | *(Installed but inactive)* Alternative completion UI |

---

## LSP Servers

| Server | Language | Notes |
|---|---|---|
| `basedpyright` | Python | Community Pyright fork with stricter type checking |
| `clangd` | C / C++ | Full LSP support including header resolution |
| `lua_ls` | Lua | Configured to recognise the `vim` global |
| `bashls` | Bash / Shell | |
| `sqls` | SQL | Connects to databases via per-project `.nvim.lua` |

### Adding a new LSP server

1. Add the server name to `ensure_installed` in `lua/core/activation.lua`
2. If you need custom settings, create `lsp/<servername>.lua` returning a settings table
3. Run `:MasonInstall <servername>` or restart Neovim to trigger auto-install

### SQL database connection (sqls)

`sqls` requires a per-project config to connect to a database. Create `.nvim.lua` in your project root:

```lua
-- .nvim.lua  (project root)
vim.lsp.config("sqls", {
  cmd = { "sqls", "-config", ".sqls.yml" },
})
```

And `.sqls.yml`:

```yaml
connections:
  - alias: mydb
    driver: sqlite3
    dataSourceName: ./mydb.sqlite3
```

`exrc = true` in `options.lua` allows Neovim to load this file automatically.

---

## Keymaps

### General

| Key | Mode | Action |
|---|---|---|
| `<Space>` | — | Leader key |
| `<leader>e` | Normal | Open file explorer (`:Lex`) |
| `<C-s>` | Normal | Open terminal split (15 lines, bottom) |

### LSP

| Key | Mode | Action |
|---|---|---|
| `<C-Space>` | Insert | Manually trigger completion |
| `<C-n>` / `<C-p>` | Insert | Navigate completion menu |
| `<C-y>` | Insert | Confirm selected completion item |
| `<C-e>` | Insert | Dismiss completion menu |
| `<C-k>` | Insert | Open signature help manually |
| `<leader>f` | Normal | Format buffer (async) |

Completion also triggers automatically on every keystroke in insert mode via `InsertCharPre`. It does not trigger on `(`, `,`, or `)` so it does not compete with signature help.

### Telescope

| Key | Mode | Action |
|---|---|---|
| `<leader>ff` | Normal | Find files |
| `<leader>fg` | Normal | Live grep (requires ripgrep) |
| `<leader>fb` | Normal | Open buffers |
| `<leader>fh` | Normal | Help tags |
| `<leader>fr` | Normal | Recent files |
| `<leader>fd` | Normal | Diagnostics list |

### Treesitter text objects

| Key | Mode | Action |
|---|---|---|
| `af` | Visual / Operator | Around function |
| `if` | Visual / Operator | Inside function |
| `ac` | Visual / Operator | Around class |
| `ic` | Visual / Operator | Inside class |

---

## Completion

Completion is powered by native `vim.lsp.completion` (no plugin). The menu shows:

- A Nerd Font icon for the completion kind (Function, Variable, Snippet, etc.)
- A `[KindName]` label on the right
- A `[LSP]` source tag

`autotrigger = false` is set intentionally — the `InsertCharPre` autocmd in `core/lsp.lua` drives triggering manually, which lets the config skip triggering on signature characters.

`completeopt` is set to `menuone`, `noselect`, `popup`, `fuzzy`:

- `noselect` — nothing is pre-selected; you choose explicitly with `<C-n>`
- `fuzzy` — candidates fuzzy-match what you have typed
- `popup` — documentation appears in a floating window on the right

---

## Diagnostics

Diagnostics appear as virtual lines below each offending line (not inline). The statusline shows live counts per severity. Signs in the gutter use Nerd Font icons.

| Severity | Sign |
|---|---|
| Error | |
| Warning | |
| Info | 󱛉 |
| Hint | |

`update_in_insert = true` means diagnostics refresh while you type, not only on save.

---

## Format on Save

Formatting runs automatically on `BufWritePre` for every buffer with an attached LSP server that supports formatting. clangd, basedpyright, lua_ls, and bashls all support it. `async = false` is used for save-time formatting so the file is always written in its formatted state.

Manual format: `<leader>f` (async, returns immediately).

---

## Inlay Hints

Enabled automatically for servers that declare `inlayHintProvider` support. basedpyright is configured to show:

- Variable types
- Call argument names
- Function return types
- Generic types

clangd also shows inlay hints for parameter names and deduced types.

---

## Statusline

The statusline is custom Lua with no plugin dependency. It shows:

```
 NORMAL | filename [modified]           E: 0 W: 0 H: 0 I: 0 | line:col
```

Mode names are: `NORMAL`, `INSERT`, `VISUAL`, `V-LINE`, `COMMAND`, `REPLACE`, `TERMINAL`.

---

## Switching to blink.cmp

The config is pre-wired for a clean switch. Three sections in `core/lsp.lua` are marked `BLINK REPLACES THIS BLOCK` with toggle instructions.

**To switch:**

1. In `lua/core/activation.lua`, uncomment the blink.cmp line in `vim.pack.add`:
   ```lua
   { src = "https://github.com/saghen/blink.cmp" },
   ```

2. In `lua/core/lsp.lua`, change `---[[` to `--[[` on each of the three marked blocks to disable native completion, the `InsertCharPre` trigger, and `completeopt`.

3. In `init.lua`, uncomment:
   ```lua
   require("plugins.blink")
   ```

4. Restart Neovim. `vim.pack` will install blink.cmp and it will take over completion.

blink.cmp requires a Rust toolchain if it does not have a pre-built binary for your platform. The `blink.lua` config is already written and ready.

---

## Per-project Config

`vim.o.exrc = true` allows Neovim to load a `.nvim.lua` file from the current working directory. Use this for per-project LSP overrides (especially sqls database connections) without polluting your global config.

---

## Options Reference

Key options set in `config/options.lua`:

| Option | Value | Effect |
|---|---|---|
| `shiftwidth` / `tabstop` | 4 | 4-space indentation |
| `expandtab` | true | Spaces instead of tabs |
| `relativenumber` | true | Relative line numbers |
| `scrolloff` | 12 | Keep 12 lines visible above/below cursor |
| `wrap` | false | No line wrapping |
| `undofile` | true | Persistent undo across sessions |
| `clipboard` | unnamedplus | System clipboard integration |
| `updatetime` | 250ms | Faster CursorHold / LSP hover response |
| `winborder` | rounded | Rounded borders on all floating windows |
| `pumblend` | 30 | Slight transparency on the completion popup |
| `ignorecase` + `smartcase` | true | Case-insensitive search unless you type a capital |

---

## Troubleshooting

**Plugins did not install on first launch**

Run `:lua vim.pack.sync()` to retry. Check that git is on your PATH.

**LSP not attaching**

Run `:LspInfo` to see what servers are attached to the current buffer. If none, check `:Mason` to confirm the server for that filetype is installed.

**No icons / boxes appearing instead of icons**

Your terminal font is not a Nerd Font. Install one from [nerdfonts.com](https://www.nerdfonts.com) and set it in your terminal emulator's font settings.

**Telescope live grep not working**

Install ripgrep. On Ubuntu: `sudo apt install ripgrep`. On Arch: `sudo pacman -S ripgrep`.

**SQL completions not appearing**

`sqls` requires a database connection config (see SQL section above). Without it, the server attaches but returns no completions. Also note: Neovim's built-in SQL completion (`vim.g.loaded_sql_completion`) is intentionally disabled in this config because it depends on the third-party `dbext` plugin.

**Format on save is slow**

Switch the `BufWritePre` formatter to `async = true` in `core/lsp.lua` if you find it blocks on large files. Note: async formatting does not guarantee the file is written in its formatted state.
