{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyparsing,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "ucsmsdk";
  version = "0.9.26";

  src = fetchFromGitHub {
    owner = "CiscoUcs";
    repo = "ucsmsdk";
    tag = "v${version}";
    hash = "sha256-PX9SoUhFp0XlEXaKKEh1TA7+gNCUj+t0jOR5hgosu9c=";
  };

  # most tests are broken
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pyparsing
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "ucsmsdk" ];

  meta = {
    description = "Python SDK for Cisco UCS";
    homepage = "https://github.com/CiscoUcs/ucsmsdk";
    changelog = "https://github.com/CiscoUcs/ucsmsdk/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
