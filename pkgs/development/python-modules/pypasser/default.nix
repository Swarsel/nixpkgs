{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pydub,
  pysocks,
  pythonRelaxDepsHook,
  requests,
  selenium,
  setuptools,
  speechrecognition,
}:

buildPythonPackage rec {
  pname = "pypasser";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "xHossein";
    repo = "PyPasser";
    tag = version;
    hash = "sha256-vqa+Xap9dYvjJMiGNGNmegh7rmAqwf3//MH47xwr/T0=";
  };

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ];

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pydub
    pysocks
    requests
    selenium
    speechrecognition
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pypasser"
    "pypasser.reCaptchaV2"
    "pypasser.reCaptchaV3"
  ];

  pythonRelaxDeps = [
    "speechrecognition"
  ];

  meta = {
    description = "Bypassing reCaptcha V3 by sending HTTP requests & solving reCaptcha V2 using speech to text";
    homepage = "https://github.com/xHossein/PyPasser";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
