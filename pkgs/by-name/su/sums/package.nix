{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  libadwaita,
  meson,
  mpfr,
  ninja,
  pkg-config,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sums";
  version = "0.16";

  src = fetchFromGitLab {
    owner = "leesonwai";
    repo = "sums";
    tag = finalAttrs.version;
    hash = "sha256-X+AMUH8nJli0Um1bH0gDGLnfHGknqea3DZxH+tdTEr8=";
  };

  postPatch = ''
    # tests target has racy config.h dep
    substituteInPlace meson.build \
      --replace-fail "subdir('tests')" ""
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    mpfr
  ];

  meta = {
    description = "Simple GTK postfix calculator for GNOME";
    homepage = "https://gitlab.com/leesonwai/sums";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "sums";
  };
})
