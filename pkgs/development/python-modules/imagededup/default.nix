{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  matplotlib,
  pillow,
  pytest-mock,
  pytestCheckHook,
  pywavelets,
  scikit-learn,
  setuptools,
  torch,
  torchvision,
  tqdm,
}:
let
  MobileNetV3 = fetchurl {
    hash = "sha256-BH3P9K3e+G6lvC7/E8lhTcEfR6sRYNCnGiXn25lPTh8=";
    url = "https://download.pytorch.org/models/mobilenet_v3_small-047dcff4.pth";
  };
  ViT = fetchurl {
    hash = "sha256-msG1N42ZJ71sg3TODNVX74Dhs/j7wYWd8zLE3J0P2CU=";
    url = "https://download.pytorch.org/models/vit_b_16_swag-9ac1b537.pth";
  };
  EfficientNet = fetchurl {
    hash = "sha256-I6uLzVvb72GnpDuRrcrYH2Iv1/NvtJNaVpgo13iIxE4=";
    url = "https://download.pytorch.org/models/efficientnet_b4_rwightman-23ab8bcd.pth";
  };
in
buildPythonPackage rec {
  pname = "imagededup";
  version = "03.3";

  src = fetchFromGitHub {
    owner = "idealo";
    repo = "imagededup";
    tag = "v${version}";
    hash = "sha256-tm6WGf74xu3CcwpyeA7+rvO5wemO0daXpj/jvYrH19E=";
  };

  nativeBuildInputs = [
    cython
    setuptools
  ];

  propagatedBuildInputs = [
    matplotlib
    pillow
    pywavelets
    scikit-learn
    torch
    torchvision
    tqdm
  ];

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d)

    # Checks with CNN are preloaded to avoid downloads in the check phase
    mkdir -p $HOME/.cache/torch/hub/checkpoints/
    ln -s ${MobileNetV3} $HOME/.cache/torch/hub/checkpoints/${MobileNetV3.name}
    ln -s ${ViT} $HOME/.cache/torch/hub/checkpoints/${ViT.name}
    ln -s ${EfficientNet} $HOME/.cache/torch/hub/checkpoints/${EfficientNet.name}
  '';

  pyproject = true;
  pythonImportsCheck = [ "imagededup" ];

  meta = {
    description = "Finding duplicate images made easy";
    homepage = "https://idealo.github.io/imagededup/";
    changelog = "https://github.com/idealo/imagededup/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stunkymonkey ];
  };
}
