{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fastcore";
  version = "1.14.5";

  src = fetchFromGitHub {
    owner = "fastai";
    repo = "fastcore";
    tag = finalAttrs.version;
    hash = "sha256-lWCUVgu/4Udv3r5BPbBoyn+VyMJYWLWvlcPP89pcC+w=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ packaging ];
  pyproject = true;
  pythonImportsCheck = [ "fastcore" ];

  meta = {
    description = "Python module for Fast AI";
    homepage = "https://github.com/fastai/fastcore";
    changelog = "https://github.com/fastai/fastcore/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
