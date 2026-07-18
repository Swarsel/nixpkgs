{
  lib,
  fetchFromGitHub,
  addDriverRunpath,
  buildPythonPackage,
  setuptools,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "py3nvml";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "fbcotter";
    repo = "py3nvml";
    tag = finalAttrs.version;
    hash = "sha256-NZHpjUFeByhe290R9QWZHsVEtwScP5I3LXRh9OQIUgQ=";
  };

  postPatch = ''
    substituteInPlace py3nvml/py3nvml.py \
      --replace-fail "libnvidia-ml.so.1" "${addDriverRunpath.driverLink}/lib/libnvidia-ml.so.1"
  '';

  build-system = [ setuptools ];
  dependencies = [ xmltodict ];
  pyproject = true;
  pythonImportsCheck = [ "py3nvml" ];

  meta = {
    description = "Python 3 Bindings for the NVIDIA Management Library";
    homepage = "https://github.com/fbcotter/py3nvml";
    changelog = "https://github.com/fbcotter/py3nvml/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      bsd3
      bsd2
    ];

    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "py3smi";
  };
})
