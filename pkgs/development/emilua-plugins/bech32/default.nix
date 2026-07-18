{
  lib,
  stdenv,
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
  meson,
  ninja,
  openssl,
  pkg-config,
  range-v3,
}:

stdenv.mkDerivation rec {
  pname = "emilua-bech32";
  version = "1.1.1";

  src = fetchFromGitLab {
    owner = "emilua";
    repo = "bech32";
    rev = "v${version}";
    hash = "sha256-DJUdwnX9jHKpVYRkP/UFYNefphbqCoUIjXLTNQ5umis=";
  };

  nativeBuildInputs = [
    gperf
    gawk
    pkg-config
    asciidoctor
    meson
    ninja
    cmake
  ];

  buildInputs = [
    emilua
    liburing
    fmt
    range-v3
    luajit_openresty
    openssl
    boost
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Bech32 codec for Emilua";
    homepage = "https://emilua.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ manipuladordedados ];
    platforms = lib.platforms.linux;
  };
}
