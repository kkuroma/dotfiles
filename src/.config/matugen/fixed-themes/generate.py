#!/usr/bin/env python3
"""Generate all fixed theme files for matugen."""
import os, colorsys
from pathlib import Path

BASE = Path.home() / ".config/matugen/fixed-themes"

# --- Color utilities ---

def hex_to_hsl(c):
    c = c.lstrip('#')
    r, g, b = int(c[0:2],16)/255, int(c[2:4],16)/255, int(c[4:6],16)/255
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return h*360, s*100, l*100

def hsl_to_hex(h, s, l):
    r, g, b = colorsys.hls_to_rgb(h/360, l/100, s/100)
    return f"#{int(r*255+.5):02x}{int(g*255+.5):02x}{int(b*255+.5):02x}"

def adj_light(c, l_pct):
    h, s, _ = hex_to_hsl(c)
    return hsl_to_hex(h, s, l_pct)

def brighten(c, amt):
    h, s, l = hex_to_hsl(c)
    return hsl_to_hex(h, s, min(100, max(0, l+amt)))

def strip(c):
    return c.lstrip('#')

def render(template, data):
    result = template
    for key, val in sorted(data.items(), key=lambda x: -len(x[0])):
        result = result.replace(f'%{key}%', str(val))
    return result

# --- M3 color names (alphabetical, matching matugen output) ---

M3_COLORS = sorted([
    "background", "error", "error_container", "inverse_on_surface", "inverse_primary",
    "inverse_surface", "on_background", "on_error", "on_error_container", "on_primary",
    "on_primary_container", "on_primary_fixed", "on_primary_fixed_variant", "on_secondary",
    "on_secondary_container", "on_secondary_fixed", "on_secondary_fixed_variant",
    "on_surface", "on_surface_variant", "on_tertiary", "on_tertiary_container",
    "on_tertiary_fixed", "on_tertiary_fixed_variant", "outline", "outline_variant",
    "primary", "primary_container", "primary_fixed", "primary_fixed_dim", "scrim",
    "secondary", "secondary_container", "secondary_fixed", "secondary_fixed_dim",
    "shadow", "source_color", "surface", "surface_bright", "surface_container",
    "surface_container_high", "surface_container_highest", "surface_container_low",
    "surface_container_lowest", "surface_dim", "surface_tint", "surface_variant",
    "tertiary", "tertiary_container", "tertiary_fixed", "tertiary_fixed_dim",
])

# --- Theme Palettes ---

