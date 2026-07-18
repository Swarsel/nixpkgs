{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  zeep,
}:

buildPythonPackage rec {
  pname = "python-stdnum";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "arthurdejong";
    repo = "python-stdnum";
    tag = version;
    hash = "sha256-X/VmD9bgOfs58m4YtmIdsYI5B4T0a68Wiiq2Ae27A8w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  optional-dependencies = {
    SOAP = [ zeep ];
  };

  pyproject = true;
  pythonImportsCheck = [ "stdnum" ];

  meta = {
    description = "Python module to handle standardized numbers and codes";
    homepage = "https://arthurdejong.org/python-stdnum/";
    changelog = "https://github.com/arthurdejong/python-stdnum/blob/${version}/ChangeLog";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ johbo ];
  };
}
