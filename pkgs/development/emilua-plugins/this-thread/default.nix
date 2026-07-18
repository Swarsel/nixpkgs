{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
  boost,
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
  pname = "emilua-this-thread";
  version = "1.0.3";

  src = fetchFromGitLab {
    owner = "emilua";
    repo = "this-thread";
    rev = "v${version}";
    hash = "sha256-3f2nB6KwNka0P7jnvMZF2+ExuTmICj2NswmRWB+YDKo=";
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
    luajit_openresty
    openssl
    boost
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Access C++'s this_thread from Lua";
    homepage = "https://emilua.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ manipuladordedados ];
    platforms = lib.platforms.linux;
  };
}