THEMES = {
    "gruvbox": {
        "background": "#282828", "error": "#cc241d", "error_container": "#fb4934",
        "inverse_on_surface": "#282828", "inverse_primary": "#fabd2f",
        "inverse_surface": "#a89984", "on_background": "#fbf1c7",
        "on_error": "#282828", "on_error_container": "#282828",
        "on_primary": "#282828", "on_primary_container": "#282828",
        "on_primary_fixed": "#282828", "on_primary_fixed_variant": "#3c3836",
        "on_secondary": "#282828", "on_secondary_container": "#282828",
        "on_secondary_fixed": "#282828", "on_secondary_fixed_variant": "#3c3836",
        "on_surface": "#ebdbb2", "on_surface_variant": "#d5c4a1",
        "on_tertiary": "#282828", "on_tertiary_container": "#282828",
        "on_tertiary_fixed": "#282828", "on_tertiary_fixed_variant": "#3c3836",
        "outline": "#928374", "outline_variant": "#665c54",
        "primary": "#d79921", "primary_container": "#fabd2f",
        "primary_fixed": "#fabd2f", "primary_fixed_dim": "#d79921",
        "scrim": "#000000",
        "secondary": "#458588", "secondary_container": "#83a598",
        "secondary_fixed": "#83a598", "secondary_fixed_dim": "#458588",
        "shadow": "#000000", "source_color": "#d79921",
        "surface": "#282828", "surface_bright": "#7c6f64",
        "surface_container": "#3c3836", "surface_container_high": "#504945",
        "surface_container_highest": "#665c54", "surface_container_low": "#32302f",
        "surface_container_lowest": "#1d2021", "surface_dim": "#282828",
        "surface_tint": "#d79921", "surface_variant": "#504945",
        "tertiary": "#689d6a", "tertiary_container": "#8ec07c",
        "tertiary_fixed": "#8ec07c", "tertiary_fixed_dim": "#689d6a",
        # ANSI
        "ansi_red": "#cc241d", "ansi_red_bright": "#fb4934",
        "ansi_green": "#98971a", "ansi_green_bright": "#b8bb26",
        "ansi_yellow": "#d79921", "ansi_yellow_bright": "#fabd2f",
        "ansi_blue": "#458588", "ansi_blue_bright": "#83a598",
        "ansi_magenta": "#b16286", "ansi_magenta_bright": "#d3869b",
        "ansi_cyan": "#689d6a", "ansi_cyan_bright": "#8ec07c",
        "ansi_black": "#504945", "ansi_black_bright": "#665c54",
        "ansi_white": "#a89984", "ansi_white_bright": "#ebdbb2",
        "syntax_orange": "#d65d0e", "syntax_pink": "#d3869b",
    },
    "catppuccin": {
        "background": "#1e1e2e", "error": "#f38ba8", "error_container": "#eba0ac",
        "inverse_on_surface": "#1e1e2e", "inverse_primary": "#b4befe",
        "inverse_surface": "#a6adc8", "on_background": "#cdd6f4",
        "on_error": "#1e1e2e", "on_error_container": "#1e1e2e",
        "on_primary": "#1e1e2e", "on_primary_container": "#1e1e2e",
        "on_primary_fixed": "#1e1e2e", "on_primary_fixed_variant": "#313244",
        "on_secondary": "#1e1e2e", "on_secondary_container": "#1e1e2e",
        "on_secondary_fixed": "#1e1e2e", "on_secondary_fixed_variant": "#313244",
        "on_surface": "#cdd6f4", "on_surface_variant": "#bac2de",
        "on_tertiary": "#1e1e2e", "on_tertiary_container": "#1e1e2e",
        "on_tertiary_fixed": "#1e1e2e", "on_tertiary_fixed_variant": "#313244",
        "outline": "#6c7086", "outline_variant": "#585b70",
        "primary": "#cba6f7", "primary_container": "#f5c2e7",
        "primary_fixed": "#f5c2e7", "primary_fixed_dim": "#cba6f7",
        "scrim": "#000000",
        "secondary": "#89b4fa", "secondary_container": "#74c7ec",
        "secondary_fixed": "#74c7ec", "secondary_fixed_dim": "#89b4fa",
        "shadow": "#000000", "source_color": "#cba6f7",
        "surface": "#1e1e2e", "surface_bright": "#6c7086",
        "surface_container": "#313244", "surface_container_high": "#45475a",
        "surface_container_highest": "#585b70", "surface_container_low": "#1e1e2e",
        "surface_container_lowest": "#11111b", "surface_dim": "#181825",
        "surface_tint": "#cba6f7", "surface_variant": "#585b70",
        "tertiary": "#94e2d5", "tertiary_container": "#a6e3a1",
        "tertiary_fixed": "#a6e3a1", "tertiary_fixed_dim": "#94e2d5",
        # ANSI
        "ansi_red": "#f38ba8", "ansi_red_bright": "#f38ba8",
        "ansi_green": "#a6e3a1", "ansi_green_bright": "#a6e3a1",
        "ansi_yellow": "#f9e2af", "ansi_yellow_bright": "#f9e2af",
        "ansi_blue": "#89b4fa", "ansi_blue_bright": "#89b4fa",
        "ansi_magenta": "#cba6f7", "ansi_magenta_bright": "#cba6f7",
        "ansi_cyan": "#94e2d5", "ansi_cyan_bright": "#94e2d5",
        "ansi_black": "#45475a", "ansi_black_bright": "#585b70",
        "ansi_white": "#a6adc8", "ansi_white_bright": "#cdd6f4",
        "syntax_orange": "#fab387", "syntax_pink": "#f5c2e7",
    },
    "rosepine": {
        "background": "#232136", "error": "#eb6f92", "error_container": "#eb6f92",
        "inverse_on_surface": "#232136", "inverse_primary": "#9ccfd8",
        "inverse_surface": "#908caa", "on_background": "#e0def4",
        "on_error": "#232136", "on_error_container": "#232136",
        "on_primary": "#232136", "on_primary_container": "#232136",
        "on_primary_fixed": "#232136", "on_primary_fixed_variant": "#2a273f",
        "on_secondary": "#e0def4", "on_secondary_container": "#232136",
        "on_secondary_fixed": "#232136", "on_secondary_fixed_variant": "#2a273f",
        "on_surface": "#e0def4", "on_surface_variant": "#908caa",
        "on_tertiary": "#232136", "on_tertiary_container": "#232136",
        "on_tertiary_fixed": "#232136", "on_tertiary_fixed_variant": "#2a273f",
        "outline": "#6e6a86", "outline_variant": "#56526e",
        "primary": "#c4a7e7", "primary_container": "#ea9a97",
        "primary_fixed": "#ea9a97", "primary_fixed_dim": "#c4a7e7",
        "scrim": "#000000",
        "secondary": "#3e8fb0", "secondary_container": "#9ccfd8",
        "secondary_fixed": "#9ccfd8", "secondary_fixed_dim": "#3e8fb0",
        "shadow": "#000000", "source_color": "#c4a7e7",
        "surface": "#232136", "surface_bright": "#6e6a86",
        "surface_container": "#2a283e", "surface_container_high": "#44415a",
        "surface_container_highest": "#56526e", "surface_container_low": "#2a273f",
        "surface_container_lowest": "#191724", "surface_dim": "#232136",
        "surface_tint": "#c4a7e7", "surface_variant": "#56526e",
        "tertiary": "#f6c177", "tertiary_container": "#ea9a97",
        "tertiary_fixed": "#ea9a97", "tertiary_fixed_dim": "#f6c177",
        # ANSI
        "ansi_red": "#eb6f92", "ansi_red_bright": "#eb6f92",
        "ansi_green": "#9ccfd8", "ansi_green_bright": "#9ccfd8",
        "ansi_yellow": "#f6c177", "ansi_yellow_bright": "#f6c177",
        "ansi_blue": "#3e8fb0", "ansi_blue_bright": "#3e8fb0",
        "ansi_magenta": "#c4a7e7", "ansi_magenta_bright": "#c4a7e7",
        "ansi_cyan": "#9ccfd8", "ansi_cyan_bright": "#9ccfd8",
        "ansi_black": "#44415a", "ansi_black_bright": "#56526e",
        "ansi_white": "#908caa", "ansi_white_bright": "#e0def4",
        "syntax_orange": "#ea9a97", "syntax_pink": "#eb6f92",
    },
    "kanagawa": {
        "background": "#181616", "error": "#c4746e", "error_container": "#e46876",
        "inverse_on_surface": "#181616", "inverse_primary": "#7fb4ca",
        "inverse_surface": "#9e9b93", "on_background": "#c5c9c5",
        "on_error": "#181616", "on_error_container": "#181616",
        "on_primary": "#181616", "on_primary_container": "#181616",
        "on_primary_fixed": "#181616", "on_primary_fixed_variant": "#282727",
        "on_secondary": "#181616", "on_secondary_container": "#181616",
        "on_secondary_fixed": "#181616", "on_secondary_fixed_variant": "#282727",
        "on_surface": "#c5c9c5", "on_surface_variant": "#a6a69c",
        "on_tertiary": "#181616", "on_tertiary_container": "#181616",
        "on_tertiary_fixed": "#181616", "on_tertiary_fixed_variant": "#282727",
        "outline": "#7a8382", "outline_variant": "#625e5a",
        "primary": "#957fb8", "primary_container": "#8992a7",
        "primary_fixed": "#8992a7", "primary_fixed_dim": "#957fb8",
        "scrim": "#000000",
        "secondary": "#8ba4b0", "secondary_container": "#7fb4ca",
        "secondary_fixed": "#7fb4ca", "secondary_fixed_dim": "#8ba4b0",
        "shadow": "#000000", "source_color": "#957fb8",
        "surface": "#181616", "surface_bright": "#625e5a",
        "surface_container": "#282727", "surface_container_high": "#393836",
        "surface_container_highest": "#625e5a", "surface_container_low": "#1d1c19",
        "surface_container_lowest": "#0d0c0c", "surface_dim": "#12120f",
        "surface_tint": "#957fb8", "surface_variant": "#625e5a",
        "tertiary": "#87a987", "tertiary_container": "#8a9a7b",
        "tertiary_fixed": "#8a9a7b", "tertiary_fixed_dim": "#87a987",
        # ANSI
        "ansi_red": "#c4746e", "ansi_red_bright": "#e46876",
        "ansi_green": "#8a9a7b", "ansi_green_bright": "#87a987",
        "ansi_yellow": "#c4b28a", "ansi_yellow_bright": "#e6c384",
        "ansi_blue": "#8ba4b0", "ansi_blue_bright": "#7fb4ca",
        "ansi_magenta": "#a292a3", "ansi_magenta_bright": "#938aa9",
        "ansi_cyan": "#8ea4a2", "ansi_cyan_bright": "#7aa89f",
        "ansi_black": "#0d0c0c", "ansi_black_bright": "#625e5a",
        "ansi_white": "#c5c9c5", "ansi_white_bright": "#c8c093",
        "syntax_orange": "#b6927b", "syntax_pink": "#a292a3",
    },
    "everforest": {
        "background": "#2d353b", "error": "#e67e80", "error_container": "#e67e80",
        "inverse_on_surface": "#2d353b", "inverse_primary": "#83c092",
        "inverse_surface": "#859289", "on_background": "#d3c6aa",
        "on_error": "#2d353b", "on_error_container": "#2d353b",
        "on_primary": "#2d353b", "on_primary_container": "#2d353b",
        "on_primary_fixed": "#2d353b", "on_primary_fixed_variant": "#3d484d",
        "on_secondary": "#2d353b", "on_secondary_container": "#2d353b",
        "on_secondary_fixed": "#2d353b", "on_secondary_fixed_variant": "#3d484d",
        "on_surface": "#d3c6aa", "on_surface_variant": "#9da9a0",
        "on_tertiary": "#2d353b", "on_tertiary_container": "#2d353b",
        "on_tertiary_fixed": "#2d353b", "on_tertiary_fixed_variant": "#3d484d",
        "outline": "#7a8478", "outline_variant": "#4f585e",
        "primary": "#a7c080", "primary_container": "#83c092",
        "primary_fixed": "#83c092", "primary_fixed_dim": "#a7c080",
        "scrim": "#000000",
        "secondary": "#7fbbb3", "secondary_container": "#d699b6",
        "secondary_fixed": "#d699b6", "secondary_fixed_dim": "#7fbbb3",
        "shadow": "#000000", "source_color": "#a7c080",
        "surface": "#2d353b", "surface_bright": "#56635f",
        "surface_container": "#3d484d", "surface_container_high": "#475258",
        "surface_container_highest": "#4f585e", "surface_container_low": "#343f44",
        "surface_container_lowest": "#232a2e", "surface_dim": "#2d353b",
        "surface_tint": "#a7c080", "surface_variant": "#4f585e",
        "tertiary": "#dbbc7f", "tertiary_container": "#e69875",
        "tertiary_fixed": "#e69875", "tertiary_fixed_dim": "#dbbc7f",
        # ANSI
        "ansi_red": "#e67e80", "ansi_red_bright": "#e67e80",
        "ansi_green": "#a7c080", "ansi_green_bright": "#a7c080",
        "ansi_yellow": "#dbbc7f", "ansi_yellow_bright": "#dbbc7f",
        "ansi_blue": "#7fbbb3", "ansi_blue_bright": "#7fbbb3",
        "ansi_magenta": "#d699b6", "ansi_magenta_bright": "#d699b6",
        "ansi_cyan": "#83c092", "ansi_cyan_bright": "#83c092",
        "ansi_black": "#475258", "ansi_black_bright": "#4f585e",
        "ansi_white": "#859289", "ansi_white_bright": "#d3c6aa",
        "syntax_orange": "#e69875", "syntax_pink": "#d699b6",
    },
    "ocean": {
        "background": "#0f111a", "error": "#ff5370", "error_container": "#f07178",
        "inverse_on_surface": "#0f111a", "inverse_primary": "#89ddff",
        "inverse_surface": "#8f93a2", "on_background": "#eeffff",
        "on_error": "#0f111a", "on_error_container": "#0f111a",
        "on_primary": "#0f111a", "on_primary_container": "#0f111a",
        "on_primary_fixed": "#0f111a", "on_primary_fixed_variant": "#1f2233",
        "on_secondary": "#0f111a", "on_secondary_container": "#0f111a",
        "on_secondary_fixed": "#0f111a", "on_secondary_fixed_variant": "#1f2233",
        "on_surface": "#a6accd", "on_surface_variant": "#8f93a2",
        "on_tertiary": "#0f111a", "on_tertiary_container": "#0f111a",
        "on_tertiary_fixed": "#0f111a", "on_tertiary_fixed_variant": "#1f2233",
        "outline": "#464b5d", "outline_variant": "#292d3e",
        "primary": "#82aaff", "primary_container": "#89ddff",
        "primary_fixed": "#89ddff", "primary_fixed_dim": "#82aaff",
        "scrim": "#000000",
        "secondary": "#c792ea", "secondary_container": "#89ddff",
        "secondary_fixed": "#89ddff", "secondary_fixed_dim": "#c792ea",
        "shadow": "#000000", "source_color": "#82aaff",
        "surface": "#0f111a", "surface_bright": "#575656",
        "surface_container": "#1f2233", "surface_container_high": "#292d3e",
        "surface_container_highest": "#464b5d", "surface_container_low": "#1a1c25",
        "surface_container_lowest": "#090b10", "surface_dim": "#0f111a",
        "surface_tint": "#82aaff", "surface_variant": "#292d3e",
        "tertiary": "#c3e88d", "tertiary_container": "#ffcb6b",
        "tertiary_fixed": "#ffcb6b", "tertiary_fixed_dim": "#c3e88d",
        # ANSI
        "ansi_red": "#ff5370", "ansi_red_bright": "#f07178",
        "ansi_green": "#c3e88d", "ansi_green_bright": "#c3e88d",
        "ansi_yellow": "#ffcb6b", "ansi_yellow_bright": "#ffcb6b",
        "ansi_blue": "#82aaff", "ansi_blue_bright": "#82aaff",
        "ansi_magenta": "#c792ea", "ansi_magenta_bright": "#c792ea",
        "ansi_cyan": "#89ddff", "ansi_cyan_bright": "#89ddff",
        "ansi_black": "#292d3e", "ansi_black_bright": "#464b5d",
        "ansi_white": "#8f93a2", "ansi_white_bright": "#eeffff",
        "syntax_orange": "#f78c6c", "syntax_pink": "#ff5370",
    },
}

