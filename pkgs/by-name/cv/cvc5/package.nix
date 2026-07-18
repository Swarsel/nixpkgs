{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cadical,
  cmake,
  flex,
  gmp,
  gtest,
  jdk,
  libpoly,
  pkg-config,
  python3,
  symfpu,
  cadical' ? cadical.override { version = "2.1.3"; },
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cvc5";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "cvc5";
    repo = "cvc5";
    tag = "cvc5-${finalAttrs.version}";
    hash = "sha256-PZcOArSTyJzyd2DKT8K0aFC4RlVXgTCnkoU0f08KPfY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    flex
    (python3.withPackages (
      ps: with ps; [
        pyparsing
        tomli
      ]
    ))
  ];

  buildInputs = [
    cadical'.dev
    symfpu
    gmp
    gtest
    boost
    jdk
    libpoly
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=1"
    "-DUSE_POLY=ON"
  ];

  preConfigure = ''
    patchShebangs ./src/
  '';

  doCheck = true;
  __structuredAttrs = true;
  cmakeBuildType = "Production";

  meta = {
    description = "High-performance theorem prover and SMT solver";
    homepage = "https://cvc5.github.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ shadaj ];
    platforms = lib.platforms.unix;
    mainProgram = "cvc5";
  };
})
