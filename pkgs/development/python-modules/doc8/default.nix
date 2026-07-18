{
  lib,
  buildPythonPackage,
  chardet,
  docutils,
  fetchPypi,
  pbr,
  pygments,
  pytestCheckHook,
  restructuredtext-lint,
  setuptools-scm,
  stevedore,
  wheel,
}:

buildPythonPackage rec {
  pname = "doc8";
  version = "2.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-EmetMnWJcfvPmRRCQXo5Nce8nlJVDnNiLg5WulXqHUA=";
  };

  buildInputs = [ pbr ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools-scm
    wheel
  ];

  dependencies = [
    docutils
    chardet
    stevedore
    restructuredtext-lint
    pygments
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::PendingDeprecationWarning"
  ];

  pythonImportsCheck = [ "doc8" ];
  pythonRelaxDeps = [ "docutils" ];

  meta = {
    description = "Style checker for Sphinx (or other) RST documentation";
    homepage = "https://github.com/pycqa/doc8";
    changelog = "https://github.com/PyCQA/doc8/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "doc8";
  };
}
