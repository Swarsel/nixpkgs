{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pkgs,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "yara-x";
  version = "1.19.0";

  src = fetchFromGitHub {
    owner = "VirusTotal";
    repo = "yara-x";
    tag = "v${version}";
    hash = "sha256-CokjFTQoFT9k/2/MuQSbfzHonW4V0F8hskhqDvpCesM=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = [ pkgs.yara-x ];
  nativeCheckInputs = [ pytestCheckHook ];
  buildAndTestSubdir = "py";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname src version;
    hash = "sha256-wMh8F++16tQ0IUhacBPb4rDcydmDKZKzQf8EK/qDJXo=";
  };

  pyproject = true;
  pythonImportsCheck = [ "yara_x" ];

  meta = {
    description = "Official Python library for YARA-X";
    homepage = "https://github.com/VirusTotal/yara-x/tree/main/py";
    changelog = "https://github.com/VirusTotal/yara-x/tree/${src.tag}/py";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      ivyfanchiang
      lesuisse
    ];
  };
}