def enrich_theme(t):
    """Add computed color variants for vesktop base colors."""
    for name, key in [("red","ansi_red"), ("green","ansi_green"), ("blue","ansi_blue"),
                      ("yellow","ansi_yellow"), ("purple","ansi_magenta")]:
        base = t[key]
        t[f"{name}_1"] = brighten(base, 5)
        t[f"{name}_2"] = base
        t[f"{name}_3"] = adj_light(base, 45)
        t[f"{name}_4"] = adj_light(base, 35)
        t[f"{name}_5"] = adj_light(base, 25)
    return t

# --- Template: kitty-colors.conf ---

KITTY_TPL = """\
cursor %on_surface%
cursor_text_color %on_surface_variant%

foreground            %on_surface%
background            %surface_container_lowest%
selection_foreground  %on_secondary%
selection_background  %secondary_fixed_dim%
url_color             %primary%

# black
color0   %surface_container_high%
color8   %surface_container_highest%

# red (secondary, hue forced to red)
color1   %ansi_red%
color9   %ansi_red_bright%

# green (tertiary, hue forced to green)
color2   %ansi_green%
color10  %ansi_green_bright%

# yellow (primary, hue forced to yellow)
color3   %ansi_yellow%
color11  %ansi_yellow_bright%

# blue (primary, as-is)
color4   %ansi_blue%
color12  %ansi_blue_bright%

# magenta (secondary, hue forced to magenta)
color5   %ansi_magenta%
color13  %ansi_magenta_bright%

# cyan (tertiary, hue forced to cyan)
color6   %ansi_cyan%
color14  %ansi_cyan_bright%

# white
color7   %inverse_surface%
color15  %on_background%

mark1_foreground %on_primary_fixed%
mark1_background %primary_fixed%
mark2_foreground %on_secondary_fixed%
mark2_background %secondary_fixed%
mark3_foreground %on_tertiary_fixed%
mark3_background %tertiary_fixed%

active_tab_foreground %on_primary%
active_tab_background %primary%
inactive_tab_foreground %on_primary_container%
inactive_tab_background %primary_container%

active_border_color %primary%
inactive_border_color %on_primary%
"""

# --- Template: neovim-theme.lua ---

NEOVIM_TPL = """\
-- Auto-generated by Matugen
-- Colors derived from matugen palette with forced hues (matching ANSI/kitty)

local colors = {
  red      = '%ansi_red%',
  green    = '%ansi_green%',
  yellow   = '%ansi_yellow%',
  blue     = '%ansi_blue%',
  magenta  = '%ansi_magenta%',
  cyan     = '%ansi_cyan%',
  orange   = '%syntax_orange%',
  pink     = '%syntax_pink%',

  fg       = '%on_surface%',
  fg_dim   = '%on_surface_variant%',
  comment  = '%outline%',
  primary  = '%primary%',
  secondary = '%secondary%',
}

-- Helper
local function set_hl_multiple(groups, value)
  for _, v in pairs(groups) do
    vim.api.nvim_set_hl(0, v, value)
  end
end

-- Core: transparent backgrounds
vim.api.nvim_set_hl(0, 'Normal', { fg = colors.fg, bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalNC', { fg = colors.fg, bg = 'NONE' })
vim.api.nvim_set_hl(0, 'NormalFloat', { fg = colors.fg, bg = 'NONE' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { fg = colors.comment, bg = 'NONE' })
vim.api.nvim_set_hl(0, 'MsgArea', { fg = colors.fg, bg = 'NONE' })

-- Selection / cursor (these need bg to be readable)
vim.api.nvim_set_hl(0, 'Visual', {
  bg = '%primary_container%',
})
vim.api.nvim_set_hl(0, 'CursorLine', {
  bg = '%surface_container_high%',
})
vim.api.nvim_set_hl(0, 'Search', {
  bg = '%secondary_container%',
  fg = '%on_secondary_container%',
})
vim.api.nvim_set_hl(0, 'IncSearch', {
  bg = '%primary%',
  fg = '%on_primary%',
})
vim.api.nvim_set_hl(0, 'PmenuSel', {
  bg = '%primary%',
  fg = '%on_primary%',
})

-- Pmenu (needs bg to float above content)
vim.api.nvim_set_hl(0, 'Pmenu', {
  bg = '%surface_container_high%',
  fg = colors.fg,
})

-- StatusLine (needs bg to separate from content)
vim.api.nvim_set_hl(0, 'StatusLine', {
  bg = '%surface_container%',
  fg = colors.fg,
})

-- Line numbers
vim.api.nvim_set_hl(0, 'LineNr', { fg = colors.comment })
vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = colors.primary, bold = true })

-- Comments
set_hl_multiple({ 'Comment', '@comment' }, {
  fg = colors.comment,
  italic = true,
})

-- Keywords (primary accent)
set_hl_multiple({ 'Keyword', '@keyword', '@keyword.control', '@keyword.function', 'Conditional', 'Repeat' }, {
  fg = colors.primary,
})

-- Functions (secondary accent)
set_hl_multiple({ 'Function', '@function', '@function.call', '@method', '@method.call' }, {
  fg = colors.secondary,
})

-- Strings (green)
set_hl_multiple({ 'String', '@string', '@string.escape' }, {
  fg = colors.green,
})

-- Numbers & Constants (orange)
set_hl_multiple({ 'Number', '@number', 'Boolean', '@boolean', 'Constant', '@constant' }, {
  fg = colors.orange,
})

-- Types & Classes (yellow)
set_hl_multiple({ 'Type', '@type', '@type.builtin', 'Structure', 'StorageClass' }, {
  fg = colors.yellow,
})

-- Variables (default fg)
set_hl_multiple({ 'Identifier', '@variable', '@parameter' }, {
  fg = colors.fg,
})

-- Special/Magic variables (red)
set_hl_multiple({ '@variable.builtin', 'Special' }, {
  fg = colors.red,
  italic = true,
})

-- Operators (fg)
set_hl_multiple({ 'Operator', '@operator' }, {
  fg = colors.cyan,
})

-- Punctuation
set_hl_multiple({ 'Delimiter', '@punctuation.delimiter', '@punctuation.bracket' }, {
  fg = colors.fg_dim,
})

-- Tags (HTML/XML)
set_hl_multiple({ 'Tag', '@tag', '@tag.delimiter' }, {
  fg = colors.primary,
})

-- Attributes
set_hl_multiple({ '@tag.attribute' }, {
  fg = colors.secondary,
  italic = true,
})

-- Diagnostics
vim.api.nvim_set_hl(0, 'Error', { fg = colors.red, bold = true })
vim.api.nvim_set_hl(0, 'DiagnosticError', { fg = colors.red })
vim.api.nvim_set_hl(0, 'DiagnosticWarn', { fg = colors.yellow })
vim.api.nvim_set_hl(0, 'DiagnosticInfo', { fg = colors.blue })
vim.api.nvim_set_hl(0, 'DiagnosticHint', { fg = colors.fg_dim })
"""

