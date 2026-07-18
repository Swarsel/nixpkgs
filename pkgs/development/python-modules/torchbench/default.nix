{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  opencv4,
  setuptools,
  sotabenchapi,
  torch,
  torchvision,
  tqdm,
}:

let
  version = "0.0.31";
  pname = "torchbench";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-EBZzcnRT50KREIOPrr/OZTJ4639ZUEejcelh3QSBcZ8=";
  };

  # requirements.txt is missing in the Pypi archive and this makes the setup.py script fails
  postPatch = ''
    touch requirements.txt
  '';

  # No tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    opencv4
    sotabenchapi
    torch
    torchvision
    tqdm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "torchbench"
  ];

  meta = {
    description = "Easily benchmark machine learning models in PyTorch";
    homepage = "https://github.com/paperswithcode/torchbench";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
