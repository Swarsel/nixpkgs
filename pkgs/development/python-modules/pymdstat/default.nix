{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymdstat";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "nicolargo";
    repo = "pymdstat";
    rev = "v${version}";
    hash = "sha256-ZpAXD77bNJ+YpXCW0es7jR+Hs3uDDfxWVeHiWz3sDRs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "unitest.py" ];
  pyproject = true;
  pythonImportsCheck = [ "pymdstat" ];

  meta = {
    description = "Pythonic library to parse Linux /proc/mdstat file";
    homepage = "https://github.com/nicolargo/pymdstat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rhoriguchi ];
  };
}