# --- Template: vscode-settings.json ---

VSCODE_TPL = """\
{
    "workbench.activityBar.location": "hidden",
    "breadcrumbs.enabled": false,
    "editor.minimap.enabled": false,
    "editor.scrollbar.vertical": "hidden",
    "editor.scrollbar.horizontal": "hidden",
    "workbench.editor.showTabs": "single",
    "window.menuBarVisibility": "toggle",
    "editor.lineNumbers": "relative",
    "vim.useSystemClipboard": true,
    "vim.hlsearch": true,
    "vim.leader": "<space>",
    "vim.normalModeKeyBindingsNonRecursive": [
        { "before": ["<leader>", "e"], "commands": ["workbench.view.explorer"] },
        { "before": ["<leader>", "f"], "commands": ["workbench.action.quickOpen"] },
        { "before": ["<leader>", "w"], "commands": ["workbench.action.files.save"] },
        { "before": ["<C-h>"], "commands": ["workbench.action.navigateLeft"] },
        { "before": ["<C-l>"], "commands": ["workbench.action.navigateRight"] },
        { "before": ["<C-k>"], "commands": ["workbench.action.navigateUp"] },
        { "before": ["<C-j>"], "commands": ["workbench.action.navigateDown"] }
    ],
    "editor.lineHeight": 1.6,
    "editor.cursorBlinking": "solid",
    "workbench.startupEditor": "none",
    "workbench.colorCustomizations": {
        "focusBorder": "%primary%",
        "foreground": "%on_surface%",
        "editor.background": "%surface_container_lowest%",
        "editor.foreground": "%on_surface%",
        "editor.lineHighlightBackground": "%surface_container%",
        "editor.selectionBackground": "%primary_container%40",
        "editorBracketMatch.background": "%primary_container%40",
        "editorBracketMatch.border": "%primary%",
        "editorCursor.foreground": "%primary%",
        "editorLineNumber.foreground": "%outline%",
        "editorLineNumber.activeForeground": "%primary%",
        "activityBar.background": "%surface_dim%",
        "activityBar.foreground": "%primary%",
        "activityBar.inactiveForeground": "%on_surface_variant%",
        "activityBarBadge.background": "%primary%",
        "activityBarBadge.foreground": "%on_primary%",
        "sideBar.background": "%surface_dim%",
        "sideBar.foreground": "%on_surface%",
        "sideBarTitle.foreground": "%primary%",
        "sideBarSectionHeader.background": "%surface_container_low%",
        "sideBarSectionHeader.foreground": "%on_surface%",
        "list.activeSelectionBackground": "%primary%",
        "list.activeSelectionForeground": "%on_primary%",
        "list.inactiveSelectionBackground": "%surface_container%",
        "list.hoverBackground": "%surface_container_high%",
        "statusBar.background": "%surface_dim%",
        "statusBar.foreground": "%on_surface%",
        "statusBar.noFolderBackground": "%surface_dim%",
        "titleBar.activeBackground": "%surface_dim%",
        "titleBar.activeForeground": "%on_surface%",
        "titleBar.inactiveBackground": "%surface_dim%",
        "titleBar.inactiveForeground": "%on_surface_variant%",
        "tab.activeBackground": "%surface_container_lowest%",
        "tab.activeForeground": "%primary%",
        "tab.activeBorderTop": "%primary%",
        "tab.inactiveBackground": "%surface_dim%",
        "tab.inactiveForeground": "%on_surface_variant%",
        "tab.border": "%surface_dim%",
        "editorGroupHeader.tabsBackground": "%surface_dim%",
        "editorWidget.background": "%surface_container_low%",
        "editorWidget.border": "%outline%",
        "editorSuggestWidget.background": "%surface_container_low%",
        "editorSuggestWidget.selectedBackground": "%surface_container%",
        "editorSuggestWidget.highlightForeground": "%primary%",
        "editorHoverWidget.background": "%surface_container_low%",
        "editorHoverWidget.border": "%outline%",
        "input.background": "%surface_container%",
        "input.foreground": "%on_surface%",
        "input.border": "%outline%",
        "inputOption.activeBorder": "%primary%",
        "button.background": "%primary%",
        "button.foreground": "%on_primary%",
        "button.hoverBackground": "%primary_container%",
        "dropdown.background": "%surface_container_low%",
        "dropdown.border": "%primary%",
        "panel.background": "%surface_container_lowest%",
        "panel.border": "%outline%",
        "panelTitle.activeForeground": "%primary%",
        "panelTitle.activeBorder": "%primary%",
        "terminal.foreground": "%on_surface%",
        "terminal.background": "%surface_container_lowest%",
        "terminal.ansiBlack": "%surface_container_high%",
        "terminal.ansiBrightBlack": "%surface_container_highest%",
        "terminal.ansiRed": "%ansi_red%",
        "terminal.ansiBrightRed": "%ansi_red_bright%",
        "terminal.ansiGreen": "%ansi_green%",
        "terminal.ansiBrightGreen": "%ansi_green_bright%",
        "terminal.ansiYellow": "%ansi_yellow%",
        "terminal.ansiBrightYellow": "%ansi_yellow_bright%",
        "terminal.ansiBlue": "%ansi_blue%",
        "terminal.ansiBrightBlue": "%ansi_blue_bright%",
        "terminal.ansiMagenta": "%ansi_magenta%",
        "terminal.ansiBrightMagenta": "%ansi_magenta_bright%",
        "terminal.ansiCyan": "%ansi_cyan%",
        "terminal.ansiBrightCyan": "%ansi_cyan_bright%",
        "terminal.ansiWhite": "%inverse_surface%",
        "terminal.ansiBrightWhite": "%on_background%",
        "terminal.selectionBackground": "%primary_container%80",
        "terminalCursor.foreground": "%primary%",
        "scrollbarSlider.background": "%outline%80",
        "scrollbarSlider.hoverBackground": "%outline%",
        "scrollbarSlider.activeBackground": "%primary%80"
    },
    "editor.tokenColorCustomizations": {
        "comments": "%outline%",
        "keywords": "%ansi_magenta%",
        "strings": "%ansi_green%",
        "numbers": "%syntax_orange%",
        "functions": "%primary%",
        "types": "%ansi_yellow%",
        "variables": "%on_surface%",
        "textMateRules": [
            {
                "scope": ["text", "source", "variable.other.readwrite", "punctuation.definition.variable"],
                "settings": {
                    "foreground": "%on_surface%"
                }
            },
            {
                "scope": "punctuation",
                "settings": {
                    "foreground": "%outline%"
                }
            },
            {
                "scope": ["comment", "punctuation.definition.comment"],
                "settings": {
                    "foreground": "%outline%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["string", "punctuation.definition.string"],
                "settings": {
                    "foreground": "%ansi_green%"
                }
            },
            {
                "scope": "constant.character.escape",
                "settings": {
                    "foreground": "%syntax_pink%"
                }
            },
            {
                "scope": ["constant.numeric", "variable.other.constant", "entity.name.constant", "constant.language.boolean"],
                "settings": {
                    "foreground": "%syntax_orange%"
                }
            },
            {
                "scope": ["keyword", "keyword.operator.word", "keyword.operator.new", "variable.language.super", "support.type.primitive", "storage.type", "storage.modifier", "punctuation.definition.keyword"],
                "settings": {
                    "foreground": "%ansi_magenta%"
                }
            },
            {
                "scope": ["keyword.operator", "punctuation.accessor", "punctuation.definition.generic", "punctuation.separator.key-value"],
                "settings": {
                    "foreground": "%ansi_cyan%"
                }
            },
            {
                "scope": ["entity.name.function", "meta.function-call.method", "support.function", "variable.function"],
                "settings": {
                    "foreground": "%primary%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["entity.name.class", "entity.other.inherited-class", "support.class", "meta.function-call.constructor", "entity.name.struct", "entity.name.enum"],
                "settings": {
                    "foreground": "%ansi_yellow%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["variable.other.enummember", "meta.enum variable.other.readwrite"],
                "settings": {
                    "foreground": "%ansi_cyan%"
                }
            },
            {
                "scope": ["meta.property.object"],
                "settings": {
                    "foreground": "%ansi_cyan%"
                }
            },
            {
                "scope": ["meta.type", "meta.type-alias", "support.type", "entity.name.type"],
                "settings": {
                    "foreground": "%ansi_yellow%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["meta.annotation variable.function", "meta.decorator", "punctuation.decorator"],
                "settings": {
                    "foreground": "%syntax_orange%"
                }
            },
            {
                "scope": ["variable.parameter", "meta.function.parameters"],
                "settings": {
                    "foreground": "%ansi_red%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["constant.language", "support.function.builtin"],
                "settings": {
                    "foreground": "%ansi_red%"
                }
            },
            {
                "scope": ["entity.name.namespace"],
                "settings": {
                    "foreground": "%ansi_yellow%"
                }
            },
            {
                "scope": ["variable.language.this"],
                "settings": {
                    "foreground": "%ansi_red%"
                }
            },
            {
                "scope": ["keyword.other.definition.ini", "support.type.property-name.json", "support.type.property-name.toml", "entity.name.tag.yaml"],
                "settings": {
                    "foreground": "%primary%"
                }
            },
            {
                "scope": ["constant.language.json", "constant.language.yaml"],
                "settings": {
                    "foreground": "%syntax_orange%"
                }
            },
            {
                "scope": ["support.type.property-name.table", "entity.name.section.group-title.ini"],
                "settings": {
                    "foreground": "%ansi_yellow%"
                }
            },
            {
                "scope": ["support.type.property-name.css"],
                "settings": {
                    "foreground": "%primary%"
                }
            },
            {
                "scope": ["source.css entity.other.attribute-name.class.css"],
                "settings": {
                    "foreground": "%ansi_yellow%"
                }
            },
            {
                "scope": ["entity.name.tag"],
                "settings": {
                    "foreground": "%primary%"
                }
            },
            {
                "scope": ["entity.other.attribute-name"],
                "settings": {
                    "foreground": "%ansi_yellow%"
                }
            },
            {
                "scope": ["markup.heading"],
                "settings": {
                    "foreground": "%ansi_red%",
                    "fontStyle": "bold"
                }
            },
            {
                "scope": ["markup.bold"],
                "settings": {
                    "foreground": "%ansi_red%",
                    "fontStyle": "bold"
                }
            },
            {
                "scope": ["markup.italic"],
                "settings": {
                    "foreground": "%ansi_red%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["markup.underline.link"],
                "settings": {
                    "foreground": "%primary%"
                }
            },
            {
                "scope": ["markup.inline.raw.string.markdown"],
                "settings": {
                    "foreground": "%ansi_green%"
                }
            },
            {
                "scope": ["variable.language.special.self.python"],
                "settings": {
                    "foreground": "%ansi_red%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["support.function.magic.python"],
                "settings": {
                    "foreground": "%ansi_cyan%",
                    "fontStyle": "italic"
                }
            },
            {
                "scope": ["entity.name.function.decorator.python", "punctuation.definition.decorator.python"],
                "settings": {
                    "foreground": "%syntax_orange%",
                    "fontStyle": "italic"
                }
            }
        ]
    }
}
"""

