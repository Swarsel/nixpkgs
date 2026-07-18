{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  intelhex,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "lpc-checksum";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "basilfx";
    repo = "lpc_checksum";
    rev = "v${version}";
    hash = "sha256-POgV0BdkMLmdjBh/FToPPmJTAxsPASB7ZE32SqGGKHk=";
  };

  nativeBuildInputs = [
    poetry-core
    pytestCheckHook
  ];

  propagatedBuildInputs = [ intelhex ];
  pyproject = true;
  pythonImportsCheck = [ "lpc_checksum" ];

  meta = {
    description = "Python script to calculate LPC firmware checksums";
    homepage = "https://pypi.org/project/lpc-checksum/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ otavio ];
    mainProgram = "lpc_checksum";
  };
}
