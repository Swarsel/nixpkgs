{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  cmake,
  libxslt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mktiupgrade";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "KnightOS";
    repo = "mktiupgrade";
    rev = finalAttrs.version;
    sha256 = "15y3rxvv7ipgc80wrvrpksxzdyqr21ywysc9hg6s7d3w8lqdq8dm";
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
    description = "Makes TI calculator upgrade files from ROM dumps";
    homepage = "https://knightos.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
    mainProgram = "mktiupgrade";
  };
})