# --- Template: vesktop-system24.theme.css ---

VESKTOP_TPL = """\
/**
 * @name system24
 * @description a tui-style discord theme.
 * @author refact0r
 * @version 2.0.0
 * @invite nz87hXyvcy
 * @website https://github.com/refact0r/system24
 * @source https://github.com/refact0r/system24/blob/master/theme/system24.theme.css
 * @authorId 508863359777505290
 * @authorLink https://www.refact0r.dev
*/

/* import theme modules */
@import url('https://refact0r.github.io/system24/build/system24.css');

body {
    /* font, change to '' for default discord font */
    --font: 'JetBrainsMono Nerd Font'; /* change to '' for default discord font */
    --code-font: 'Maple Mono NF CN'; /* change to '' for default discord font */
    font-weight: 300; /* text font weight. 300 is light, 400 is normal. DOES NOT AFFECT BOLD TEXT */
    letter-spacing: -0.05ch; /* decreases letter spacing for better readability. recommended on monospace fonts.*/

    /* sizes */
    --gap: 12px; /* spacing between panels */
    --divider-thickness: 4px; /* thickness of unread messages divider and highlighted message borders */
    --border-thickness: 2px; /* thickness of borders around main panels. DOES NOT AFFECT OTHER BORDERS */
    --border-hover-transition: 0.2s ease; /* transition for borders when hovered */

    /* animation/transition options */
    --animations: on; /* off: disable animations/transitions, on: enable animations/transitions */
    --list-item-transition: 0.2s ease; /* transition for list items */
    --dms-icon-svg-transition: 0.4s ease; /* transition for the dms icon */

    /* top bar options */
    --top-bar-height: var(--gap); /* height of the top bar (discord default is 36px, old discord style is 24px, var(--gap) recommended if button position is set to titlebar) */
    --top-bar-button-position: titlebar; /* off: default position, hide: hide buttons completely, serverlist: move inbox button to server list, titlebar: move inbox button to channel titlebar (will hide title) */
    --top-bar-title-position: off; /* off: default centered position, hide: hide title completely, left: left align title (like old discord) */
    --subtle-top-bar-title: off; /* off: default, on: hide the icon and use subtle text color (like old discord) */

    /* window controls */
    --custom-window-controls: off; /* off: default window controls, on: custom window controls */
    --window-control-size: 14px; /* size of custom window controls */

    /* dms button options */
    --custom-dms-icon: off; /* off: use default discord icon, hide: remove icon entirely, custom: use custom icon */
    --dms-icon-svg-url: url(''); /* icon svg url. MUST BE A SVG. */
    --dms-icon-svg-size: 90%; /* size of the svg (css mask-size property) */
    --dms-icon-color-before: var(--icon-secondary); /* normal icon color */
    --dms-icon-color-after: var(--white); /* icon color when button is hovered/selected */
    --custom-dms-background: off; /* off to disable, image to use a background image (must set url variable below), color to use a custom color/gradient */
    --dms-background-image-url: url(''); /* url of the background image */
    --dms-background-image-size: cover; /* size of the background image (css background-size property) */
    --dms-background-color: linear-gradient(70deg, var(--blue-2), var(--purple-2), var(--red-2)); /* fixed color/gradient (css background property) */

    /* background image options */
    --background-image: off; /* off: no background image, on: enable background image (must set url variable below) */
    --background-image-url: url(''); /* url of the background image */

    /* transparency/blur options */
    /* NOTE: TO USE TRANSPARENCY/BLUR, YOU MUST HAVE TRANSPARENT BG COLORS. FOR EXAMPLE: --bg-4: hsla(220, 15%, 10%, 0.7); */
    --transparency-tweaks: off; /* off: no changes, on: remove some elements for better transparency */
    --remove-bg-layer: off; /* off: no changes, on: remove the base --bg-3 layer for use with window transparency (WILL OVERRIDE BACKGROUND IMAGE) */
    --panel-blur: off; /* off: no changes, on: blur the background of panels */
    --blur-amount: 12px; /* amount of blur */
    --bg-floating: var(--bg-3); /* set this to a more opaque color if floating panels look too transparent. only applies if panel blur is on  */

    /* other options */
    --small-user-panel: on; /* off: default user panel, on: smaller user panel like in old discord */

    /* unrounding options */
    --unrounding: on; /* off: default, on: remove rounded corners from panels */

    /* styling options */
    --custom-spotify-bar: on; /* off: default, on: custom text-like spotify progress bar */
    --ascii-titles: on; /* off: default, on: use ascii font for titles at the start of a channel */
    --ascii-loader: system24; /* off: default, system24: use system24 ascii loader, cats: use cats loader */

    /* panel labels */
    --panel-labels: on; /* off: default, on: add labels to panels */
    --label-color: var(--text-muted); /* color of labels */
    --label-font-weight: 500; /* font weight of labels */
}

/* color options */
:root {
    --colors: on; /* off: discord default colors, on: midnight custom colors */

    /* text colors */
    --text-0: var(--bg-4); /* text on colored elements */
    --text-1: oklch(95% 0 0); /* other normally white text */
    --text-2: oklch(85% 0 0); /* headings and important text */
    --text-3: oklch(75% 0 0); /* normal text */
    --text-4: oklch(60% 0 0); /* icon buttons and channels */
    --text-5: oklch(40% 0 0); /* muted channels/chats and timestamps */

    /* background and dark colors - THEMED BY MATUGEN */
    --bg-1: %surface_container_high%; /* dark buttons when clicked */
    --bg-2: %surface_container%; /* dark buttons */
    --bg-3: %surface_container_low%; /* spacing, secondary elements */
    --bg-4: %surface%; /* main background color */
    --hover: color-mix(in srgb, %on_surface% 10%, transparent); /* channels and buttons when hovered */
    --active: color-mix(in srgb, %on_surface% 20%, transparent); /* channels and buttons when clicked or selected */
    --active-2: color-mix(in srgb, %on_surface% 30%, transparent); /* extra state for transparent buttons */
    --message-hover: var(--hover); /* messages when hovered */

    /* accent colors */
    --accent-1: %primary%; /* links and other accent text */
    --accent-2: %primary%; /* small accent elements */
    --accent-3: %primary%; /* accent buttons */
    --accent-4: %primary_container%; /* accent buttons when hovered */
    --accent-5: %tertiary%; /* accent buttons when clicked */
    --accent-new: var(--red-2); /* stuff that's normally red like mute/deafen buttons */
    --mention: linear-gradient(to right, color-mix(in hsl, var(--accent-2), transparent 90%) 40%, transparent); /* background of messages that mention you */
    --mention-hover: linear-gradient(to right, color-mix(in hsl, var(--accent-2), transparent 95%) 40%, transparent); /* background of messages that mention you when hovered */
    --reply: linear-gradient(to right, color-mix(in hsl, var(--text-3), transparent 90%) 40%, transparent); /* background of messages that reply to you */
    --reply-hover: linear-gradient(to right, color-mix(in hsl, var(--text-3), transparent 95%) 40%, transparent); /* background of messages that reply to you when hovered */

    /* status indicator colors */
    --online: var(--green-2); /* change to #40a258 for default */
    --dnd: var(--red-2); /* change to #d83a41 for default */
    --idle: var(--yellow-2); /* change to #cc954c for default */
    --streaming: var(--purple-2); /* change to ##9147ff for default */
    --offline: var(--text-4); /* change to #82838b for default offline color */

    /* border colors */
    --border-light: var(--hover); /* general light border color */
    --border: var(--active); /* general normal border color */
    --border-hover: var(--accent-2); /* border color of panels when hovered */
    --button-border: hsl(220, 0%, 100%, 0.1); /* neutral border color of buttons */

    /* base colors - derived from theme palette */
    --red-1: %red_1%;
    --red-2: %red_2%;
    --red-3: %red_3%;
    --red-4: %red_4%;
    --red-5: %red_5%;

    --green-1: %green_1%;
    --green-2: %green_2%;
    --green-3: %green_3%;
    --green-4: %green_4%;
    --green-5: %green_5%;

    --blue-1: %blue_1%;
    --blue-2: %blue_2%;
    --blue-3: %blue_3%;
    --blue-4: %blue_4%;
    --blue-5: %blue_5%;

    --yellow-1: %yellow_1%;
    --yellow-2: %yellow_2%;
    --yellow-3: %yellow_3%;
    --yellow-4: %yellow_4%;
    --yellow-5: %yellow_5%;

    --purple-1: %purple_1%;
    --purple-2: %purple_2%;
    --purple-3: %purple_3%;
    --purple-4: %purple_4%;
    --purple-5: %purple_5%;
}
"""

