{
  lib,
  buildPythonPackage,
  fetchPypi,
  hydra-core,
  iopath,
  numpy,
  pillow,
  setuptools,
  torch,
  torchvision,
  tqdm,
}:
buildPythonPackage rec {
  pname = "sam2";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fg6iUtQ8ENhT46z84LV3CsaDwwSBvW3jETAOnUT0W3Q=";
  };

  build-system = [
    setuptools
    torch
  ];

  dependencies = [
    hydra-core
    iopath
    numpy
    pillow
    torch
    torchvision
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "sam2" ];

  meta = {
    description = "SAM 2: Segment Anything in Images and Videos";
    homepage = "https://github.com/facebookresearch/sam2";

    license = with lib.licenses; [
      bsd3
      asl20
    ];

    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.all;
  };
}
