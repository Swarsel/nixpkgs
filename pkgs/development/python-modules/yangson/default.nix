{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  elementpath,
  poetry-core,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "yangson";
  version = "1.7.8";

  src = fetchFromGitHub {
    owner = "CZ-NIC";
    repo = "yangson";
    tag = version;
    hash = "sha256-otvKjMsH2A4Zxs1ZeafTSDNUroSmxzOhw8P+V13uN88=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    elementpath
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "yangson" ];
  pythonRelaxDeps = [ "elementpath" ];
  # only used for docs build
  pythonRemoveDeps = [ "sphinxcontrib-shtest" ];

  meta = {
    description = "Library for working with data modelled in YANG";
    homepage = "https://github.com/CZ-NIC/yangson";

    license = with lib.licenses; [
      gpl3Plus
      lgpl3Plus
    ];

    maintainers = [ ];
    mainProgram = "yangson";
  };
}