# --- Template: gtk-colors.css ---

GTK_TPL = """\
/*
* GTK Colors
* Generated with Matugen
*/

* {
  font-family: "JetBrainsMono Nerd Font", "JetBrains Mono", "Noto Sans", "Noto Sans CJK JP", "Noto Sans CJK KR", "Noto Sans CJK SC", "Noto Sans Arabic", "Noto Sans Thai", monospace;
}

/* Accent colors */
@define-color accent_color %primary_fixed_dim%;
@define-color accent_fg_color %on_primary_fixed%;
@define-color accent_bg_color %primary_fixed_dim%;

/* Window colors */
@define-color window_bg_color %surface%;
@define-color window_fg_color %on_surface%;

/* Headerbar colors */
@define-color headerbar_bg_color %surface_container_high%;
@define-color headerbar_fg_color %on_surface%;
@define-color headerbar_border_color %outline_variant%;
@define-color headerbar_backdrop_color %surface_container%;
@define-color headerbar_shade_color rgba(0, 0, 0, 0.36);

/* Popover colors */
@define-color popover_bg_color %surface_container_high%;
@define-color popover_fg_color %on_surface%;

/* View colors */
@define-color view_bg_color %surface_container%;
@define-color view_fg_color %on_surface%;

/* Card colors */
@define-color card_bg_color %surface_container_high%;
@define-color card_fg_color %on_surface%;
@define-color card_shade_color rgba(0, 0, 0, 0.36);

/* Dialog colors */
@define-color dialog_bg_color %surface_container_high%;
@define-color dialog_fg_color %on_surface%;

/* Sidebar colors */
@define-color sidebar_bg_color %surface_container_low%;
@define-color sidebar_fg_color %on_surface%;
@define-color sidebar_border_color %outline_variant%;
@define-color sidebar_backdrop_color %surface_container_low%;

/* Additional semantic colors for GTK3/4 */
@define-color destructive_bg_color %error%;
@define-color destructive_fg_color %on_error%;
@define-color success_bg_color #26a269;
@define-color success_fg_color #ffffff;
@define-color warning_bg_color #e5a50a;
@define-color warning_fg_color #ffffff;
@define-color error_bg_color %error%;
@define-color error_fg_color %on_error%;

/* Legacy GTK theme colors */
@define-color theme_bg_color %surface%;
@define-color theme_fg_color %on_surface%;
@define-color theme_base_color %surface_container%;
@define-color theme_text_color %on_surface%;
@define-color theme_selected_bg_color %primary%;
@define-color theme_selected_fg_color %on_primary%;
@define-color insensitive_bg_color %surface_dim%;
@define-color insensitive_fg_color %outline%;
@define-color insensitive_base_color %surface_container_low%;
@define-color theme_unfocused_bg_color %surface%;
@define-color theme_unfocused_fg_color %on_surface%;
@define-color theme_unfocused_base_color %surface_container%;
@define-color theme_unfocused_text_color %on_surface%;
@define-color theme_unfocused_selected_bg_color %primary_container%;
@define-color theme_unfocused_selected_fg_color %on_primary_container%;
@define-color borders %outline_variant%;
@define-color unfocused_borders %outline%;

/* Additional utility colors */
@define-color shade_color rgba(0, 0, 0, 0.36);
@define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
"""

# --- Template: kde.colors ---

KDE_COLORS_TPL = """\
[ColorEffects:Disabled]
Color=%on_surface_variant%
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=%surface_variant%
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=%surface_container%
BackgroundNormal=%surface%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%primary%
ForegroundInactive=%on_surface_variant%
ForegroundLink=%primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_surface%
ForegroundPositive=%on_surface%
ForegroundVisited=%on_surface%

[Colors:Selection]
BackgroundAlternate=%primary%
BackgroundNormal=%primary%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%on_primary%
ForegroundInactive=%on_surface_variant%
ForegroundLink=%on_primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_primary%
ForegroundPositive=%on_primary%
ForegroundVisited=%on_primary%

[Colors:Tooltip]
BackgroundAlternate=%surface_container_high%
BackgroundNormal=%surface_container_high%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%primary%
ForegroundInactive=%on_surface_variant%
ForegroundLink=%primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_surface%
ForegroundPositive=%on_surface%
ForegroundVisited=%on_surface%

[Colors:View]
BackgroundAlternate=%surface_container_low%
BackgroundNormal=%surface%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%on_surface%
ForegroundInactive=%on_surface%
ForegroundLink=%on_surface%
ForegroundNegative=%on_surface%
ForegroundNeutral=%on_surface%
ForegroundNormal=%on_surface%
ForegroundPositive=%on_surface%
ForegroundVisited=%on_surface%

[Colors:Window]
BackgroundAlternate=%surface%
BackgroundNormal=%background%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%primary%
ForegroundInactive=%on_surface_variant%
ForegroundLink=%primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_surface%
ForegroundPositive=%on_surface%
ForegroundVisited=%on_surface%

[General]
ColorScheme=MaterialYou
Name=MaterialYou

[WM]
activeBackground=%surface_container%
activeBlend=%on_surface%
activeForeground=%on_surface%
inactiveBackground=%background%
inactiveBlend=%on_surface_variant%
inactiveForeground=%on_surface_variant%\
"""

