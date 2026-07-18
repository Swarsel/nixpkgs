{
  lib,
  stdenv,
  fetchFromGitHub,
  glib-networking,
  gobject-introspection,
  gst_all_1,
  nixosTests,
  pipewire,
  pythonPackages,
  wrapGAppsNoGuiHook,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy";
  version = "3.4.2";

  src = fetchFromGitHub {
    owner = "mopidy";
    repo = "mopidy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2OFav2HaQq/RphmZxLyL1n3suwzt1Y/d4h33EdbStjk=";
  };

  nativeBuildInputs = [ wrapGAppsNoGuiHook ];

  buildInputs =
    with gst_all_1;
    [
      glib-networking
      gst-plugins-bad
      gst-plugins-base
      gst-plugins-good
      gst-plugins-ugly
      gst-plugins-rs
      gst-libav
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ pipewire ];

  propagatedBuildInputs = [ gobject-introspection ];
  # There are no tests
  doCheck = false;
  build-system = [ pythonPackages.setuptools ];

  dependencies =
    with pythonPackages;
    [
      gst-python
      pygobject3
      pykka
      requests
      setuptools
      tornado
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ dbus-python ];

  propagatedNativeBuildInputs = [ gobject-introspection ];
  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) mopidy;
  };

  meta = {
    description = "Extensible music server that plays music from local disk, Spotify, SoundCloud, and more";
    homepage = "https://www.mopidy.com/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.fpletz ];
    mainProgram = "mopidy";
    hydraPlatforms = [ ];
  };
})
