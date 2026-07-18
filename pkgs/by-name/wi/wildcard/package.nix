{
  lib,
  stdenv,
  fetchFromGitLab,
  blueprint-compiler,
  cargo,
  desktop-file-utils,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wildcard";
  version = "0.3.5";

  src = fetchFromGitLab {
    owner = "World";
    repo = "Wildcard";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8e3UWJ6PGhwvo/AB89VgkBfgsaNVa4g6hT9vBTmKlZQ=";
    domain = "gitlab.gnome.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    blueprint-compiler
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-hoJsXoPmp0A6oIV1Rm7eXI2U2OIGrStmKzDdPQtI41A=";
    name = "wildcard-${finalAttrs.version}";
  };

  meta = {
    description = "Test your regular expressions";

    longDescription = ''
      Wildcard gives you a nice and simple to use interface to test/practice regular expressions.
    '';

    homepage = "https://gitlab.gnome.org/World/Wildcard";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "wildcard";
    downloadPage = "https://gitlab.gnome.org/World/Wildcard/-/releases/v${finalAttrs.version}";
  };
})
