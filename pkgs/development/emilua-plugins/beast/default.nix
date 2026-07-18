{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoctor,
  emilua,
  gitUpdater,
  gperf,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "emilua_beast";
  version = "1.1.2";

  src = fetchFromGitLab {
    owner = "emilua";
    repo = "beast";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MASaZvhIVKmeBUcn/NjlBZ+xh+2RgwHBH2o08lklGa0=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [
    emilua
    asciidoctor
    gperf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Emilua bindings to Boost.Beast (a WebSocket library)";
    homepage = "https://gitlab.com/emilua/beast";
    license = lib.licenses.boost;

    maintainers = with lib.maintainers; [
      manipuladordedados
      lucasew
    ];

    platforms = lib.platforms.linux;
  };
})
