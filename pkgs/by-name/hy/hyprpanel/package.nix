{
  lib,
  stdenv,
  fetchFromGitHub,
  ags,
  astal,
  awww,
  bluez,
  bluez-tools,
  brightnessctl,
  btop,
  config,
  dart-sass,
  glib,
  glib-networking,
  gnome-bluetooth,
  gpu-screen-recorder,
  gpustat,
  grimblast,
  gtksourceview3,
  gvfs,
  hyprpicker,
  libgtop,
  libnotify,
  libsoup_3,
  matugen,
  networkmanager,
  nix-update-script,
  python3,
  pywal16,
  upower,
  wireplumber,
  wl-clipboard,
  writeShellScript,
  writeShellScriptBin,
  enableCuda ? config.cudaSupport,
}:

let
  # TODO: Remove once hyprpanel updates to use `awww`
  swww-compat = writeShellScriptBin "swww" ''
    exec awww "$@"
  '';
  swww-daemon-compat = writeShellScriptBin "swww-daemon" ''
    exec awww-daemon "$@"
  '';
in

ags.bundle {
  pname = "hyprpanel";
  version = "0-unstable-2026-04-23";

  src = fetchFromGitHub {
    owner = "Jas-SinghFSU";
    repo = "HyprPanel";
    rev = "1961ba86ad5ab880beb639e5454054b2b5037e0d";
    hash = "sha256-QowlCOrE4jGOTDCUCEx/E8gHjqSx3r25y7v4dEBpBhk=";
  };

  strictDeps = true;

  postFixup =
    let
      script = writeShellScript "hyprpanel" ''
        export GIO_EXTRA_MODULES='${glib-networking}/lib/gio/modules'
        if [ "$#" -eq 0 ]; then
          exec @out@/bin/.hyprpanel
        else
          exec ${astal.io}/bin/astal -i hyprpanel "$*"
        fi
      '';
    in
    # bash
    ''
      mv "$out/bin/hyprpanel" "$out/bin/.hyprpanel"
      cp '${script}' "$out/bin/hyprpanel"
      substituteInPlace "$out/bin/hyprpanel" \
        --replace-fail '@out@' "$out"
    '';

  __structuredAttrs = true;

  # keep in sync with https://github.com/Jas-SinghFSU/HyprPanel/blob/master/flake.nix#L42
  dependencies = [
    astal.apps
    astal.battery
    astal.bluetooth
    astal.cava
    astal.hyprland
    astal.mpris
    astal.network
    astal.notifd
    astal.powerprofiles
    astal.tray
    astal.wireplumber

    awww
    bluez
    bluez-tools
    brightnessctl
    btop
    dart-sass
    glib
    gnome-bluetooth
    grimblast
    gtksourceview3
    gvfs
    hyprpicker
    libgtop
    libnotify
    libsoup_3
    matugen
    networkmanager
    pywal16
    swww-compat
    swww-daemon-compat
    upower
    wireplumber
    wl-clipboard
    (python3.withPackages (
      ps:
      with ps;
      [
        dbus-python
        pygobject3
      ]
      ++ lib.optional enableCuda gpustat
    ))
  ]
  ++ (lib.optionals (stdenv.hostPlatform.system == "x86_64-linux") [ gpu-screen-recorder ]);

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Bar/Panel for Hyprland with extensive customizability";
    homepage = "https://github.com/Jas-SinghFSU/HyprPanel";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ PerchunPak ];
    platforms = lib.platforms.linux;
    mainProgram = "hyprpanel";
  };
}
