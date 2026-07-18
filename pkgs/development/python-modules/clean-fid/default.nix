{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  numpy,
  pillow,
  requests,
  scipy,
  setuptools,
  torch,
  torchvision,
  tqdm,
}:

buildPythonPackage {
  pname = "clean-fid";
  version = "0.1.35";

  src = fetchFromGitHub {
    owner = "GaParmar";
    repo = "clean-fid";
    rev = "c8ffa420a3923e8fd87c1e75170de2cf59d2644b";
    hash = "sha256-fqBU/TmCXDTPU3KTP0+VYQoP+HsT2UMcZeLzQHKD9hw=";
  };

  # no tests1
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    pillow
    requests
    scipy
    torch
    torchvision
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "cleanfid" ];

  meta = {
    description = "PyTorch - FID calculation with proper image resizing and quantization steps [CVPR 2022]";
    homepage = "https://www.cs.cmu.edu/~clean-fid/";
    license = lib.licenses.mit;
    downloadPage = "https://github.com/GaParmar/clean-fid";
    teams = [ lib.teams.tts ];
  };
}
