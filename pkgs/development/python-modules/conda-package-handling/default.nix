{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  conda-package-streaming,
  setuptools,
}:
buildPythonPackage rec {
  pname = "conda-package-handling";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "conda";
    repo = "conda-package-handling";
    tag = version;
    hash = "sha256-AvuxHl3gUH7zIyMhZGeXqpMy0rJ99wj1/SrdTvlaX9A=";
  };

  build-system = [ setuptools ];
  dependencies = [ conda-package-streaming ];
  pyproject = true;
  pythonImportsCheck = [ "conda_package_handling" ];

  meta = {
    description = "Create and extract conda packages of various formats";
    homepage = "https://github.com/conda/conda-package-handling";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.ericthemagician ];
  };
}
