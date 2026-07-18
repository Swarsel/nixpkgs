{
  lib,
  stdenv,
  fetchFromGitHub,
  darwinMinVersionHook,
  freetype,
  lcms2,
  libjpeg,
  libpng,
  libtiff,
  meson,
  ninja,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "capypdf";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "jpakkane";
    repo = "capypdf";
    rev = finalAttrs.version;
    hash = "sha256-NJ4pjjbZ7z1bLqqt8ewA/5I/rBUXqy3wGwP29AGV5Vs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    freetype
    lcms2
    libpng
    libjpeg
    libtiff
    zlib
  ]
  # error: 'to_chars' is unavailable: introduced in macOS 13.3
  ++ lib.optional stdenv.hostPlatform.isDarwin (darwinMinVersionHook "13.3");

  meta = {
    description = "Fully color managed PDF generation library";
    homepage = "https://github.com/jpakkane/capypdf";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.all;
    mainProgram = "capypdf";
  };
})
