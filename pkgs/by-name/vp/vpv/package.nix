{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cargo,
  cmake,
  gdal,
  libGL,
  libjpeg,
  libpng,
  libtiff,
  libx11,
  octave,
  pkg-config,
  rustPlatform,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vpv";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "kidanger";
    repo = "vpv";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-eyfRMoocKEt0VezDRm5Tq7CjpEyfrcEb6WcUSO5M1Og=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.cargoSetupHook
    cargo
  ];

  buildInputs = [
    libGL
    libpng
    libtiff
    libjpeg
    libx11
    SDL2
    gdal
    octave
  ];

  cmakeFlags = [
    "-DUSE_GDAL=ON"
    "-DUSE_OCTAVE=ON"
    "-DVPV_VERSION=v${finalAttrs.version}"
    "-DBUILD_TESTING=ON"
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = finalAttrs.src;
    hash = "sha256-4XxhKzrfTulAnLvlzRCrxSxuR+Nl/ANqcUem0YqCQ0Y=";
    sourceRoot = "${finalAttrs.src.name}/src/fuzzy-finder";
  };

  cargoRoot = "src/fuzzy-finder";

  meta = {
    description = "Image viewer for image processing experts";
    homepage = "https://github.com/kidanger/vpv";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.kidanger ];
    mainProgram = "vpv";
    broken = stdenv.hostPlatform.isDarwin; # the CMake expects the SDL2::SDL2main target for darwin
  };
})
