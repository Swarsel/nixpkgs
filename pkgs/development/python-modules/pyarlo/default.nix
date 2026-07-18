{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  sseclient-py,
}:

buildPythonPackage (finalattrs: {
  pname = "pyarlo";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "tchellomello";
    repo = "python-arlo";
    tag = finalattrs.version;
    sha256 = "0pp7y2llk4xnf6zh57j5xas0gw5zqm42qaqssd8p4qa3g5rds8k3";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    sseclient-py
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyarlo" ];

  meta = {
    description = "Python library to work with Netgear Arlo cameras";
    homepage = "https://github.com/tchellomello/python-arlo";
    changelog = "https://github.com/tchellomello/python-arlo/releases/tag/${finalattrs.src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
})
