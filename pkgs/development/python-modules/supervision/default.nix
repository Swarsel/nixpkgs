{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  defusedxml,
  matplotlib,
  numpy,
  opencv-python,
  pillow,
  pydeprecate,
  pyyaml,
  requests,
  scipy,
  # build-system
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "supervision";
  version = "0.29.1";

  src = fetchFromGitHub {
    owner = "roboflow";
    repo = "supervision";
    tag = finalAttrs.version;
    hash = "sha256-rDRdoiOfE6n/ZHAxI09cdJbsHwHU8MY9eAVP0J6B2ZA=";
  };

  # Tests require network access and GPU/model resources.
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    defusedxml
    matplotlib
    numpy
    opencv-python
    pillow
    pydeprecate
    pyyaml
    requests
    scipy
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "supervision" ];

  meta = {
    description = "Set of easy-to-use utils that will come in handy in any Computer Vision project";
    homepage = "https://github.com/roboflow/supervision";
    changelog = "https://github.com/roboflow/supervision/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mahyarmirrashed ];
  };
})
