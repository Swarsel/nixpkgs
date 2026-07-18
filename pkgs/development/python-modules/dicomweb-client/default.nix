{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  numpy,
  pillow,
  pydicom,
  pytest-localserver,
  pytestCheckHook,
  requests,
  retrying,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "dicomweb-client";
  version = "0.61.0";

  src = fetchFromGitHub {
    owner = "ImagingDataCommons";
    repo = "dicomweb-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uCImuJDZr2gyWnLCU2JCmkGO/EloRty1fIRujwzYzAg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-localserver
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    numpy
    pillow
    pydicom
    requests
    retrying
  ];

  pyproject = true;
  pythonImportsCheck = [ "dicomweb_client" ];

  meta = {
    description = "Python client for DICOMweb RESTful services";
    homepage = "https://dicomweb-client.readthedocs.io";
    changelog = "https://github.com/ImagingDataCommons/dicomweb-client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
    mainProgram = "dicomweb_client";
  };
})
