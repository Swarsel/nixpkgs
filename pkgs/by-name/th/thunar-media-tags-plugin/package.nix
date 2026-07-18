{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libxfce4util,
  meson,
  ninja,
  pkg-config,
  taglib,
  thunar,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thunar-media-tags-plugin";
  version = "0.6.0";

  src = fetchFromGitLab {
    owner = "thunar-plugins";
    repo = "thunar-media-tags-plugin";
    tag = "thunar-media-tags-plugin-${finalAttrs.version}";
    hash = "sha256-qEoBga+JSxpByOjqhOspjYknF0p74oXZnpoDz2MSBOA=";
    domain = "gitlab.xfce.org";
  };

  patches = [
    # meson-build: Fix typo libxfce4ui -> libxfce4util
    # https://gitlab.xfce.org/thunar-plugins/thunar-media-tags-plugin/-/merge_requests/14
    (fetchpatch {
      hash = "sha256-ASVknxEiGOWbE82hVlgEAOqE+8TknAh/ULQg55mfs9o=";
      url = "https://gitlab.xfce.org/thunar-plugins/thunar-media-tags-plugin/-/commit/4e19a56deeeefa6d913f7b15a12b30a5d99119d4.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    thunar
    glib
    gtk3
    libxfce4util
    taglib
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "thunar-media-tags-plugin-"; };

  meta = {
    description = "Thunar plugin providing tagging and renaming features for media files";
    homepage = "https://gitlab.xfce.org/thunar-plugins/thunar-media-tags-plugin";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ncfavier ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
