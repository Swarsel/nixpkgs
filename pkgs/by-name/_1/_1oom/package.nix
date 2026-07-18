{
  lib,
  stdenv,
  SDL2,
  SDL2_mixer,
  allegro,
  autoreconfHook,
  fetchgit,
  gitUpdater,
  libsamplerate,
  libx11,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "1oom";
  version = "1.11.9";

  src = fetchgit {
    url = "https://git@git.sourcecraft.dev/fork1oom/1oom.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tU396z/7qpnhDEFqj/S55e/zeXa5jZFUi2VG3O6SJdY=";
  };

  outputs = [
    "out"
    "doc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    SDL2
  ];

  buildInputs = [
    allegro
    libsamplerate
    libx11
    SDL2
    SDL2_mixer
    readline
  ];

  postInstall = ''
    install -Dm644 -t $doc/share/doc/1oom \
      HACKING NEWS PHILOSOPHY README.md doc/*.txt
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Master of Orion (1993) game engine recreation; a more updated fork";
    homepage = "https://fork1oom.sourcecraft.site/";
    changelog = "https://sourcecraft.dev/fork1oom/1oom/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ marcin-serwin ];
    platforms = lib.platforms.linux;
  };
})
