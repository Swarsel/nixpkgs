{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  feedbackd,
  glib,
  gnome-desktop,
  gtk3,
  libbsd,
  libxkbcommon,
  libxml2,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  rustPlatform,
  rustc,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "squeekboard";
  version = "1.43.1";

  src = fetchFromGitLab {
    owner = "Phosh";
    repo = "squeekboard";
    rev = "v${version}";
    hash = "sha256-UsUr4UnYNo2ybEdNyOD/IiafEZ1YJFwRQ3CVy76X2H0=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib
    wayland-scanner
    wrapGAppsHook3
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    gtk3
    gnome-desktop
    wayland
    wayland-protocols
    libbsd
    libxml2
    libxkbcommon
    feedbackd
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-3K1heokPYxYbiAGha9TrrjQXguzGv/djIB4eWa8dVjg=";
  };

  passthru.tests.phosh = nixosTests.phosh;

  meta = {
    description = "Virtual keyboard supporting Wayland";
    homepage = "https://gitlab.gnome.org/World/Phosh/squeekboard";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
  };
}
