{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3,
  replaceVars,
  sqlite,
  which,
  writableTmpDirAsHomeHook,
}:

let
  inherit (python3.pkgs)
    buildPythonApplication
    setuptools
    cython
    apsw
    cryptography
    defusedxml
    google-auth
    google-auth-oauthlib
    pyfuse3
    requests
    trio
    pytest-trio
    pytestCheckHook
    python
    ;
in

buildPythonApplication (finalAttrs: {
  pname = "s3ql";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "s3ql";
    repo = "s3ql";
    tag = "s3ql-${finalAttrs.version}";
    hash = "sha256-SVB+VB508hGXvdHZo5lt09yssjjwHS1tsDU8M4j+swc=";
  };

  patches = [
    (replaceVars ./0001-setup.py-remove-self-reference.patch { inherit (finalAttrs) version; })
  ];

  nativeBuildInputs = [
    which
    cython
  ];

  preBuild = ''
    ${python.pythonOnBuildForHost.interpreter} ./setup.py build_cython build_ext --inplace
  '';

  nativeCheckInputs = [
    pytest-trio
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    apsw
    cryptography
    defusedxml
    google-auth
    google-auth-oauthlib
    pyfuse3
    requests
    sqlite
    trio
  ];

  # SSL EOF error doesn't match connection reset error. Seems fine.
  disabledTests = [ "test_aborted_write2" ];
  enabledTestPaths = [ "tests/" ];
  pyproject = true;
  pythonImportsCheck = [ "s3ql" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "s3ql-([0-9.]+)"
    ];
  };

  meta = {
    description = "Full-featured file system for online data storage";
    homepage = "https://github.com/s3ql/s3ql/";
    changelog = "https://github.com/s3ql/s3ql/releases/tag/s3ql-${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ rushmorem ];
    platforms = lib.platforms.linux;
  };
})
