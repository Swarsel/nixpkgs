{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  capstone,
  cmake,
  fetchpatch,
  flex,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "boomerang";
  version = "0.5.2";

  # NOTE: When bumping version beyond 0.5.2, you likely need to remove
  #       the cstdint.patch below. The patch does a fix that has already
  #       been done upstream but is not yet part of a release
  src = fetchFromGitHub {
    owner = "BoomerangDecompiler";
    repo = "boomerang";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PQJvEXxXH7Ip949FfuHbccZP4WlFrl3/pMRn9MFtzHY=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-941IydcV3mqj7AWvXTM6GePW5VgawEcL0wrBCXqeWvc=";
      name = "include-missing-cstdint.patch";
      url = "https://github.com/BoomerangDecompiler/boomerang/commit/3342b0eac6b7617d9913226c06c1470820593e74.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    bison
    flex
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    capstone
  ];

  # Boomerang usually compiles with -Werror but has not been updated for newer
  # compilers. Disable -Werror for now. Consider trying to remove this when
  # updating this derivation.
  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error" ];

  meta = {
    description = "General, open source, retargetable decompiler";
    homepage = "https://github.com/BoomerangDecompiler/boomerang";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
