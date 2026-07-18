{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cerberus,
  pyyaml,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "riscv-config";
  version = "3.18.3";

  src = fetchFromGitHub {
    owner = "riscv-software-src";
    repo = "riscv-config";
    tag = version;
    hash = "sha256-eaHi6ezgU8gQYH97gCS2TzEzIP3F4zfn7uiA/To2Gmc=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cerberus
    pyyaml
    ruamel-yaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "riscv_config" ];
  pythonRelaxDeps = [ "pyyaml" ];

  meta = {
    description = "RISC-V configuration validator";
    homepage = "https://github.com/riscv/riscv-config";
    changelog = "https://github.com/riscv-software-src/riscv-config/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "riscv-config";
  };
}
