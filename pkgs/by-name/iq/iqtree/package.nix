{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  eigen,
  llvmPackages,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iqtree";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "iqtree";
    repo = "iqtree3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6Zy/u7YSCoqkLwq6xOoFMFDInGYREea1gS+PzSP4F8Q=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    eigen
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.openmp
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_CMAPLE" false) # tries to download googletest
  ];

  meta = {
    description = "Efficient and versatile phylogenomic software by maximum likelihood";
    homepage = "https://iqtree.github.io/";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ bzizou ];
    platforms = lib.platforms.linux;
    mainProgram = "iqtree3";
  };
})
