{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  ipopt,
  numpy,
  pkg-config,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cyipopt";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "mechmotum";
    repo = "cyipopt";
    tag = "v${version}";
    hash = "sha256-feGGAwhNw+xZrSsag2W5nruQWAC6NP9k4F0X9EjaRTg=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ipopt ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "cyipopt" ];

  meta = {
    description = "Cython interface for the interior point optimzer IPOPT";
    homepage = "https://github.com/mechmotum/cyipopt";
    changelog = "https://github.com/mechmotum/cyipopt/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.epl20;
    maintainers = with lib.maintainers; [ nim65s ];
  };
}
