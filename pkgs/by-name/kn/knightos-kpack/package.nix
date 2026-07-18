{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  cmake,
  libxslt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kpack";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "kpack";
    rev = finalAttrs.version;
    sha256 = "1l6bm2j45946i80qgwhrixg9sckazwb5x4051s76d3mapq9bara8";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8.5)" "cmake_minimum_required(VERSION 3.10)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    cmake
    libxslt.bin
  ];

  hardeningDisable = [ "fortify" ];

  meta = {
    description = "Tool to create or extract KnightOS packages";
    homepage = "https://knightos.org/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "kpack";
  };
})
