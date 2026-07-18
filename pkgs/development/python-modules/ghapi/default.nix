{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fastcore,
  packaging,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ghapi";
  version = "1.0.15";

  src = fetchFromGitHub {
    owner = "fastai";
    repo = "ghapi";
    tag = finalAttrs.version;
    hash = "sha256-H1DuoESnGtU3nsKzW3Zj0RdGNXj1bBGpt6W3mprpVeg=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    fastcore
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "ghapi" ];

  meta = {
    description = "Python interface to GitHub's API";
    homepage = "https://github.com/fastai/ghapi";
    changelog = "https://github.com/fastai/ghapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
