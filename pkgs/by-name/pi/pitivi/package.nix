{
  lib,
  fetchurl,
  gettext,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gsound,
  gst_all_1,
  gtk3,
  hicolor-icon-theme,
  itstool,
  libnotify,
  libpeas,
  librsvg,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pitivi";
  version = "2023.03";

  src = fetchurl {
    url = "mirror://gnome/sources/pitivi/${lib.versions.major finalAttrs.version}/pitivi-${finalAttrs.version}.tar.xz";
    sha256 = "PX1OFEeavqMPvF613BKgxwErxqW2huw6mQxo8YpBS/M=";
  };

  patches = [
    # By default, the build picks up environment variables like PYTHONPATH
    # and saves them to the generated binary. This would make the build-time
    # dependencies part of the closure so we remove it.
    ./prevent-closure-contamination.patch
  ];

  postPatch = ''
    patchShebangs ./getenvvar.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    itstool
    python3
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libpeas
    librsvg
    gsound
    gsettings-desktop-schemas
    libnotify
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-editing-services
    gst-plugins-base
    (gst-plugins-good.override { gtkSupport = true; })
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
    gst-devtools
  ]);

  preFixup = ''
    gappsWrapperArgs+=(
      # The icon theme is hardcoded.
      --prefix XDG_DATA_DIRS : "${hicolor-icon-theme}/share"
    )
  '';

  pyproject = false;

  pythonPath = with python3.pkgs; [
    pygobject3
    gst-python
    numpy
    pycairo
    matplotlib
    librosa
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "pitivi";
      versionPolicy = "none"; # we are using dev version, since the stable one is too old
    };
  };

  meta = {
    description = "Non-Linear video editor utilizing the power of GStreamer";

    longDescription = ''
      Pitivi is a video editor built upon the GStreamer Editing Services.
      It aims to be an intuitive and flexible application
      that can appeal to newbies and professionals alike.
    '';

    homepage = "http://pitivi.org/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "pitivi";
  };
})
