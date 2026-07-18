{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  colorama,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "shamir-mnemonic";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "trezor";
    repo = "python-${pname}";
    tag = "v${version}";
    hash = "sha256-KjZbxA92h25ghbItdmPvkSPvDZUSRWkl4vnJDBMN71s=";
  };

  propagatedBuildInputs = [
    click
    colorama
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "shamir_mnemonic" ];

  meta = {
    description = "Reference implementation of SLIP-0039";
    homepage = "https://github.com/trezor/python-shamir-mnemonic";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
    mainProgram = "shamir";
  };
}
