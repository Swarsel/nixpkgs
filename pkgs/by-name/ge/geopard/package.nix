{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  glib-networking,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geopard";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "ranfdev";
    repo = "geopard";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wOkzylRfFJsdu9KC4TvF/qYkGf8OZVd1tRre5TbNOX4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    blueprint-compiler
    desktop-file-utils
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    libadwaita
    glib-networking
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-g7pHEBrR/tdKP+kuYJ44Py7kaAx0tXcMkC4UdsfSfDQ=";
  };

  meta = {
    description = "Colorful, adaptive gemini browser";
    homepage = "https://github.com/ranfdev/Geopard";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      jfvillablanca
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "geopard";
  };
})
