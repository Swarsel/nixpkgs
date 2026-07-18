{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  ifaddr,
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wsdiscovery";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "andreikop";
    repo = "python-ws-discovery";
    tag = "v${version}";
    hash = "sha256-c9ExGiNo0j+h1U9yKU3OtInawJXivBxdzAGvrSfi7VE=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    ifaddr
  ];

  pyproject = true;
  pythonImportsCheck = [ "wsdiscovery" ];

  meta = {
    description = "WS-Discovery implementation for Python";
    homepage = "https://github.com/andreikop/python-ws-discovery";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
}
