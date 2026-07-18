{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyevmasm";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "crytic";
    repo = "pyevmasm";
    rev = version;
    sha256 = "134q0z0dqzxzr0jw5jr98kp90kx2dl0qw9smykwxdgq555q1l6qa";
  };

  propagatedBuildInputs = [ future ];
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Ethereum Virtual Machine (EVM) assembler and disassembler";
    homepage = "https://github.com/crytic/pyevmasm";
    changelog = "https://github.com/crytic/pyevmasm/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arturcygan ];
    mainProgram = "evmasm";
  };
}
