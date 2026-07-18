{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  gettext,
  gobject-introspection,
  gst_all_1,
  gtk3,
  help2man,
  keybinder3,
  libnotify,
  librsvg,
  makeWrapper,
  python3,
  streamripper,
  udisks,
  webkitgtk_4_1,
  wrapGAppsHook3,
  cdMetadataSupport ? false,
  deviceDetectionSupport ? true,
  documentationSupport ? true,
  iconTheme ? adwaita-icon-theme,
  ipythonSupport ? false,
  lastfmSupport ? false,
  lyricsManiaSupport ? false,
  multimediaKeySupport ? false,
  musicBrainzSupport ? false,
  notificationSupport ? true,
  podcastSupport ? false,
  scalableIconSupport ? true,
  streamripperSupport ? false,
  translationSupport ? true,
  wikipediaSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "exaile";
  version = "4.2.2";

  src = fetchFromGitHub {
    owner = "exaile";
    repo = "exaile";
    rev = finalAttrs.version;
    sha256 = "sha256-8q7OP9imTaoxqNgDOcVmvGSb5Sra0JtPOtZPo7zgkHM=";
  };

  nativeBuildInputs = [
    gobject-introspection
    makeWrapper
    wrapGAppsHook3
  ]
  ++ lib.optionals documentationSupport [
    help2man
    python3.pkgs.sphinx
    python3.pkgs.sphinx-rtd-theme
  ]
  ++ lib.optional translationSupport gettext;

  buildInputs = [
    iconTheme
    gtk3
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ])
  ++ (with python3.pkgs; [
    berkeleydb
    dbus-python
    mutagen
    pygobject3
    pycairo
    gst-python
  ])
  ++ lib.optional deviceDetectionSupport udisks
  ++ lib.optional notificationSupport libnotify
  ++ lib.optional scalableIconSupport librsvg
  ++ lib.optional ipythonSupport python3.pkgs.ipython
  ++ lib.optional cdMetadataSupport python3.pkgs.discid
  ++ lib.optional lastfmSupport python3.pkgs.pylast
  ++ lib.optional lyricsManiaSupport python3.pkgs.lxml
  ++ lib.optional multimediaKeySupport keybinder3
  ++ lib.optional (musicBrainzSupport || cdMetadataSupport) python3.pkgs.musicbrainzngs
  ++ lib.optional podcastSupport python3.pkgs.feedparser
  ++ lib.optional wikipediaSupport webkitgtk_4_1;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  doCheck = true;

  nativeCheckInputs = with python3.pkgs; [
    pytest
  ];

  preCheck = ''
    substituteInPlace Makefile --replace "PYTHONPATH=$(shell pwd)" "PYTHONPATH=$PYTHONPATH:$(shell pwd)"
    export PYTEST="py.test"
    export XDG_CACHE_HOME=$(mktemp -d)
  '';

  postInstall = ''
    wrapProgram $out/bin/exaile \
      --set PYTHONPATH $PYTHONPATH \
      --prefix PATH : ${
        lib.makeBinPath ([ python3 ] ++ lib.optionals streamripperSupport [ streamripper ])
      }
  '';

  meta = {
    description = "Music player with a simple interface and powerful music management capabilities";
    homepage = "https://www.exaile.org/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ryneeverett ];
    platforms = lib.platforms.all;
    mainProgram = "exaile";
  };
})
