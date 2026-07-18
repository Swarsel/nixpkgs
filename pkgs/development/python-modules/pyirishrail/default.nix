{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyirishrail";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "ttroy50";
    repo = "pyirishrail";
    tag = version;
    hash = "sha256-NgARqhcXP0lgGpgBRiNtQaSn9JcRNtCcZPljcL7t3Xc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pyirishrail" ];

  meta = {
    description = "Python library to get the real-time transport information (RTPI) from Irish Rail";
    homepage = "https://github.com/ttroy50/pyirishrail";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
