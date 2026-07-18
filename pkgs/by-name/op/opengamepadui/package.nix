{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cargo,
  dbus,
  gamescope,
  godot_4_6,
  hwdata,
  libGL,
  libpulseaudio,
  mesa-demos,
  nix-update-script,
  pkg-config,
  rustPlatform,
  udev,
  upower,
  vulkan-loader,
  withDebug ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opengamepadui";
  version = "0.45.0";

  src = fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "OpenGamepadUI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B3s9fJzOUNKqvdz1CuJQKJTcQKBUsn8cEV0F6e9Pjr0=";
  };

  nativeBuildInputs = [
    cargo
    godot_4_6
    pkg-config
    rustPlatform.cargoSetupHook
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  buildFlags = [ "build" ];

  env =
    let
      versionAndRelease = lib.splitString "-" godot_4_6.version;
    in
    {
      BUILD_TYPE = "${finalAttrs.buildType}";
      EXPORT_TEMPLATE = "${godot_4_6.export-template}/share/godot/export_templates";
      GODOT = lib.getExe godot_4_6;
      GODOT_RELEASE = lib.elemAt versionAndRelease 1;
      GODOT_VERSION = lib.elemAt versionAndRelease 0;
    };

  preBuild = ''
    # Godot looks for export templates in HOME
    export HOME=$(mktemp -d)
    mkdir -p $HOME/.local/share/godot/
    ln -s "$EXPORT_TEMPLATE" "$HOME"/.local/share/godot/
  '';

  postInstall =
    let
      runtimeDependencies = [
        gamescope
        hwdata
        mesa-demos
        udev
        upower
      ];
    in
    ''
      # The Godot binary looks in "../lib" for gdextensions
      mkdir -p $out/share/lib
      mv $out/share/opengamepadui/*.so $out/share/lib
      patchelf --add-rpath ${lib.makeLibraryPath runtimeDependencies} $out/share/lib/*.so
    '';

  buildType = if withDebug then "debug" else "release";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src cargoRoot;
    hash = "sha256-aykBD6cyhLL3I2oCrxXEFotmULrhOlte9zNON9liQx4=";
  };

  cargoRoot = "extensions";
  dontStrip = withDebug;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open source gamepad-native game launcher and overlay";
    homepage = "https://github.com/ShadowBlip/OpenGamepadUI";
    changelog = "https://github.com/ShadowBlip/OpenGamepadUI/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ shadowapex ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "opengamepadui";
  };
})
