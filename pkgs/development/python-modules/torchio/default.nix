{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # optional dependencies
  colorcet,
  # dependencies
  deprecated,
  einops,
  ffmpeg-python,
  humanize,
  jaxtyping,
  matplotlib,
  monai,
  nibabel,
  numpy,
  packaging,
  pandas,
  # tests
  parameterized,
  pytestCheckHook,
  rich,
  scikit-learn,
  scipy,
  simpleitk,
  torch,
  tqdm,
  typer,
  # build-system
  uv-build,
}:

buildPythonPackage rec {
  pname = "torchio";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "TorchIO-project";
    repo = "torchio";
    tag = "v${version}";
    hash = "sha256-v9mAtwyglY5PsszrIzGSZJ+eEK3ED3v0slai7Vz9WjA=";
  };

  nativeCheckInputs = [
    matplotlib
    parameterized
    pytestCheckHook
  ]
  ++ optional-dependencies.monai
  ++ optional-dependencies.sklearn;

  build-system = [
    uv-build
  ];

  dependencies = [
    deprecated
    einops
    humanize
    jaxtyping
    nibabel
    numpy
    packaging
    rich
    scipy
    simpleitk
    torch
    tqdm
    typer
  ];

  disabledTests = [
    # tries to download models:
    "test_load_all"
  ]
  ++ lib.optionals stdenv.hostPlatform.isAarch64 [
    # RuntimeError: DataLoader worker (pid(s) <...>) exited unexpectedly
    "test_queue_multiprocessing"
  ];

  optional-dependencies =
    let
      extras = {
        csv = [ pandas ];
        monai = [ monai ];

        plot = [
          colorcet
          matplotlib
        ];

        sklearn = [ scikit-learn ];
        video = [ ffmpeg-python ];
      };
    in
    extras // { all = lib.concatLists (lib.attrValues extras); };

  pyproject = true;

  pythonImportsCheck = [
    "torchio"
    "torchio.data"
  ];

  meta = {
    description = "Medical imaging toolkit for deep learning";
    homepage = "https://docs.torchio.org";
    changelog = "https://github.com/TorchIO-project/torchio/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
}
