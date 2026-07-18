{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  buildPackages,
  cmake,
  libxslt,
}:

let
  isCrossCompiling = stdenv.hostPlatform != stdenv.buildPlatform;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "scas";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "scas";
    rev = finalAttrs.version;
    sha256 = "sha256-JGQE+orVDKKJsTt8sIjPX+3yhpZkujISroQ6g19+MzU=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "TARGETS scas scdump scwrap" "TARGETS scas scdump scwrap generate_tables" \
      --replace-fail "cmake_minimum_required(VERSION 2.8.5)" "cmake_minimum_required(VERSION 3.10)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    libxslt.bin
    cmake
  ];

  cmakeFlags = [ "-DSCAS_LIBRARY=1" ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.cc.isClang [
      "-Wno-error=implicit-function-declaration"
    ]
  );

  postInstall = ''
    cd ..
    make DESTDIR=$out install_man
  '';

  depsBuildBuild = lib.optionals isCrossCompiling [ buildPackages.knightos-scas ];

  meta = {
    description = "Assembler and linker for the Z80";
    homepage = "https://knightos.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
  };
})
