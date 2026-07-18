{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  cmake,
  libxslt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kimg";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "kimg";
    rev = finalAttrs.version;
    sha256 = "040782k3rh2a5mhbfgr9gnbfis0wgxvi27vhfn7l35vrr12sw1l3";
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
    description = "Converts image formats supported by stb_image to the KnightOS image format";
    homepage = "https://knightos.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.all;
    mainProgram = "kimg";
  };
})
