{
  lib,
  stdenv,
  fetchFromGitLab,
  # tests
  beautifulsoup4,
  buildPythonPackage,
  # dependencies
  flask,
  importlib-metadata,
  ndjson,
  pytest-flask,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  # build-system
  setuptools,
  setuptools-scm,
  swh-auth,
  swh-core,
  swh-model,
  swh-web-client,
  types-beautifulsoup4,
  types-pyyaml,
  types-requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-scanner";
  version = "0.8.3";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-scanner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-baUUuYFapBD7iuDaDP8CSR9f4glVZcS5qBpZddVf7z8=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  nativeCheckInputs = [
    beautifulsoup4
    pytest-flask
    pytest-mock
    pytestCheckHook
    swh-core
    swh-model
    types-beautifulsoup4
    types-pyyaml
    types-requests
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    flask
    importlib-metadata
    ndjson
    requests
    swh-auth
    swh-core
    swh-model
    swh-web-client
  ];

  disabledTestPaths = [
    # pytestRemoveBytecodePhase fails with: "error (ignored): error: opening directory "/tmp/nix-build-python3.12-swh-scanner-0.8.3.drv-5/build/pytest-of-nixbld/pytest-0/test_randomdir_policy_info_cal0/big-directory/dir/dir/dir/ ......"
    "swh/scanner/tests/test_policy.py"
    # TypeError: CliRunner.__init__() got an unexpected keyword argument 'mix_stderr'
    "swh/scanner/tests/test_cli.py"
  ];

  disabledTests =
    lib.optionals (pythonAtLeast "3.14") [
      # _pickle.PicklingError: Can't pickle local object
      "test_add_provenance_with_release"
      "test_add_provenance_with_revision"
      "test_scanner_result"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # Failed: Failed to start the server after 5 seconds.
      "test_add_provenance_with_release"
      "test_add_provenance_with_revision"
      "test_scanner_result"
    ];

  pyproject = true;
  pythonImportsCheck = [ "swh.scanner" ];

  meta = {
    description = "Source code scanner to analyze code bases and compare them with source code artifacts archived by Software Heritage";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-scanner";
    changelog = "https://gitlab.softwareheritage.org/swh/devel/swh-scanner/-/tags/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
