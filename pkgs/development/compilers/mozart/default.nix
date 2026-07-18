{
  lib,
  fetchurl,
  boost183,
  cmake,
  emacs,
  fetchpatch,
  gmp,
  jre_headless,
  llvmPackages,
  makeWrapper,
  tcl,
  tk,
  unzip,
}:

let
  stdenv = llvmPackages.stdenv;
  pname = "mozart2";
  version = "2.0.1";

  # This is a workaround to avoid using sbt.
  # I guess it is acceptable to fetch the bootstrapping compiler in binary form.
  bootcompiler = fetchurl {
    sha256 = "1hgh1a8hgzgr6781as4c4rc52m2wbazdlw3646s57c719g5xphjz";
    url = "https://github.com/layus/mozart2/releases/download/v2.0.0-beta.1/bootcompiler.jar";
  };
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/mozart/mozart2/releases/download/v${version}/${pname}-${version}-Source.zip";
    sha256 = "1mad9z5yzzix87cdb05lmif3960vngh180s2mb66cj5gwh5h9dll";
  };

  patches = [
    ./patch-limits.diff
    (fetchpatch {
      hash = "sha256-AnOrBnxoCxqis+RdCsq8EKBg//jcNHSOFYUvf7vh+Hc=";
      name = "remove-uses-of-deprecated-boost-apis.patch";
      url = "https://github.com/mozart/mozart2/commit/4256d3a9122e1cbb01400a1807bdee66088ff274.patch";
    })
  ];

  postPatch = ''
    substituteInPlace {vm,.}/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace vm/vm/test/gtest/{googletest,.}/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6.4)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace bootcompiler/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace {boosthost,opi,wish,stdlib}/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    makeWrapper
    unzip
  ];

  buildInputs = [
    boost183
    gmp
    emacs
    jre_headless
    tcl
    tk
  ];

  cmakeFlags = [
    "-DBoost_USE_STATIC_LIBS=OFF"
    "-DMOZART_BOOST_USE_STATIC_LIBS=OFF"
    # We are building with clang, as nix does not support having clang and
    # gcc together as compilers and we need clang for the sources generation.
    # However, clang emits tons of warnings about gcc's atomic-base library.
    "-DCMAKE_CXX_FLAGS=-Wno-braced-scalar-init"
  ];

  postConfigure = ''
    cp ${bootcompiler} bootcompiler/bootcompiler.jar
  '';

  fixupPhase = ''
    wrapProgram $out/bin/oz --set OZEMACS ${emacs}/bin/emacs
  '';

  meta = {
    description = "Open source implementation of Oz 3";
    homepage = "https://mozart.github.io";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      layus
      h7x4
    ];

    platforms = lib.platforms.all;
    # Trace/BPT trap: 5
    broken = stdenv.hostPlatform.isDarwin;
  };

}
