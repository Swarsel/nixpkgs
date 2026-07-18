{
  sway,
  swayfx-unwrapped,
  dbusSupport ? true,
  enableXWayland ? true,
  extraOptions ? [ ], # E.g.: [ "--verbose" ]
  extraSessionCommands ? "",
  isNixOS ? false,
  # Used by the NixOS module:
  withBaseWrapper ? true,
  withGtkWrapper ? false,
}:

sway.override {
  inherit
    withBaseWrapper
    extraSessionCommands
    withGtkWrapper
    extraOptions
    isNixOS
    enableXWayland
    dbusSupport
    ;

  sway-unwrapped = swayfx-unwrapped;
}
