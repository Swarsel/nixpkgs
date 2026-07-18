{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pybind11,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyspeex-noise";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "pyspeex-noise";
    tag = version;
    hash = "sha256-XtLA5yVVCZdpALPu3fx+U+aaA729Vs1UeOJsIm6/S+k=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    pybind11
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyspeex_noise" ];

  meta = {
    description = "Noise suppression and automatic gain with speex";
    homepage = "https://github.com/rhasspy/pyspeex-noise";
    changelog = "https://github.com/rhasspy/pyspeex-noise/blob/${src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # pyspeex-noise
      bsd3 # speex (vendored)
    ];

    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
