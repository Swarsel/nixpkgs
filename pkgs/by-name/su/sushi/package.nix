{
  lib,
  stdenv,
  fetchurl,
  evince,
  gdk-pixbuf,
  gettext,
  gjs,
  glib,
  gnome,
  gobject-introspection,
  gst_all_1,
  gtk3,
  gtksourceview4,
  harfbuzz,
  icu,
  libepoxy,
  librsvg,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sushi";
  version = "50.0";

  src = fetchurl {
    url = "mirror://gnome/sources/sushi/${lib.versions.major finalAttrs.version}/sushi-${finalAttrs.version}.tar.xz";
    hash = "sha256-qyUXeQjVzMWFaHaageubTzIwZ4bmxzYYGT6/YaEn7gA=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gettext
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    evince
    icu
    harfbuzz
    gjs
    gtksourceview4
    gdk-pixbuf
    librsvg
    libsoup_3
    webkitgtk_4_1
    libepoxy
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ];

  # See https://github.com/NixOS/nixpkgs/issues/31168
  postInstall = ''
    for file in $out/libexec/org.gnome.NautilusPreviewer
    do
      sed -e $"2iimports.package._findEffectiveEntryPointName = () => \'$(basename $file)\' " \
        -i $file
    done
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "sushi";
    };
  };

  meta = {
    description = "Quick previewer for Nautilus";
    homepage = "https://gitlab.gnome.org/GNOME/sushi";
    changelog = "https://gitlab.gnome.org/GNOME/sushi/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "sushi";
    teams = [ lib.teams.gnome ];
  };
})
