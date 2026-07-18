{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  cmake,
  libxslt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "genkfs";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "genkfs";
    rev = finalAttrs.version;
    sha256 = "0f50idd2bb73b05qjmwlirjnhr1bp43zhrgy6z949ab9a7hgaydp";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8.5)" "cmake_minimum_required(VERSION 3.10)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    libxslt.bin
    cmake
  ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Utility to write a KFS filesystem into a ROM file";
    homepage = "https://knightos.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
    mainProgram = "genkfs";
  };
})
