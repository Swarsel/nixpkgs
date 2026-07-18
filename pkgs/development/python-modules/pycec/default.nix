{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libcec,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycec";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "konikvranik";
    repo = "pycec";
    tag = "v${version}";
    hash = "sha256-5KQyHjAvHWeHFqcFHFJxDOPwWuVcFAN2wVdz9a77dzU=";
  };

  patches = [
    # https://github.com/konikvranik/pyCEC/pull/84
    ./python-3.14-compat.patch
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ libcec ];
  pyproject = true;
  pythonImportsCheck = [ "pycec" ];

  meta = {
    description = "Python modules to access HDMI CEC devices";
    homepage = "https://github.com/konikvranik/pycec/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pycec";
  };
}
