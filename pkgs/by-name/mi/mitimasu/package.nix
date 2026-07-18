{
  lib,
  fetchFromGitHub,
  installFonts,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "mitimasu";
  version = "0-unstable-2023-10-24";

  src = fetchFromGitHub {
    owner = "kemomimi-no-sato";
    repo = "mitimasu-webfont";
    rev = "6798f7a192d5c60adf75a3d32184057b8579e3c5";
    hash = "sha256-yiAnIVZY9DoIborO/s2KSlt6Zq1kAjKewLd30qBQqio=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  meta = {
    description = "Mitimasu webfont";
    homepage = "https://github.com/kemomimi-no-sato/mitimasu-webfont";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ istudyatuni ];
    platforms = lib.platforms.all;
  };
}
