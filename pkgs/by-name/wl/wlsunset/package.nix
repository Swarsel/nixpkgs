{
  lib,
  stdenv,
  fetchFromSourcehut,
  meson,
  ninja,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wlsunset";
  version = "0.4.0";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = "wlsunset";
    rev = finalAttrs.version;
    sha256 = "sha256-U/yROKkU9pOBLIIIsmkltF64tt5ZR97EAxxGgrFYwNg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    wayland-scanner
    scdoc
  ];

  buildInputs = [
    wayland
    wayland-protocols
  ];

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Day/night gamma adjustments for Wayland";

    longDescription = ''
      Day/night gamma adjustments for Wayland compositors supporting
      wlr-gamma-control-unstable-v1.
    '';

    homepage = "https://sr.ht/~kennylevinsen/wlsunset/";
    changelog = "https://git.sr.ht/~kennylevinsen/wlsunset/refs/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "wlsunset";
  };
})
