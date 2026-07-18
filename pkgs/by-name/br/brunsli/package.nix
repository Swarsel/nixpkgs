{
  lib,
  stdenv,
  fetchFromGitHub,
  brotli,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "brunsli";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "google";
    repo = "brunsli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZcrRz2xSoRepgG8KZYY/JzgONerItW0e6mH1PYsko98=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # unvendor brotli
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-/WPOG9OcEDj9ObBSXEM8Luq4Rix+PS2MvsYyHhK5mns=";
      url = "https://cgit.freebsd.org/ports/plain/graphics/brunsli/files/patch-CMakeLists.txt";
    })
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-+HXA9Tin+l2St7rRUEBM0AfhAjSoFxz8UX7hsg12aFg=";
      url = "https://cgit.freebsd.org/ports/plain/graphics/brunsli/files/patch-brunsli.cmake";
    })
  ];

  postPatch = ''
    rm -r third_party
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    rm -r build
  ''
  # fix build with cmake v4, should be removed in next release
  + ''
    substituteInPlace CMakeLists.txt \
      --replace-fail 'cmake_minimum_required(VERSION 3.1)' 'cmake_minimum_required(VERSION 3.10)'
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    brotli
  ];

  meta = {
    description = "Lossless JPEG repacking library";
    homepage = "https://github.com/google/brunsli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
