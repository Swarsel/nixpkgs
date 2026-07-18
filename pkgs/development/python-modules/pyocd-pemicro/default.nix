{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyocd,
  pypemicro,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyocd-pemicro";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "pyocd";
    repo = "pyocd-pemicro";
    tag = "v${version}";
    hash = "sha256-qi803s8fkrLizcCLeDRz7CTQ56NGLQ4PPwCbxiRigwc=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    pyocd
    pypemicro
  ];

  # upstream has no tests
  doCheck = false;
  pyproject = true;

  meta = {
    description = "PEMicro probe plugin for pyOCD";
    homepage = "https://github.com/pyocd/pyocd-pemicro";
    changelog = "https://github.com/pyocd/pyocd-pemicro/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
