{
  lib,
  fetchFromGitHub,
  gtksourceview5,
  libadwaita,
  libpanel,
  pkg-config,
  poppler,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage {
  pname = "fm";
  version = "0-unstable-2024-01-03";

  src = fetchFromGitHub {
    owner = "euclio";
    repo = "fm";
    rev = "f1da116fe703a2c3d5bc9450703ecf1a1f1b4fda";
    hash = "sha256-fCufqCy5H5Up6V15sOz8SJrixth7OQ7tc4yIymmfq1M=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    libpanel
    gtksourceview5
    poppler
  ];

  cargoHash = "sha256-5B5TIFsfg7fWF5OEq0xVfkIUm1nlkvGfupr5qUtaiwA=";

  meta = {
    description = "Small, general purpose file manager built with GTK4";
    homepage = "https://github.com/euclio/fm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "fm";
  };
}
