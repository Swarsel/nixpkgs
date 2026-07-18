{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  freealut,
  gdk-pixbuf,
  libconfig,
  libnotify,
  libopus,
  libsodium,
  libtoxcore,
  libvpx,
  ncurses,
  openal,
  pkg-config,
  qrencode,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "toxic";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "TokTok";
    repo = "toxic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HNZKQPNwKLvtT/0EJlDaJnGI04gpJqXHKjd/85H3zH8=";
  };

  nativeBuildInputs = [
    pkg-config
    libconfig
  ];

  buildInputs = [
    libtoxcore
    libsodium
    ncurses
    curl
    gdk-pixbuf
    libnotify
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isAarch32) [
    openal
    libopus
    libvpx
    freealut
    qrencode
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = finalAttrs.src.meta // {
    description = "Reference CLI for Tox";
    homepage = "https://github.com/TokTok/toxic";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "toxic";
  };
})
