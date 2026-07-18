{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gklib,
  llvmPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "metis";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "KarypisLab";
    repo = "METIS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eddLR6DvZ+2LeR0DkknN6zzRvnW+hLN2qeI+ETUPcac=";
  };

  patches = [
    # fix gklib link error
    (fetchpatch {
      hash = "sha256-uoXMi6pMs5VrzUmjsLlQYFLob1A8NAt9CbFi8qhQXVQ=";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/sci-libs/metis/files/metis-5.2.1-add-gklib-as-required.patch?id=c78ecbd3fdf9b33e307023baf0de12c4448dd283";
    })
    # cmake 4 compatibility
    (fetchpatch {
      hash = "sha256-vX1GSZOLDxO9IIAQmNa9ADreEWSHCU9eF9L8qiSHye8=";
      name = "metis-cmake-minimum-required-bump.patch";
      url = "https://github.com/KarypisLab/METIS/commit/350931887dfc00c2e3cb7551c5abf30e0297126a.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ gklib ] ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  cmakeFlags = [
    (lib.cmakeBool "OPENMP" true)
    (lib.cmakeBool "SHARED" (!stdenv.hostPlatform.isStatic))
  ];

  preConfigure = ''
    make config
  '';

  meta = {
    description = "Serial graph partitioning and fill-reducing matrix ordering";
    homepage = "https://github.com/KarypisLab/METIS";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qbisi ];
    platforms = lib.platforms.all;
  };
})
