{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  pyproject-hooks,
  pytestCheckHook,
  setuptools,
  testpath,
}:

buildPythonPackage rec {
  pname = "pyproject-hooks";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-HoWb1cQPrpRIZC3Yca30WeXiCEGG6NLCp5qCTJcNofg=";
    pname = "pyproject_hooks";
  };

  nativeBuildInputs = [ flit-core ];
  # We need to disable tests because this package is part of the bootstrap chain
  # and its test dependencies cannot be built yet when this is being built.
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pyproject_hooks" ];

  passthru.tests = {
    pytest = buildPythonPackage {
      inherit version;
      pname = "${pname}-pytest";

      nativeCheckInputs = [
        pyproject-hooks
        pytestCheckHook
        setuptools
        testpath
      ];

      disabledTests = [
        # fail to import setuptools
        "test_setup_py"
        "test_issue_104"
      ];

      dontBuild = true;
      dontInstall = true;
      pyproject = false;
    };
  };

  meta = {
    description = "Low-level library for calling build-backends in `pyproject.toml`-based project";
    homepage = "https://github.com/pypa/pyproject-hooks";
    changelog = "https://github.com/pypa/pyproject-hooks/blob/v${version}/docs/changelog.rst";
    license = lib.licenses.mit;
    teams = [ lib.teams.python ];
  };
}
