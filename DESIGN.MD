# Design Philosophy

As mentioned in the preface, my desktop configuration has been specifically tailored to suit my workflow. Several components of my desktop were deliberately put in such a way that exploited my muscle memory while making the most use of the screen real estate. My configuration can be broken down into following (intertwined) components:

## Software selection

I'll quickly run through my (arguably insane) thought process to justify why I picked these software for my workflow

- **Terminal**: Kitty. GPU accelerated and allows images to be displayed. Essentially a bloated alacritty, in a good way. Not recommended for old hardware
- **Text editor**: VSCodium and Neovim, stripped of all Microsoft's telemetry of course. I find the former better suited for large projects and the latter convenient for editing individual files.
- **Browser**: Zen. Heavy on the memory but feature rich. Tab workspaces is a must.
- **File manager**: Dolphin. Feature rich, natively supports split view, tabs, and built-in terminals for quick scripting.

I find feature richness more important than minimalism for these essential tools.

## Status Bar

> What do I expect from a bar?

A bar serves to fulfil three prominent uses:

- **Status query:** the bar is the first place you'll look for system status without needing to carry out additional actions. As opposed to many who monitor their hardware via on-wallpaper widgets, I prefer the bar to contain my hardware utilization due to the compute-heavy nature of my work.
- **Quick launchers:** the bar is also a place for persistent buttons in a mouse-oriented workflow for commonly used launchers like applications or the power button.
- **On-hover widgets:** with a simple action of moving the cursor on certain modules, you're able to display an amount of (static) information comparable to launching a dedicated application.

> Why waybar?

**Warbar** is my bar of choice due to its simple `.jsonc` configuration. You're able to achieve the three use cases by configuring the bar's `on-click` and `tooltip` properties. Being backed by GTK, it uses a rather easy `css` styling system. Opposed to requiring dedicated shells (quickshell, AGS, EWW), I settled on waybar as the simplest option that fulfills my needs.

Still, waybar isn't without limitations. Custom waybar modules are nearly limited to text displays, not allowing for complex geometries and custom widgets outside of the bar itself and floating tooltips.

> Horizontal vs Vertical

As screens are rectangular, horizontal bars allow more information to be displayed at once at the cost of screen real estate. As such, I configured a vertical bar layout for "wide" (16:9) screens. This poses a challenge; 3+ character wide bars often look too wide to fit the bar aesthetics, and 2 characters is too little to cram all the information. I ended up settling with a compromises: nerd font icons allowed me to condense 3-digit hardware utilization into a single pie chart.

## Widgets

TBA

## Window Management

TBA