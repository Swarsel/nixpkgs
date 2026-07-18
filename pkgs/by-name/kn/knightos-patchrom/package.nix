{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  cmake,
  libxslt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "patchrom";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "patchrom";
    rev = finalAttrs.version;
    sha256 = "0yc4q7n3k7k6rx3cxq5ddd5r0la8gw1287a74kql6gwkxjq0jmcv";
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

  hardeningDisable = [ "format" ];

  meta = {
    description = "Patches jumptables into TI calculator ROM files and generates an include file";
    homepage = "https://knightos.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "patchrom";
  };
})
