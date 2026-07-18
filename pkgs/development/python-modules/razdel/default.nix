{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest7CheckHook,
}:

buildPythonPackage rec {
  pname = "razdel";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QzTA/f401OiIzw7YVJaMnfFPClR9+Qmnf0Y0+f/mJuY=";
  };

  nativeCheckInputs = [ pytest7CheckHook ];
  enabledTestPaths = [ "razdel" ];
  format = "setuptools";
  pythonImportsCheck = [ "razdel" ];

  meta = {
    description = "Rule-based system for Russian sentence and word tokenization";
    homepage = "https://github.com/natasha/razdel";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ npatsakula ];
    mainProgram = "razdel-ctl";
  };
}
