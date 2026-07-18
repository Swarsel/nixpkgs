{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  kornia-rs,
  packaging,
  setuptools,
  torch,
}:

buildPythonPackage rec {
  pname = "kornia";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "kornia";
    repo = "kornia";
    tag = "v${version}";
    hash = "sha256-jNwqWgmILbSrISepuGZZSUnB9GlgwU5J0zqYwN54ul0=";
  };

  doCheck = false; # tests hang with no single test clearly responsible
  build-system = [ setuptools ];

  dependencies = [
    kornia-rs
    packaging
    torch
  ];

  pyproject = true;

  pythonImportsCheck = [
    "kornia"
    "kornia.augmentation"
    "kornia.color"
    "kornia.contrib"
    "kornia.enhance"
    "kornia.feature"
    "kornia.filters"
    "kornia.geometry"
    "kornia.io"
    "kornia.losses"
    "kornia.metrics"
    "kornia.morphology"
    "kornia.tracking"
    "kornia.utils"
  ];

  meta = {
    description = "Differentiable computer vision library";
    homepage = "https://kornia.readthedocs.io";
    changelog = "https://github.com/kornia/kornia/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
