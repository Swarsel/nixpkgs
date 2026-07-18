{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  evdev,
  gitUpdater,
  pyobjc-framework-ApplicationServices,
  pyobjc-framework-Quartz,
  # dependencies
  python-xlib,
  # build-system
  setuptools,
  setuptools-lint,
  six,
  sphinx,
  # tests
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pynput";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "moses-palmer";
    repo = "pynput";
    tag = "v${version}";
    hash = "sha256-LoolcMYzurJrR7HR1qDO+dvLwP1l9P3+QOzI7uwLdso=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'sphinx >=1.3.1'," "" \
      --replace-fail "'twine >=4.0']" "]"
  '';

  nativeBuildInputs = [
    setuptools
    setuptools-lint
    sphinx
  ];

  propagatedBuildInputs = [
    six
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    evdev
    python-xlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # the darwin backend imports HIServices (ApplicationServices) and Quartz
    pyobjc-framework-ApplicationServices
    pyobjc-framework-Quartz
  ];

  doCheck = false; # requires running X server
  nativeCheckInputs = [ unittestCheckHook ];
  pyproject = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Library to control and monitor input devices";
    homepage = "https://github.com/moses-palmer/pynput";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ nickhu ];
  };
}
