{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  py-datastruct,
  pycryptodome,
  pyserial,
}:

buildPythonPackage rec {
  pname = "bk7231tools";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "tuya-cloudcutter";
    repo = "bk7231tools";
    tag = "v${version}";
    hash = "sha256-CXX4BcdlUQHPtZYggCn0LaqqEDCWXI7LRZnCWsja+SY=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    pycryptodome
    py-datastruct
    pyserial
  ];

  pyproject = true;
  pythonImportsCheck = [ "bk7231tools" ];

  pythonRelaxDeps = [
    "pycryptodome"
    "py-datastruct"
    "pyserial"
  ];

  meta = {
    description = "Tools to interact with and analyze artifacts for BK7231 MCUs";
    homepage = "https://github.com/tuya-cloudcutter/bk7231tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mevatron ];
    mainProgram = "bk7231tools";
  };
}
