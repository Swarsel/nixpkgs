{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "vultr";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "spry-group";
    repo = "python-vultr";
    tag = "v${version}";
    hash = "sha256-ByPtIU6Yro28nH2cIzxqgZR0VwpggCsOAXVDBhssjAI=";
  };

  # Tests disabled. They fail because they try to access the network
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "vultr" ];

  meta = {
    description = "Vultr.com API Client";
    homepage = "https://github.com/spry-group/python-vultr";
    changelog = "https://github.com/spry-group/python-vultr/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lihop ];
  };
}
