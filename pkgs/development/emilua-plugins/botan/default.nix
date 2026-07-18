{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
  boost,
  botan3,
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
}:

stdenv.mkDerivation rec {
  pname = "emilua-botan";
  version = "1.2.1";

  src = fetchFromGitLab {
    owner = "emilua";
    repo = "botan";
    rev = "v${version}";
    hash = "sha256-b5yOkjXKnJBQWSKCqiHJcznH1QOmTVgBbS5IwP3VTXA=";
  };

  nativeBuildInputs = [
    gperf
    gawk
    pkg-config
    asciidoctor
    meson
    ninja
  ];

  buildInputs = [
    emilua
    liburing
    fmt
    botan3
    luajit_openresty
    openssl
    boost
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Securely clears secrets from memory in Emilua";
    homepage = "https://emilua.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ manipuladordedados ];
    platforms = lib.platforms.linux;
  };
}