# --- Template: kdeglobals ---

KDEGLOBALS_TPL = """\
[ColorEffects:Disabled]
Color=%outline%
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=%outline_variant%
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=%surface_container_high%
BackgroundNormal=%surface_container%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%primary%
ForegroundInactive=%outline%
ForegroundLink=%primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_surface%
ForegroundPositive=%secondary%
ForegroundVisited=%secondary%

[Colors:Selection]
BackgroundAlternate=%primary%
BackgroundNormal=%primary%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%on_primary%
ForegroundInactive=%outline%
ForegroundLink=%on_primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_primary%
ForegroundPositive=%secondary%
ForegroundVisited=%secondary%

[Colors:Tooltip]
BackgroundAlternate=%surface_container_highest%
BackgroundNormal=%surface_container_highest%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%primary%
ForegroundInactive=%outline%
ForegroundLink=%primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_surface%
ForegroundPositive=%secondary%
ForegroundVisited=%secondary%

[Colors:View]
BackgroundAlternate=%surface_container_low%
BackgroundNormal=%surface_container%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%on_surface%
ForegroundInactive=%on_surface%
ForegroundLink=%on_surface%
ForegroundNegative=%on_surface%
ForegroundNeutral=%on_surface%
ForegroundNormal=%on_surface%
ForegroundPositive=%on_surface%
ForegroundVisited=%on_surface%

[Colors:Window]
BackgroundAlternate=%surface_container%
BackgroundNormal=%surface%
DecorationFocus=%primary%
DecorationHover=%primary%
ForegroundActive=%primary%
ForegroundInactive=%outline%
ForegroundLink=%primary%
ForegroundNegative=%error%
ForegroundNeutral=%tertiary%
ForegroundNormal=%on_surface%
ForegroundPositive=%secondary%
ForegroundVisited=%secondary%

[General]
ColorScheme=MaterialYou
TerminalApplication=kitty

[UiSettings]
ColorScheme=MaterialYou

[Icons]
Theme=Numix-Circle

[WM]
activeBackground=%surface_container_high%
activeBlend=%on_surface%
activeForeground=%on_surface%
inactiveBackground=%surface_dim%
inactiveBlend=%outline%
inactiveForeground=%outline%\
"""

# --- Template: qtct-colors.conf ---

QTCT_TPL = """\
[ColorScheme]
active_colors=%on_background%, %surface%, #ffffff, #cacaca, #9f9f9f, #b8b8b8, %on_background%, #ffffff, %on_surface%, %background%, %background%, %shadow%, %primary_container%, %on_primary_container%, %secondary%, %primary%, %surface%, %scrim%, %surface%, %on_surface%, %secondary%
disabled_colors=%on_background%, %surface%, #ffffff, #cacaca, #9f9f9f, #b8b8b8, %on_background%, #ffffff, %on_surface%, %background%, %background%, %shadow%, %primary_container%, %on_primary_container%, %secondary%, %primary%, %surface%, %scrim%, %surface%, %on_surface%, %secondary%
inactive_colors=%on_background%, %surface%, #ffffff, #cacaca, #9f9f9f, #b8b8b8, %on_background%, #ffffff, %on_surface%, %background%, %background%, %shadow%, %primary_container%, %on_primary_container%, %secondary%, %primary%, %surface%, %scrim%, %surface%, %on_surface%, %secondary%
"""

# --- Template: tmux-colors.conf ---

TMUX_TPL = """\
# Auto-generated by Matugen
set -g status-bg                          "%surface_container_lowest%"
set -gq @thm_bar_bg                       "%surface_container_lowest%"
set -gq @thm_bg                           "%surface%"
set -gq @thm_fg                           "%on_surface%"
set -gq @thm_primary                      "%primary%"
set -gq @thm_inverse_primary              "%inverse_primary%"
set -gq @thm_surface_low                  "%surface_container_low%"
set -gq @thm_surface                      "%surface_container%"
set -gq @thm_surface_variant              "%surface_container_high%"
set -gq @thm_outline                      "%outline_variant%"
set -gq @thm_text_variant                 "%on_surface_variant%"
# Some variables/options must be re-set, which can be done here
set -g status-style                       "bg=#{@thm_bg},fg=#{@thm_fg}"\
"""

# --- Template: btop.theme ---

BTOP_TPL = """\
# Matugen template for btop


# Colors should be in 6 or 2 character hexadecimal or single spaced rgb decimal: "#RRGGBB", "#BW" or "0-255 0-255 0-255"
# example for white: "#ffffff", "#ff" or "255 255 255".

# All graphs and meters can be gradients
# For single color graphs leave "mid" and "end" variable empty.
# Use "start" and "end" variables for two color gradient
# Use "start", "mid" and "end" for three color gradient

# Main background, empty for terminal default, need to be empty if you want transparent background
theme[main_bg]=""

# Main text color
theme[main_fg]="%on_surface%"

# Title color for boxes
theme[title]="%primary%"

# Highlight color for keyboard shortcuts
theme[hi_fg]="%secondary%"

# Background color of selected item in processes box
theme[selected_bg]="%primary%"

# Foreground color of selected item in processes box
theme[selected_fg]="%on_primary%"

# Color of inactive/disabled text
theme[inactive_fg]="%on_surface_variant%"

# Misc colors for processes box including mini cpu graphs, details memory graph and details status text
theme[proc_misc]="%tertiary%"

# Cpu box outline color
theme[cpu_box]="%outline%"

# Memory/disks box outline color
theme[mem_box]="%outline%"

# Net up/down box outline color
theme[net_box]="%outline%"

# Processes box outline color
theme[proc_box]="%outline%"

# Box divider line and small boxes line color
theme[div_line]="%outline_variant%"

# Temperature graph colors
theme[temp_start]="%secondary%"
theme[temp_mid]="%primary%"
theme[temp_end]="%error%"

# CPU graph colors
theme[cpu_start]="%secondary%"
theme[cpu_mid]="%primary%"
theme[cpu_end]="%error%"

# Mem/Disk free meter
theme[free_start]="%secondary%"
theme[free_mid]=""
theme[free_end]="%secondary_container%"

# Mem/Disk cached meter
theme[cached_start]="%tertiary%"
theme[cached_mid]=""
theme[cached_end]="%tertiary_container%"

# Mem/Disk available meter
theme[available_start]="%primary%"
theme[available_mid]=""
theme[available_end]="%primary_container%"

# Mem/Disk used meter
theme[used_start]="%error%"
theme[used_mid]=""
theme[used_end]="%error_container%"

# Download graph colors
theme[download_start]="%secondary%"
theme[download_mid]="%primary%"
theme[download_end]="%tertiary%"

# Upload graph colors
theme[upload_start]="%secondary%"
theme[upload_mid]="%primary%"
theme[upload_end]="%tertiary%"
"""

# --- Template: clipse-theme.json ---

CLIPSE_TPL = """\
{
    "UseCustomTheme": true,
    "DimmedDesc": "%outline%",
    "DimmedTitle": "%on_surface_variant%",
    "FilterDateFg": "%tertiary%",
    "PinIndicatorFg": "%primary%",
    "SelectedBorderFg": "%primary%",
    "SelectedDescFg": "%on_primary%",
    "SelectedTitleBg": "%primary%",
    "SelectedTitleFg": "%on_primary%",
    "StatusBarActiveFg": "%primary%",
    "StatusBarBg": "%surface_container%",
    "StatusBarFg": "%on_surface%",
    "TitleFg": "%on_surface%",
    "NormalDescFg": "%on_surface_variant%",
    "NormalTitleFg": "%on_surface%"
}
"""

# --- Template: fcitx5-theme.conf ---

