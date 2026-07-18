{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libpng,
  meson,
  ninja,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libspng";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "randy408";
    repo = "libspng";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-BiRuPQEKVJYYgfUsglIuxrBoJBFiQ0ygQmAFrVvCz4Q=";
  };

  outputs = [
    "out"
    "dev"
  ];

  # disable two tests broken after libpng update
  # https://github.com/randy408/libspng/issues/276
  postPatch = ''
    cat tests/images/meson.build | grep -v "'ch1n3p04'" | grep -v "'ch2n3p08'" > tests/images/meson.build-patched
    mv tests/images/meson.build-patched tests/images/meson.build
  '';

  strictDeps = true;

  nativeBuildInputs = [
    ninja
    meson
    pkg-config
  ];

  buildInputs = [
    zlib
    libpng
  ];

  mesonFlags = [
    # this is required to enable testing
    # https://github.com/randy408/libspng/blob/bc383951e9a6e04dbc0766f6737e873e0eedb40b/tests/README.md#testing
    "-Ddev_build=true"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    cmake
  ];

  mesonBuildType = "release";

  meta = {
    description = "Simple, modern libpng alternative";
    homepage = "https://libspng.org/";
    license = with lib.licenses; [ bsd2 ];
    maintainers = with lib.maintainers; [ humancalico ];
    platforms = lib.platforms.all;
  };
})
