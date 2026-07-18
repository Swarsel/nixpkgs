{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  evdev,
  gitUpdater,
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

buildPythonPackage {
  pname = "pynputfix";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "AuroraWright";
    repo = "pynputfix";
    tag = "1.8.2";
    hash = "sha256-SKw745hh0G2NoWgUUjShyjiG2NYPd4iJlWx7IeGpW/4=";
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
    maintainers = with lib.maintainers; [ sigmanificient ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
