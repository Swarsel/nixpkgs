{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "restructuredtext-lint";
  version = "2.0.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3SUgm54Lcmkp2DBjOfr3I3NKMTfbOCvPJylPoYprxSs=";
    pname = "restructuredtext_lint";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ docutils ];
  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "restructuredtext_lint/test/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "restructuredtext_lint" ];

  meta = {
    description = "reStructuredText linter";
    homepage = "https://github.com/twolfson/restructuredtext-lint";
    changelog = "https://github.com/twolfson/restructuredtext-lint/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.unlicense;
    mainProgram = "rst-lint";
  };
}
