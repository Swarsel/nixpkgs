{
  lib,
  fetchFromGitHub,
  fdk-aac-encoder,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  intltool,
  python3Packages,
  wrapGAppsHook3,
  xvfb-run,
  # Optional due to unfree license.
  faacSupport ? false,
}:

python3Packages.buildPythonApplication rec {
  pname = "soundconverter";
  version = "4.0.6";

  src = fetchFromGitHub {
    owner = "kassoulet";
    repo = "soundconverter";
    tag = version;
    hash = "sha256-qa8VBPpB27hw+mYXGi6I35dxjJAOucH/SevxqKeu6o0=";
  };

  postPatch = ''
    substituteInPlace  bin/soundconverter --replace \
      "DATA_PATH = os.path.join(SOURCE_PATH, 'data')" \
      "DATA_PATH = '$out/share/soundconverter'"
  '';

  # Necessary to set GDK_PIXBUF_MODULE_FILE.
  strictDeps = false;

  nativeBuildInputs = [
    intltool
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    fdk-aac-encoder
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    (gst_all_1.gst-plugins-bad.override { inherit faacSupport; })
  ];

  nativeCheckInputs = [ xvfb-run ];

  preCheck =
    let
      self = {
        name = "${pname}-${version}";
        outPath = "$out";
      };
      xdgPaths = lib.concatMapStringsSep ":" glib.getSchemaDataDirPath;
    in
    ''
      export HOME=$TMPDIR
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:${
        xdgPaths [
          gtk3
          gsettings-desktop-schemas
          self
        ]
      }
      # FIXME: Fails due to weird Gio.file_parse_name() behavior.
      sed -i '49 a\    @unittest.skip("Gio.file_parse_name issues")' tests/testcases/names.py
    ''
    + lib.optionalString (!faacSupport) ''
      substituteInPlace tests/testcases/gui_integration.py --replace \
        "for encoder in ['fdkaacenc', 'faac', 'avenc_aac']:" \
        "for encoder in ['fdkaacenc', 'avenc_aac']:"
    '';

  checkPhase = ''
    runHook preCheck
    xvfb-run python tests/test.py
    runHook postCheck
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    gst-python
    distutils-extra
    setuptools
    pygobject3
  ];

  dontWrapGApps = true;
  format = "setuptools";

  meta = {
    description = "Leading audio file converter for the GNOME Desktop";

    longDescription = ''
      SoundConverter reads anything the GStreamer library can read,
      and writes WAV, FLAC, MP3, AAC and Ogg Vorbis files.
      Uses Python and GTK+ GUI toolkit, and runs on X Window System.
    '';

    homepage = "https://soundconverter.org/";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      jakubgs
      aleksana
    ];

    platforms = lib.platforms.linux;
    mainProgram = "soundconverter";
  };
}
