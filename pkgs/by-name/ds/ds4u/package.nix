{
  lib,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  fetchFromGitea,
  hidapi,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  systemd,
  udevCheckHook,
  vulkan-loader,
  wayland,
  writeText,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ds4u";
  version = "0.1.1";

  src = fetchFromGitea {
    owner = "deadYokai";
    repo = "ds4u";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q8NbpFbrYMtE56CnnjScbMewHCTxaxMih8/I9dspb+o=";
    domain = "git.yokai.digital";
  };

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    libxkbcommon
    vulkan-loader
    wayland
    libx11
    libxcursor
    libxi
    openssl
    systemd
    hidapi
  ];

  cargoHash = "sha256-KjNHX3S+XFUsngX8Od3HtI0IvpAyMp5TB6TVkCkl8Gc=";

  preInstall = ''
    # desktop icon install
    install -Dm644 $src/assets/icon.svg $out/share/icons/hicolor/scalable/apps/ds4u.svg
    # udev rules
    install -Dm644 ${finalAttrs.udevRules} -D $out/lib/udev/rules.d/70-ds4u.rules
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ udevCheckHook ];
  __structuredAttrs = true;
  # autoPatchelfHook doesnt find these automatically using dlopen
  appendRunpaths = [ (lib.makeLibraryPath finalAttrs.buildInputs) ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Settings"
        "Game"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "DS4U";
      exec = "ds4u";
      icon = "ds4u";

      keywords = [
        "controller"
        "dualsense"
        "ps5"
        "gamepad"
      ];

      name = "ds4u";
      terminal = false;
      type = "Application";
    })
  ];

  udevRules = writeText "ds4u.rules" ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0664", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0664", GROUP="input", TAG+="uaccess"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "DualSense controller manager for Linux";
    homepage = "https://git.yokai.digital/deadYokai/ds4u";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cakeforcat ];
    platforms = lib.platforms.linux;
    mainProgram = "ds4u";
  };
})
