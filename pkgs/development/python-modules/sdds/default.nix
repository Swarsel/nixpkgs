{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  numpy,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "sdds";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "pylhc";
    repo = "sdds";
    tag = "v${version}";
    hash = "sha256-2lsim4FlOKBZ4Lk/iKIcItE/hvqiAK4XTkoxm52At/8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "sdds" ];

  meta = {
    description = "Module to handle SDDS files";
    homepage = "https://pylhc.github.io/sdds/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
