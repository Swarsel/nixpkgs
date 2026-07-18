{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
  unstableGitUpdater,
}:
stdenvNoCC.mkDerivation {
  pname = "material-symbols";
  version = "4.0.0-unstable-2026-06-12";

  src = fetchFromGitHub {
    owner = "google";
    repo = "material-design-icons";
    rev = "5d5d1fdd5476f3df3749e9fb872e32021ec7a750";
    hash = "sha256-e0bxJpehssgnxigSgPt9qxMrKRZcvlVDyLu5DY6MkTA=";
    sparseCheckout = [ "variablefont" ];
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Material Symbols icons by Google";
    homepage = "https://fonts.google.com/icons";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      fufexan
      luftmensch-luftmensch
      alexphanna
    ];

    platforms = lib.platforms.all;
    downloadPage = "https://github.com/google/material-design-icons";
  };
}
