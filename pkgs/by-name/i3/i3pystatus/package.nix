{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  gobject-introspection,
  libnotify,
  libpulseaudio,
  python3Packages,
  unstableGitUpdater,
  writableTmpDirAsHomeHook,
  extraLibs ? [ ],
}:

python3Packages.buildPythonApplication rec {
  pname = "i3pystatus";
  # i3pystatus moved to rolling release:
  # https://github.com/enkore/i3pystatus/issues/584
  version = "3.35-unstable-2026-04-21";

  src = fetchFromGitHub {
    owner = "enkore";
    repo = "i3pystatus";
    rev = "045d5f09220ccec1146a220619ff80b1077206a4";
    hash = "sha256-K6sCII8qw0JLcMw5QVCY0RCu0O55MlEKFQXDY96V3NM=";
  };

  patches = [
    # absolutifies the path to the test data in buds test so it can be run from anywhere
    (fetchpatch2 {
      hash = "sha256-kSf2Nrypw8CCHC7acDkQXI27178HA3NJlyRWkHyYOGs=";
      # https://github.com/enkore/i3pystatus/pull/869
      url = "https://github.com/enkore/i3pystatus/commit/7a39c3527566411eb1b3e4f79191839ac4b0424e.patch";
    })
  ];

  postPatch = ''
    makeWrapperArgs+=(--set GI_TYPELIB_PATH "$GI_TYPELIB_PATH")
  '';

  nativeBuildInputs = [ gobject-introspection ];

  buildInputs = [
    libpulseaudio
    libnotify
  ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    python3Packages.mock
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    makeWrapper ${python3Packages.python.interpreter} $out/bin/${pname}-python-interpreter \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      ''${makeWrapperArgs[@]}
  '';

  build-system = [ python3Packages.setuptools ];

  dependencies =
    with python3Packages;
    [
      keyring
      colour
      netifaces
      psutil
      basiciw
      pygobject3
      requests
      dbus-python
    ]
    ++ extraLibs;

  # Upstream tests construct ElementCall via __new__ without Module.__init__, so
  # output/_output is never set (AttributeError on .output after run()).
  disabledTests = [
    "test_active_output"
    "test_empty_output"
    "test_error_output"
    "test_format_includes_room_alias"
  ];

  makeWrapperArgs = [
    # LC_TIME != C results in locale.Error: unsupported locale setting
    "--set"
    "LC_TIME"
    "C"
    "--suffix"
    "LD_LIBRARY_PATH"
    ":"
    "${lib.makeLibraryPath [ libpulseaudio ]}"
  ];

  pyproject = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Complete replacement for i3status";

    longDescription = ''
      i3pystatus is a growing collection of python scripts for status output compatible
      to i3status / i3bar of the i3 window manager.
    '';

    homepage = "https://github.com/enkore/i3pystatus";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      igsha
      lucasew
    ];

    platforms = lib.platforms.linux;
    mainProgram = "i3pystatus";
  };
}
