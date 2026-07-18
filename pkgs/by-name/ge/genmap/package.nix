{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "genmap";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "cpockrandt";
    repo = "genmap";
    rev = "genmap-v${finalAttrs.version}";
    hash = "sha256-7sIKBRMNzyCrZ/c2nXkknb6a5YsXe6DRE2IFhp6AviY=";
    fetchSubmodules = true;
  };

  patches = [ ./gtest.patch ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 3.0.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  # disable benchmarks
  preConfigure = ''
    echo > benchmarks/CMakeLists.txt
  '';

  doCheck = true;

  nativeCheckInputs = [
    gtest
    which
  ];

  preCheck = "make genmap_algo_test";

  meta = {
    description = "Ultra-fast computation of genome mappability";
    homepage = "https://github.com/cpockrandt/genmap";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jbedo ];
    platforms = lib.platforms.unix;
    mainProgram = "genmap";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
