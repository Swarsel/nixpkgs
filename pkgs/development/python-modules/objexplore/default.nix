{
  lib,
  fetchFromGitHub,
  blessed,
  buildPythonPackage,
  pandas,
  pytestCheckHook,
  rich,
  setuptools,
}:

buildPythonPackage {
  pname = "objexplore";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "kylepollina";
    repo = "objexplore";
    # tags for >1.5.4 are not availables on github
    # see: https://github.com/kylepollina/objexplore/issues/25
    rev = "3c2196d26e5a873eed0a694cddca66352ea7c81e";
    hash = "sha256-BgeuRRuvbB4p99mwCjNxm3hYEZuGua8x2GdoVssQ7eI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pandas
  ];

  build-system = [ setuptools ];

  dependencies = [
    blessed
    rich
  ];

  pyproject = true;

  pythonImportsCheck = [
    "objexplore"
    "objexplore.cached_object"
    "objexplore.explorer"
    "objexplore.filter"
    "objexplore.help_layout"
    "objexplore.objexplore"
    "objexplore.overview"
    "objexplore.stack"
    "objexplore.utils"
  ];

  pythonRelaxDeps = [
    "blessed"
    "rich"
  ];

  meta = {
    description = "Terminal UI to interactively inspect and explore Python objects";
    homepage = "https://github.com/kylepollina/objexplore";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pbsds
      sigmanificient
    ];
  };
}
