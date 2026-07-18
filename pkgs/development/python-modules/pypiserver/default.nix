{
  lib,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  distutils,
  importlib-resources,
  passlib,
  pip,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  twine,
  watchdog,
  webtest,
}:

buildPythonPackage rec {
  pname = "pypiserver";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "pypiserver";
    repo = "pypiserver";
    tag = "v${version}";
    hash = "sha256-nqoAT3g32srJ0c3sGNFQBznLsnymDPUfL7kcON+BP0k=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"setuptools-git>=0.3",' ""
  '';

  nativeCheckInputs = [
    pip
    pytestCheckHook
    setuptools
    twine
    webtest
    build
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export HOME=$TMPDIR
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    distutils
    pip
  ]
  ++ lib.optionals (pythonOlder "3.12") [ importlib-resources ];

  disabledTestPaths = [
    # Test requires docker service running
    "docker/test_docker.py"
  ];

  disabledTests = [
    # Fails to install the package
    "test_hash_algos"
    "test_pip_install_authed_succeeds"
    "test_pip_install_open_succeeds"
  ];

  optional-dependencies = {
    cache = [ watchdog ];
    passlib = [ passlib ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pypiserver" ];

  # Tests need these permissions in order to use the FSEvents API on macOS.
  sandboxProfile = ''
    (allow mach-lookup (global-name "com.apple.FSEvents"))
  '';

  meta = {
    description = "Minimal PyPI server for use with pip/easy_install";
    homepage = "https://github.com/pypiserver/pypiserver";
    changelog = "https://github.com/pypiserver/pypiserver/releases/tag/v${version}";

    license = with lib.licenses; [
      mit
      zlib
    ];

    maintainers = with lib.maintainers; [ austinbutler ];
    mainProgram = "pypi-server";
  };
}
