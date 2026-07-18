{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchFromGitLab,
  asciidoctor,
  boost,
  cmake,
  emilua,
  fmt,
  gawk,
  gitUpdater,
  gperf,
  liburing,
  luajit_openresty,
  openssl,
  pkg-config,
  zlib,
}:

let
  td-wrap = fetchFromGitHub {
    hash = "sha256-/TaPYy+FUOVhyocDZ13zwR07xbzp6g8c6xvAGVFLQvk=";
    owner = "tdlib";
    repo = "td";
    rev = "4041ecb535802ba1c55fcd11adf5d3ada41c2be7";
  };

  trial-circular-wrap = fetchFromGitHub {
    hash = "sha256-Xd8bX3z9PZWU17N9R95HXdj6qo9at5FBL/+PTVaJgkw=";
    owner = "breese";
    repo = "trial.protocol";
    rev = "79149f604a49b8dfec57857ca28aaf508069b669";
  };
in
stdenv.mkDerivation rec {
  pname = "emilua-tdlib";
  version = "1.0.4";

  src = fetchFromGitLab {
    owner = "emilua";
    repo = "tdlib";
    rev = "v${version}";
    hash = "sha256-dqbSECQLM664l2QrkEAfT65/NBI0ghj286dt7eaxcks=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.4 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)" \
      --replace-warn 'pkg_get_variable(EMILUA_PLUGINSDIR emilua pluginsdir)' 'set(EMILUA_PLUGINSDIR "${"$"}{CMAKE_INSTALL_PREFIX}/${emilua.sitePackages}")'
    substituteInPlace td/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0.2 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace td/td/generate/tl-parser/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    gperf
    gawk
    pkg-config
    asciidoctor
    cmake
    zlib
  ];

  buildInputs = [
    emilua
    liburing
    fmt
    luajit_openresty
    openssl
    boost
    td-wrap
    trial-circular-wrap
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Telegram Database Library bindings for Emilua";
    homepage = "https://emilua.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ manipuladordedados ];
    platforms = lib.platforms.linux;
  };
}
