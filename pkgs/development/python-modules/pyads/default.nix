{
  lib,
  stdenv,
  fetchFromGitHub,
  adslib,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyads";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "stlehmann";
    repo = "pyads";
    tag = version;
    hash = "sha256-v36T8CEEgKvw5XRg0WPTUoGMa9uKDrea/9MJY3+WsP8=";
  };

  postPatch = ''
    # Skip compilation of bundled adslib - we provide it as a separate nix package
    substituteInPlace setup.py \
      --replace-fail \
        'return sys.platform.startswith("linux") or sys.platform.startswith("darwin")' \
        'return False'

    # Load adslib from nix store instead of searching sys.path
    substituteInPlace src/pyads/pyads_ex.py \
      --replace-fail \
        'ctypes.CDLL(adslib_path)' \
        'ctypes.CDLL("${lib.getLib adslib}/lib/adslib.so")'
  '';

  buildInputs = [ adslib ];
  # Test suite has port reuse races and UDP timing issues on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # Race over UDP 48899 (no SO_REUSEADDR), occasionally segfaulting on shutdown
    "test_correct_route"
    "test_get_ams"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyads" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^(\\d+\\.\\d+\\.\\d+)$"
    ];
  };

  meta = {
    description = "Python wrapper for TwinCAT ADS library";
    homepage = "https://github.com/MrLeeh/pyads";
    changelog = "https://github.com/stlehmann/pyads/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
