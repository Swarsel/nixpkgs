{
  lib,
  build,
  buildPythonPackage,
  fetchPypi,
  gitMinimal,
  hatchling,
  mercurial,
  packaging,
  pydantic,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "versioningit";
  version = "3.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uRrX1z5z0hIg5pVA8gIT8rcpofmzXATp4Tfq8o0iFNo=";
  };

  postPatch = ''
    substituteInPlace tox.ini \
      --replace-fail "ignore:.*No source for code:coverage.exceptions.CoverageWarning" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    build
    hatchling
    pydantic
    pytest-cov-stub
    pytest-mock
    setuptools
    gitMinimal
    mercurial
  ];

  build-system = [ hatchling ];

  dependencies = [
    packaging
  ];

  disabledTests = [
    # wants to write to the Nix store
    "test_editable_mode"
    # network access
    "test_install_from_git_url"
    "test_install_from_zip_url"
  ];

  pyproject = true;
  pythonImportsCheck = [ "versioningit" ];

  meta = {
    description = "Setuptools plugin for determining package version from VCS";
    homepage = "https://github.com/jwodder/versioningit";
    changelog = "https://versioningit.readthedocs.io/en/latest/changelog.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ DeeUnderscore ];
    mainProgram = "versioningit";
  };
}
