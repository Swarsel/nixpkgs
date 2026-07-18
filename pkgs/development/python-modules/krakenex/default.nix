{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "krakenex";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "veox";
    repo = "python3-krakenex";
    rev = "v${version}";
    hash = "sha256-htldEds3vf9bjFkJAew0e0fHDLD15OTcVYybSmIp3DI=";
  };

  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "krakenex" ];

  meta = {
    description = "Kraken.com cryptocurrency exchange API";
    homepage = "https://github.com/veox/python3-krakenex";
    changelog = "https://github.com/veox/python3-krakenex/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
