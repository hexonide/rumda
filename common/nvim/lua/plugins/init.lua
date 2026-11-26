return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  -- These are some examples, uncomment them if you want to see them work!
  {
    "IogaMaster/neocord",
    event = "VeryLazy",
    opts = function()
      local cache = {}

      local utils = require "neocord.utils"
      local original_asset_url = utils.get_asset_url
      utils.get_asset_url = function(name)
        if type(name) == "string" and name:match "^https?://" then
          return name
        end
        return original_asset_url(name)
      end

      local base = "https://hexonide.github.io/share/"
      local headphones = base .. "headphones3.png"
      local small = base .. "vimcdark.png"

      local langs = {
        gpg = { "Markdown", "headphones" },
        lua = { "Lua", "headphones" },
        c = { "C", "default" },
        h = { "C Header", "default" },
        cpp = { "C++", "default" },
        hpp = { "C++ Header", "default" },
        py = { "Python", "default" },
        md = { "Markdown", "headphones" },
        js = { "JavaScript", "default" },
        ts = { "TypeScript", "default" },
        rs = { "Rust", "default" },
        go = { "Go", "default" },
        java = { "Java", "default" },
        sh = { "Shell", "default" },
        zsh = { "Zsh", "default" },
        nix = { "Nix", "default" },
        json = { "JSON", "default" },
        toml = { "TOML", "default" },
        yaml = { "YAML", "default" },
        yml = { "YAML", "default" },
        html = { "HTML", "default" },
        css = { "CSS", "default" },
        vim = { "Vim script", "default" },
        txt = { "Text", "default" },
      }

      local function resolve(icon)
        if icon == "headphones" then
          return headphones
        end
        if icon:match "^https?://" then
          return icon
        end
        return base .. icon
      end

      local file_assets = {}
      for ext, entry in pairs(langs) do
        local name, icon = entry[1], entry[2]
        if icon ~= "default" then
          file_assets[ext] = { name, resolve(icon) }
        end
      end

      local function project()
        local dir = vim.fn.expand "%:p:h"
        if dir == "" then
          dir = vim.fn.getcwd()
        end
        if cache[dir] == nil then
          local out = vim.fn.systemlist { "git", "-C", dir, "rev-parse", "--show-toplevel" }
          if vim.v.shell_error == 0 and out[1] then
            cache[dir] = vim.fn.fnamemodify(out[1], ":t")
          else
            cache[dir] = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end
        end
        return "Working on " .. cache[dir]
      end

      local function file_info()
        return "Editing " .. vim.fn.expand "%:t" .. " in " .. vim.fn.expand "%:p:h:t"
      end

      return {
        logo = small,
        logo_tooltip = "Neovim",
        main_image = "language",
        file_assets = file_assets,
        show_time = true,
        global_timer = true,
        debounce_timeout = 10,
        blacklist = { "NvimTree", "dashboard" },
        editing_text = file_info,
        reading_text = file_info,
        terminal_text = file_info,
        line_number_text = "Line %s out of %s",
        workspace_text = project,
      }
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "jamessan/vim-gnupg",
    lazy = false,
    init = function()
      vim.g.GPGPreferSymmetric = 1
    end,
  },
  {
    "ManuLinares/nvim-c3",
    ft = { "c3", "c3i", "c3t" },
    build = function()
      require("c3").update()
    end, -- (Optional) Auto-update binaries
    config = true,
  },
  -- discord presence
  -- {'andweeb/presence.nvim', lazy = false, },
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
  --
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      },
    },
    init = function()
      local shown = false
      vim.api.nvim_create_user_command("ScopeUnderline", function()
        shown = not shown
        require("ibl").update { scope = { show_start = shown, show_end = shown } }
        vim.notify("Scope underline " .. (shown and "on" or "off"))
      end, {})
    end,
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    opts = {
      mappings = false,
      on_attach = function(bufnr)
        local map = vim.keymap.set
        -- map("n", "<Leader>wT", "<Cmd>MDToc<CR>", { buffer = bufnr, desc = "Show table of contents" })
        map("n", "<Leader>wt", function()
          vim.cmd "MDTocAll"
          local items = vim.fn.getloclist(0)
          local title = vim.fn.getloclist(0, { title = 0 }).title
          vim.cmd "lclose"
          vim.fn.setqflist({}, " ", { title = title, items = items })
          vim.cmd "copen"
        end, { buffer = bufnr, desc = "Show full table of contents in quickfix" })
        map("n", "<Leader>wi", "<Cmd>MDInsertToc<CR>", { buffer = bufnr, desc = "Insert table of contents" })
      end,
    },
  },
  {
    "AckslD/nvim-FeMaco.lua",
    main = "femaco",
    cmd = "FeMaco",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      float_opts = function(code_block)
        return {
          relative = "editor",
          width = 100,
          height = math.max(5, #code_block.lines + 2),
          row = 3,
          col = 10,
          style = "minimal",
          border = "single",
        }
      end,
    },
  },
  {
    "m00qek/baleia.nvim",
    lazy = false,
    config = function()
      local baleia = require("baleia").setup {}

      vim.api.nvim_create_user_command("Colorize", function()
        baleia.once(vim.api.nvim_get_current_buf())
      end, {})

      vim.api.nvim_create_autocmd({ "BufReadPost", "StdinReadPost" }, {
        callback = function(args)
          local lines = vim.api.nvim_buf_get_lines(args.buf, 0, 200, false)
          if table.concat(lines, "\n"):find "\27%[" then
            baleia.once(args.buf)
            vim.bo[args.buf].modified = false
          end
        end,
      })
    end,
  },

  -- {
  --   "sphamba/smear-cursor.nvim",
  --   lazy = false,
  --   opts = {
  --     never_draw_over_target = true,
  --
  --     -- Smear cursor when switching buffers or windows.
  --     smear_between_buffers = true,
  --
  --     -- Smear cursor when moving within line or to neighbor lines.
  --     -- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
  --     smear_between_neighbor_lines = true,
  --
  --     -- Draw the smear in buffer space instead of screen space when scrolling
  --     scroll_buffer_space = true,
  --
  --     -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
  --     -- Smears and particles will look a lot less blocky.
  --     legacy_computing_symbols_support = true,
  --
  --     -- Smear cursor in insert mode.
  --     -- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
  --     smear_insert_mode = false,
  --
  --     gradient_exponent = 0,
  --     particles_enabled = false,
  --     particle_spread = 1,
  --     particles_per_second = 100,
  --     particles_per_length = 100,
  --     particle_max_lifetime = 1000,
  --     particle_damping = 0.1,
  --     particle_gravity = 100,
  --   },
  -- },

  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function()
      require("neoscroll").setup {
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = true,
        cursor_scrolls_alone = true,
        easing_function = "sine",
        -- Easing options: nil (default), linear, quadratic, cubic, quartic, quintic, circular, sine
        -- nil - Default (linear-ish)
        -- "linear" - Constant speed (robotic)
        -- "quadratic" - Slow start/end, fast middle (smooth)
        -- "cubic" - More pronounced slow start/end
        -- "quartic" - Even more pronounced
        -- "quintic" - Very smooth
        -- "circular" - Circular motion feel
        -- "sine" - Sine wave motion
      }

      -- Smooth movement mappings
      local t = {}

      -- j/k keys
      -- t['j'] = {'scroll', {0.05, 'true', '150'}}     -- CHANGED: Last number is duration (ms)
      -- t['k'] = {'scroll', {-0.05, 'true', '150'}}
      --
      -- -- Arrow keys (ADDED)
      -- t['<Down>'] = {'scroll', {0.2, 'true', '150'}}
      -- t['<Up>'] = {'scroll', {-0.2, 'true', '150'}}

      -- Optional: Add Ctrl+d/u for page scrolling
      t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "250" } }
      t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "250" } }

      -- Optional: Add zz, zt, zb for centering
      t["zz"] = { "zz", { "150" } }
      t["zt"] = { "zt", { "150" } }
      t["zb"] = { "zb", { "150" } }

      -- require('neoscroll.config').set_mappings(t)
    end,
  },
  {
    "nvim-mini/mini.align",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.align").setup()
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      heading = {
        enabled = true,
        width = "block",
        icons = {},
      },
      code = {
        width = "block",
        -- min_width = 30,
        -- left_margin = 0.5,
        -- left_pad = 0.01,
        right_pad = 0.01,
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require "cmp"
      local luasnip = require "luasnip"

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
        },
      }
    end,
  },

  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "/home/hexogen/Pictures/assets",
        use_absolute_path = true,
        relative_to_current_file = false,
        prompt_for_file_name = false,
        file_name = "%Y%m%d-%H%M%S",
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>" },
    },
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      image = { enabled = true },
    },
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local function start()
        local root = vim.fs.root(0, { "pom.xml", "build.gradle", "build.gradle.kts", "mvnw", "gradlew", ".git" })
          or vim.fn.getcwd()
        local workspace = vim.fn.stdpath "data" .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root, ":t")
        require("jdtls").start_or_attach {
          cmd = { vim.fn.stdpath "data" .. "/mason/bin/jdtls", "-data", workspace },
          root_dir = root,
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          settings = {
            java = {
              format = {
                settings = {
                  url = "/home/hexogen/d-velopment/backups/java-formatter.xml",
                  profile = "MyProfile",
                },
              },
            },
          },
        }
      end
      start()
      vim.api.nvim_create_autocmd("FileType", { pattern = "java", callback = start })
    end,
  },
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require "multicursor-nvim"
      mc.setup()

      local set = vim.keymap.set

      set({ "n", "x" }, "mn", function()
        mc.matchAddCursor(1)
      end, { desc = "Add cursor at next match" })
      set({ "n", "x" }, "mN", function()
        mc.matchAddCursor(-1)
      end, { desc = "Add cursor at previous match" })
      set({ "n", "x" }, "ms", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip next match" })
      set({ "n", "x" }, "mS", function()
        mc.matchSkipCursor(-1)
      end, { desc = "Skip previous match" })
      set({ "n", "x" }, "m<Up>", function()
        mc.lineAddCursor(-1)
      end, { desc = "Add cursor above" })
      set({ "n", "x" }, "m<Down>", function()
        mc.lineAddCursor(1)
      end, { desc = "Add cursor below" })
      set({ "n", "x" }, "m<S-Up>", function()
        mc.lineSkipCursor(-1)
      end, { desc = "Skip line above" })
      set({ "n", "x" }, "m<S-Down>", function()
        mc.lineSkipCursor(1)
      end, { desc = "Skip line below" })
      set("n", "m*", mc.matchAllAddCursors, { desc = "Add cursors at all matches" })
      set("x", "I", mc.insertVisual)
      set("x", "A", mc.appendVisual)
      set({ "n", "x" }, "m<space>", mc.toggleCursor, { desc = "Toggle cursor at position" })

      mc.addKeymapLayer(function(layer)
        layer({ "n", "x" }, "<left>", mc.prevCursor)
        layer({ "n", "x" }, "<right>", mc.nextCursor)
        layer({ "n", "x" }, "mx", mc.deleteCursor)
        layer("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },
}