FCITX5_TPL = """\
[Metadata]
Name=Material You
Version=1.0
Author=Matugen
Description=Material You theme for fcitx5

[InputPanel]
# Text color (also affects EN/JP indicator)
NormalColor=%on_surface%
# Background color
BackgroundColor=%surface_container_high%
# Highlight background
HighlightColor=%primary%
# Highlight text color
HighlightCandidateColor=%on_primary%
# Highlight label text color
HighlightTextColor=%on_surface%
# Normal candidate text color
CandidateTextColor=%on_surface%
# Normal label text color
NormalTextColor=%on_surface%
# Preedit text color (text you're typing)
PreeditColor=%on_surface%
# Auxiliary text color (EN/JP indicator, etc.)
AuxiliaryTextColor=%on_surface%

[InputPanel/TextMargin]
Left=12
Right=12
Top=8
Bottom=8

[InputPanel/Background]
Color=%surface_container_high%
BorderColor=%primary%
BorderWidth=2

[InputPanel/Background/Margin]
Left=2
Right=2
Top=2
Bottom=2

[InputPanel/Highlight]
Color=%primary%

[InputPanel/Highlight/Margin]
Left=8
Right=8
Top=6
Bottom=6

[Menu]
NormalColor=%surface_container_high%
HighlightColor=%primary%
NormalTextColor=%on_surface%
Spacing=4

[Menu/Background]
Color=%surface_container_high%
BorderColor=%primary%
BorderWidth=2

[Menu/Background/Margin]
Left=2
Right=2
Top=2
Bottom=2

[Menu/Highlight]
Color=%primary%

[Menu/Separator]
Color=%outline_variant%

[Menu/TextMargin]
Left=8
Right=8
Top=4
Bottom=4
"""

# --- Template: yazi-theme.toml ---

YAZI_TPL = """\
# : Manager [[[

[mgr]
cwd = { fg = "%on_surface%" }

# Find
find_keyword  = { fg = "%error%", bold = true, italic = true, underline = true }
find_position = { fg = "%error%", bold = true, italic = true }

# Marker
marker_copied   = { fg = "%tertiary_fixed%", bg = "%tertiary_fixed%" }
marker_cut      = { fg = "%tertiary_fixed%", bg = "%tertiary_fixed%" }
marker_marked   = { fg = "%error%", bg = "%error%" }
marker_selected = { fg = "%tertiary%", bg = "%tertiary%" }

# Count
count_copied   = { fg = "%on_tertiary_fixed%", bg = "%tertiary_fixed%" }
count_cut      = { fg = "%on_tertiary_fixed%", bg = "%tertiary_fixed%" }
count_selected = { fg = "%on_primary%", bg = "%tertiary%" }

# Border
border_symbol = "\u2502"
border_style  = { fg = "%surface_tint%" }

# : ]]]


# : Indicator [[[

[indicator]
padding = { open = "\u2588", close = "\u2588" }

# : ]]]


# : Tabs [[[

[tabs]
active    = { fg = "%primary%", bold = true, bg = "%surface%" }
inactive  = { fg = "%secondary%", bg = "%surface%" }
sep_inner = { open = "[", close = "]" }

# : ]]]


# : Mode [[[

[mode]
# Mode
normal_main = { bg = "%primary%", fg = "%on_primary%", bold = true }
normal_alt  = { bg = "%surface_variant%", fg = "%on_surface_variant%" }

# Select mode
select_main = { bg = "%secondary%", fg = "%on_secondary%", bold = true }
select_alt  = { bg = "%surface_variant%", fg = "%on_surface_variant%" }

# Unset mode
unset_main = { bg = "%tertiary%", fg = "%on_tertiary%", bold = true }
unset_alt  = { bg = "%surface_variant%", fg = "%on_surface_variant%" }

# : ]]]


# : Status [[[

[status]
sep_left  = { open = "\U0001fb41", close = "\U0001fb60" }
sep_right = { open = "\U0001fb41", close = "\U0001fb60" }

# Permissions
perm_type  = { fg = "%secondary%" }
perm_write = { fg = "%tertiary%" }
perm_read  = { fg = "%error%" }
perm_exec  = { fg = "%tertiary_fixed%" }
perm_sep   = { fg = "%primary_fixed%" }

# Progress
progress_label  = { bold = true }
progress_normal = { fg = "%primary%", bg = "%surface_bright%" }
progress_error  = { fg = "%error%", bg = "%surface_bright%" }

# : ]]]


# : Which [[[

[which]
cols = 3
mask = { bg = "%surface_bright%" }
cand = { fg = "%primary%" }
rest = { fg = "%on_primary%" }
desc = { fg = "%on_surface%" }
separator = " \u25b6 "
separator_style = { fg = "%on_surface%" }

# : ]]]


# : Notify [[[

[notify]
title_info  = { fg = "%tertiary%" }
title_warn  = { fg = "%primary%" }
title_error = { fg = "%error%" }

# : ]]]


# : Picker [[[

[pick]
border = { fg = "%primary%" }
active = { fg = "%tertiary%", bold = true }
inactive = {}

# : ]]]


# : Input [[[

[input]
border = { fg = "%primary%" }
value  = { fg = "%on_surface%" }

# : ]]]


# : Completion [[[

[cmp]
border = { fg = "%primary%", bg = "%on_primary%" }

# : ]]]


# : Tasks [[[

[tasks]
border  = { fg = "%primary%" }
title   = {}
hovered = { fg = "%tertiary_fixed%", underline = true }

# : ]]]


# : Help [[[

[help]
on     = { fg = "%on_surface%" }
run    = { fg = "%on_surface%" }
footer = { fg = "%on_secondary%", bg = "%secondary%" }

# : ]]]


# : File-specific styles [[[

[filetype]

rules = [
    # Images
    { mime = "image/*", fg = "%ansi_cyan_bright%" },

    # Media
    { mime = "{audio,video}/*", fg = "%ansi_yellow_bright%" },

    # Archives
    { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "%syntax_pink%" },

    # Documents
    { mime = "application/{pdf,doc,rtf}", fg = "%ansi_green_bright%" },

    # Special files
    { name = "*", is = "orphan", bg = "%error_container%" },
    { name = "*", is = "exec", fg = "%on_error_container%" },

    # Fallback
    { url = "*", fg = "%on_surface%" },
    { url = "*/", fg = "%surface_tint%" },
]

# : ]]]
"""

# --- Renderers ---

def render_colors_css(t):
    lines = ["/*", "* Css Colors", "* Generated with Matugen", "*/", ""]
    for name in M3_COLORS:
        lines.append(f"    @define-color {name} {t[name]};")
        lines.append("")
    return "\n".join(lines)

def render_hyprland(t):
    lines = []
    for name in M3_COLORS:
        h = strip(t[name])
        lines.append("")
        lines.append(f"$image = Null")
        lines.append(f"${name} = rgba({h}ff)")
    return "\n".join(lines) + "\n"

TEMPLATE_MAP = {
    "kitty-colors.conf": KITTY_TPL,
    "neovim-theme.lua": NEOVIM_TPL,
    "vscode-settings.json": VSCODE_TPL,
    "vesktop-system24.theme.css": VESKTOP_TPL,
    "gtk-colors.css": GTK_TPL,
    "kde.colors": KDE_COLORS_TPL,
    "kdeglobals": KDEGLOBALS_TPL,
    "qtct-colors.conf": QTCT_TPL,
    "tmux-colors.conf": TMUX_TPL,
    "btop.theme": BTOP_TPL,
    "clipse-theme.json": CLIPSE_TPL,
    "fcitx5-theme.conf": FCITX5_TPL,
    "yazi-theme.toml": YAZI_TPL,
}

FUNC_MAP = {
    "colors.css": render_colors_css,
    "hyprland-colors.conf": render_hyprland,
}

# --- Main ---

def main():
    for theme_name, palette in THEMES.items():
        palette = enrich_theme(dict(palette))  # copy to avoid mutation
        theme_dir = BASE / theme_name
        theme_dir.mkdir(parents=True, exist_ok=True)

        # Template-based files
        for filename, template in TEMPLATE_MAP.items():
            path = theme_dir / filename
            path.write_text(render(template, palette))
            print(f"  {theme_name}/{filename}")

        # Function-based files
        for filename, func in FUNC_MAP.items():
            path = theme_dir / filename
            path.write_text(func(palette))
            print(f"  {theme_name}/{filename}")

    print("\nDone! Generated all theme files.")

if __name__ == "__main__":
    main()
