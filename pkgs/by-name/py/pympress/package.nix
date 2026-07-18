{
  lib,
  stdenv,
  fetchFromGitHub,
  gobject-introspection,
  gst_all_1,
  gtk3,
  libcanberra-gtk3,
  poppler_gi,
  python3Packages,
  wrapGAppsHook3,
  withGstreamer ? stdenv.hostPlatform.isLinux,
  withVLC ? stdenv.hostPlatform.isLinux,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pympress";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "cimbali";
    repo = "pympress";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rIlYd5SMWYeqdMHyW3d1ggKnUMCJCDP5uw25d7zG2DU=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    poppler_gi
  ]
  ++ lib.optionals withGstreamer [
    libcanberra-gtk3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
    gst_all_1.gst-libav
  ];

  doCheck = false; # there are no tests

  build-system = with python3Packages; [
    setuptools
    babel
  ];

  dependencies =
    with python3Packages;
    [
      watchdog
      pycairo
      pygobject3
    ]
    ++ lib.optional withVLC python-vlc;

  pyproject = true;
  pythonImportsCheck = [ "pympress" ];

  meta = {
    description = "Simple yet powerful PDF reader designed for dual-screen presentations";
    homepage = "https://cimbali.github.io/pympress/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "pympress";
  };
})
