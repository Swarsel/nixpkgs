{
  lib,
  fetchurl,
  buildPythonPackage,
  dbus-python,
  directoryListingUpdater,
  enlightenment,
  packaging,
  pkg-config,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

# Should be bumped along with EFL!

buildPythonPackage rec {
  pname = "python-efl";
  version = "1.26.1";

  src = fetchurl {
    url = "http://download.enlightenment.org/rel/bindings/python/python-efl-${version}.tar.xz";
    hash = "sha256-3Ns5fhIHihnpDYDnxvPP00WIZL/o1UWLzgNott4GKNc=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ enlightenment.efl ];

  preConfigure = ''
    NIX_CFLAGS_COMPILE="$(pkg-config --cflags efl evas) $NIX_CFLAGS_COMPILE"
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # make sure we load the library from $out instead of the cwd
    # because cwd doesn't contain the built extensions
    rm -r efl/

    patchShebangs tests/ecore/exe_helper.sh

    # use the new name instead of the removed alias
    substituteInPlace tests/evas/test_01_rect.py \
      --replace-fail ".assert_(" ".assertTrue("
  '';

  build-system = [
    packaging
    setuptools
  ];

  dependencies = [
    dbus-python
  ];

  # As of 1.26.1, native extensions fail to build with python 3.13+
  disabled = pythonAtLeast "3.13";

  disabledTestPaths = [
    "tests/dbus/test_01_basics.py" # needs dbus daemon
    "tests/ecore/test_09_file_download.py" # uses network
    "tests/ecore/test_11_con.py" # uses network
    "tests/elementary/test_02_image_icon.py" # RuntimeWarning: Setting standard icon failed
  ];

  enabledTestPaths = [ "tests/" ];
  pyproject = true;
  passthru.updateScript = directoryListingUpdater { };

  meta = {
    description = "Python bindings for Enlightenment Foundation Libraries";
    homepage = "https://github.com/DaveMDS/python-efl";

    license = with lib.licenses; [
      gpl3
      lgpl3
    ];

    maintainers = with lib.maintainers; [
      matejc
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.enlightenment ];
  };
}
