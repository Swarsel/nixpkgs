{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  libftdi1,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "fw-ectool";
  version = "0-unstable-2024-04-23";

  src = fetchFromGitLab {
    owner = "DHowett";
    repo = "ectool";
    rev = "abdd574ebe3640047988cb928bb6789a15dd1390";
    hash = "sha256-j0Z2Uo1LBXlHZVHPm4Xjx3LZaI6Qq0nSdViyC/CjWC8=";
    domain = "gitlab.howett.net";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required(VERSION 3.1)' \
      'cmake_minimum_required(VERSION 4.0)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libusb1
    libftdi1
  ];

  installPhase = ''
    runHook preInstall
    install -Dm555 src/ectool "$out/bin/ectool"
    runHook postInstall
  '';

  meta = {
    description = "EC-Tool adjusted for usage with framework embedded controller";
    homepage = "https://gitlab.howett.net/DHowett/ectool";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.mkg20001 ];
    platforms = lib.platforms.linux;
    mainProgram = "ectool";
  };
}
