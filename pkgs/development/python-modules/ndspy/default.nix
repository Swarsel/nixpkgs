{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ndspy";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "RoadrunnerWMC";
    repo = "ndspy";
    tag = "v${version}";
    hash = "sha256-PQONVEuh5Fg2LHr4gq0XTGcOpps/s9FSgoyDn4BCcik=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd tests
  '';

  format = "setuptools";
  pythonImportsCheck = [ "ndspy" ];

  meta = {
    description = "Python library for many Nintendo DS file formats";
    homepage = "https://github.com/RoadrunnerWMC/ndspy";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
}
