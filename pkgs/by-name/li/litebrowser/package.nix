{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  gtk3,
  gtkmm3,
  gumbo, # litehtml dependency
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "litebrowser";
  version = "0-unstable-2024-02-25";

  src = fetchFromGitHub {
    owner = "litehtml";
    repo = "litebrowser-linux";
    rev = "8130cf50af90e07d201d43b934b5a57f7ed4e68d";
    hash = "sha256-L/pd4VypDfjLKfh+HLpc4um+POWGzGa4OOttudwJxyk=";
    fetchSubmodules = true; # litehtml submodule
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gtk3
    gtkmm3
    curl
    gumbo
  ];

  cmakeFlags = [
    "-DEXTERNAL_GUMBO=ON"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 litebrowser $out/bin/litebrowser
    runHook postInstall
  '';

  meta = {
    description = "Simple browser based on the litehtml engine";
    homepage = "https://github.com/litehtml/litebrowser-linux";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.unix;
    mainProgram = "litebrowser";
    broken = stdenv.cc.isClang; # https://github.com/litehtml/litebrowser-linux/issues/19
  };
}
