{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cx-logging,
  distutils,
  filelock,
  # tests
  pytest-mock,
  pytestCheckHook,
  # build-system
  setuptools,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "freeze-core";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "marcelotduarte";
    repo = "freeze-core";
    tag = finalAttrs.version;
    hash = "sha256-88AODiBvIPq51l1rU+mshGknQk+3qoiR7I5mfNfNv50=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools~=82.0" "setuptools"
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    cx-logging
  ];

  dependencies = [
    distutils # needed to compile
    filelock
  ];

  pyproject = true;

  pythonImportsCheck = [
    "freeze_core"
  ];

  meta = {
    description = "Core dependency for cx_Freeze";
    homepage = "https://github.com/marcelotduarte/freeze-core";
    changelog = "https://github.com/marcelotduarte/freeze-core/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
