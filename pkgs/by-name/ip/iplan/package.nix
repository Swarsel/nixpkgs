{
  lib,
  stdenv,
  fetchFromGitHub,
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

stdenv.mkDerivation rec {
  pname = "iplan";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "iman-salmani";
    repo = "iplan";
    rev = "v${version}";
    hash = "sha256-BIoxaE8c3HmvPjgj4wcZK9YFTZ0wr9338AIdYEoAiqs=";
  };

  nativeBuildInputs = [
    cargo
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-ATEm7RYfW9nYtTDAx580tvokVUIS7BL9mA65aEeJJvk=";
  };

  meta = {
    description = "Your plan for improving personal life and workflow";
    homepage = "https://github.com/iman-salmani/iplan";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "iplan";
  };
}
