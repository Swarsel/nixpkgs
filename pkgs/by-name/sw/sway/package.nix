{
  lib,
  dbus,
  gdk-pixbuf,
  glib,
  gtk3,
  makeWrapper,
  sway-unwrapped,
  symlinkJoin,
  wrapGAppsHook3,
  writeShellScriptBin,
  dbusSupport ? true,
  enableXWayland ? true,
  extraOptions ? [ ], # E.g.: [ "--verbose" ]
  extraSessionCommands ? "",
  # Used by the NixOS module:
  isNixOS ? false,
  withBaseWrapper ? true,
  withGtkWrapper ? false,
}:

assert extraSessionCommands != "" -> withBaseWrapper;

let
  inherit (builtins) replaceStrings;
  inherit (lib.lists) optional optionals;
  inherit (lib.meta) getExe;
  inherit (lib.strings) concatMapStrings optionalString;

  sway = sway-unwrapped.overrideAttrs (old: {
    inherit isNixOS enableXWayland;
  });
  baseWrapper = writeShellScriptBin sway.meta.mainProgram ''
    set -o errexit
    if [ ! "$_SWAY_WRAPPER_ALREADY_EXECUTED" ]; then
      export XDG_CURRENT_DESKTOP=${sway.meta.mainProgram}
      ${extraSessionCommands}
      export _SWAY_WRAPPER_ALREADY_EXECUTED=1
    fi
    if [ "$DBUS_SESSION_BUS_ADDRESS" ]; then
      export DBUS_SESSION_BUS_ADDRESS
      exec ${getExe sway} "$@"
    elif [ -n "$XDG_RUNTIME_DIR" ] && [ -S "$XDG_RUNTIME_DIR/bus" ]; then
      # Prefer the systemd --user bus (dbus-daemon or dbus-broker) over
      # spawning a redundant session bus via dbus-run-session.
      export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
      exec ${getExe sway} "$@"
    else
      exec ${optionalString dbusSupport "${dbus}/bin/dbus-run-session"} ${getExe sway} "$@"
    fi
  '';
in
symlinkJoin {
  inherit (sway) version;
  inherit (sway) meta;
  pname = replaceStrings [ "-unwrapped" ] [ "" ] sway.pname;
  strictDeps = false;
  nativeBuildInputs = [ makeWrapper ] ++ (optional withGtkWrapper wrapGAppsHook3);

  buildInputs = optionals withGtkWrapper [
    gdk-pixbuf
    glib
    gtk3
  ];

  postBuild = ''
    ${optionalString withGtkWrapper "gappsWrapperArgsHook"}

    wrapProgram $out/bin/${sway.meta.mainProgram} \
      ${optionalString withGtkWrapper ''"''${gappsWrapperArgs[@]}"''} \
      ${optionalString (extraOptions != [ ])
        "${concatMapStrings (x: " --add-flags " + x) extraOptions}"
      }
  '';

  # We want to run wrapProgram manually
  dontWrapGApps = true;
  paths = (optional withBaseWrapper baseWrapper) ++ [ sway ];

  passthru = {
    inherit (sway.passthru) tests;
    providedSessions = [ sway.meta.mainProgram ];
  };
}
