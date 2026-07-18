{
  lib,
  boltons,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "face";
  version = "24.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YR4poBrFlw8Ad/nFd+dG1IwIJYi0EbM6DdVcTYcpSfY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ boltons ];

  disabledTests = [
    # Assertion error as we take the Python release into account
    "test_search_prs_basic"
    "test_module_shortcut"
  ];

  pyproject = true;
  pythonImportsCheck = [ "face" ];

  meta = {
    description = "Command-line interface parser and framework";

    longDescription = ''
      A command-line interface parser and framework, friendly for
      users, full-featured for developers.
    '';

    homepage = "https://github.com/mahmoud/face";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ twey ];
  };
}
