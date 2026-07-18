{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  libdrm,
  meson,
  ninja,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wayland-utils";
  version = "1.3.0";

  src = fetchurl {
    url = "https://gitlab.freedesktop.org/wayland/wayland-utils/-/releases/${finalAttrs.version}/downloads/wayland-utils-${finalAttrs.version}.tar.xz";
    hash = "sha256-o50OZWF8auGG12jCI/VwYKOkNfb58C0DB0+UUxO/zw0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    wayland-scanner
  ];

  buildInputs = [
    libdrm
    wayland
    wayland-protocols
  ];

  depsBuildBuild = [ pkg-config ];

  passthru.updateScript = gitUpdater {
    url = "https://gitlab.freedesktop.org/wayland/wayland-utils.git";
  };

  meta = {
    description = "Wayland utilities (wayland-info)";

    longDescription = ''
      A collection of Wayland related utilities:
      - wayland-info: A utility for displaying information about the Wayland
        protocols supported by a Wayland compositor.
    '';

    homepage = "https://gitlab.freedesktop.org/wayland/wayland-utils";
    license = lib.licenses.mit; # Expat version
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "wayland-info";
  };
})
