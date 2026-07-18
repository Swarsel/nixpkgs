{
  lib,
  stdenv,
  fetchurl,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uchardet";
  version = "0.0.8";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/uchardet/releases/uchardet-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-6Xpgz8AKHBR6Z0sJe7FCKr2fp4otnOPz/cwueKNKxfA=";
  };

  outputs = [
    "bin"
    "out"
    "man"
    "dev"
  ];

  patches = [
    # Fix the build with CMake 4.
    (fetchpatch {
      hash = "sha256-WXIQEoIpT7b5vELAfQJFEt2hiYrlnGCjV7ILCmd9kqY=";
      name = "uchardet-cmake-4.patch";
      url = "https://gitlab.freedesktop.org/uchardet/uchardet/-/commit/6e163c978a7c13a6d3ff64a1e3dd4ba81d2d9e09.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];
  doCheck = !stdenv.hostPlatform.isi686; # tests fail on i686

  meta = {
    description = "Mozilla's Universal Charset Detector C/C++ API";
    homepage = "https://www.freedesktop.org/wiki/Software/uchardet/";
    license = lib.licenses.mpl11;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
    mainProgram = "uchardet";
  };
})
