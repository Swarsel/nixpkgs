{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  dbus,
  git,
  libGL,
  libx11,
  libxcb,
  libxkbcommon,
  makeDesktopItem,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
  udev,
  versionCheckHook,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "buttplug-lite";
  version = "2.5.5";

  src = fetchFromGitHub {
    owner = "runtime-shady-backroom";
    repo = "buttplug-lite";
    tag = finalAttrs.version;
    hash = "sha256-Z7xf+507rTWWygPV4p0+Q3e2rFIVgn1Ktu/W1P0FOfw=";
  };

  nativeBuildInputs = [
    pkg-config
    git
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    libx11
    libGL
    libxcb
    libxkbcommon
    dbus
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    udev
    wayland
  ];

  cargoHash = "sha256-XGfHJAlv1B+tFKhLqMWiUaVyCUnyuyVZmYz3wvwITQI=";

  postInstall = ''
    wrapProgram $out/bin/buttplug-lite --suffix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath (
        [
          libx11
          libGL
          libxcb
          libxkbcommon
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [ wayland ]
      )
    }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  desktopItems = [
    (makeDesktopItem {
      comment = "Simplified buttplug.io API for when JSON is infeasible";
      desktopName = "Buttplug Lite";
      exec = "buttplug-lite";
      name = "buttplug-lite";
    })
  ];

  meta = {
    description = "Simplified buttplug.io API for when JSON is infeasible";
    homepage = "https://github.com/runtime-shady-backroom/buttplug-lite";
    changelog = "https://github.com/runtime-shady-backroom/buttplug-lite/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ toasteruwu ];
  };
})
