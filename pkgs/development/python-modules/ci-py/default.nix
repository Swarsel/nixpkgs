{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ci-py";
  version = "1.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-R/6bLsXOKGxiJDZUvvOuvLp3usEhfg698qvvgOwBXYk=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner', " ""
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "ci" ];

  meta = {
    description = "Library for working with Continuous Integration services";
    homepage = "https://github.com/grantmcconnaughey/ci.py";
    changelog = "https://github.com/grantmcconnaughey/ci.py/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
