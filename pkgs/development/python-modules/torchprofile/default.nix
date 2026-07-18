{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  setuptools,
  torch,
  torchvision,
}:

buildPythonPackage rec {
  pname = "torchprofile";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "zhijian-liu";
    repo = "torchprofile";
    tag = "v${version}";
    hash = "sha256-ynRrGHzroyv8T8fggJAag7u6XBOx+uN49HSIe46Bcek=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    torch
    torchvision
  ];

  pyproject = true;

  pythonImportsCheck = [
    "torchprofile"
  ];

  pythonRelaxDeps = [
    "torchvision"
  ];

  meta = {
    description = "General and accurate MACs / FLOPs profiler for PyTorch models";
    homepage = "https://github.com/zhijian-liu/torchprofile";
    changelog = "https://github.com/zhijian-liu/torchprofile/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
