{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream-glib,
  desktop-file-utils,
  glib,
  glib-networking,
  gst_all_1,
  gtk3,
  keybinder3,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goodvibes";
  version = "0.8.4";

  src = fetchFromGitLab {
    owner = "goodvibes";
    repo = "goodvibes";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KEB6qSbsi+Q8NRHx5O9xOViIhuBDZceto53sWJv7As8=";
  };

  postPatch = ''
    patchShebangs scripts
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    appstream-glib
    desktop-file-utils
  ];

  buildInputs = [
    glib
    # for libsoup TLS support
    glib-networking
    gtk3
    libsoup_3
    keybinder3
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ]);

  meta = {
    description = "Lightweight internet radio player";
    homepage = "https://gitlab.com/goodvibes/goodvibes";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.linux;
  };
})
