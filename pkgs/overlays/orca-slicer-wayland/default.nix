{orca-slicer, ...}:
orca-slicer.overrideAttrs (old: {
  pname = "orca-slicer-wayland";

  patches = (old.patches or []) ++ [./wayland.patch];

  meta =
    old.meta
    // {
      description = "Orca Slicer with Wayland support patch";
    };
})
