{
  lib,
  stdenv,
  fetchFromGitHub,
  antlr3_4,
  boost,
  cln,
  cmake,
  git,
  gmp,
  jdk,
  libantlr3c,
  pkg-config,
  python3,
  readline,
  swig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cvc4";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "cvc4";
    repo = "cvc4-archived";
    rev = finalAttrs.version;
    sha256 = "1rhs4pvzaa1wk00czrczp58b2cxfghpsnq534m0l3snnya2958jp";
  };

  patches = [
    ./cvc4-bash-patsub-replacement.patch
  ];

  postPatch = ''
        # Fix missing size_t declarations by adding after pragma once or include guards
        sed -i '/#pragma once/a\
    #include <cstddef>' src/expr/emptyset.h || sed -i '1i\
    #include <cstddef>' src/expr/emptyset.h

        sed -i '/#define CVC4__EXPR__EXPR_IOMANIP_H/a\
    #include <cstddef>' src/expr/expr_iomanip.h

        sed -i '/#define CVC4__UTIL__REGEXP_H/a\
    #include <cstddef>' src/util/regexp.h

    # Fix CMake 4 build
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 3.2)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    gmp
    git
    python3.pkgs.toml
    readline
    swig
    libantlr3c
    antlr3_4
    boost
    jdk
    python3
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ cln ];

  configureFlags = [
    "--enable-language-bindings=c,c++,java"
    "--enable-gpl"
    "--with-readline"
    "--with-boost=${boost.dev}"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ "--with-cln" ];

  preConfigure = ''
    patchShebangs ./src/
  '';

  cmakeBuildType = "Production";

  prePatch = ''
    patch -p1 -i ${./minisat-fenv.patch} -d src/prop/minisat
    patch -p1 -i ${./minisat-fenv.patch} -d src/prop/bvminisat
  '';

  meta = {
    description = "High-performance theorem prover and SMT solver";
    homepage = "http://cvc4.cs.stanford.edu/web/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      vbgl
      thoughtpolice
    ];

    platforms = lib.platforms.unix;
    mainProgram = "cvc4";
  };
})
