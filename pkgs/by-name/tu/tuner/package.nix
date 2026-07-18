{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  gst_all_1,
  gtk3,
  itstool,
  json-glib,
  libgee,
  libsoup_3,
  meson,
  ninja,
  pantheon,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tuner";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "louis77";
    repo = "tuner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i6I5NSwiS8FJuZaHbrXvUcumo9RZvEVPcfKOkHUXiLo=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    vala
    glib
    itstool
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    libsoup_3
    json-glib
    libgee
    glib
    gtk3
    pantheon.granite
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
  ];

  meta = {
    description = "App to discover and play internet radio stations";
    homepage = "https://github.com/louis77/tuner";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      abbe
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "com.github.louis77.tuner";
  };
})
