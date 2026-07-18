{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  aiofiles,
  aiohttp,
  buildPythonPackage,
  importlib-metadata,
  nest-asyncio,
  numpy,
  psutil,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
  torch,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "torchsnapshot";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "torchsnapshot";
    tag = finalAttrs.version;
    hash = "sha256-F8OaxLH8BL6MPNLFv1hBuVmeEdnEQ5w2Qny6by1wP6k=";
  };

  # _pickle.UnpicklingError: Weights only load failed.
  # torchsnapshot needs to adapt to the change of torch.load that occured in 2.6.0:
  # https://pytorch.org/docs/stable/generated/torch.load.html
  postPatch = ''
    substituteInPlace torchsnapshot/io_preparers/object.py \
      --replace-fail \
        "torch.load(io.BytesIO(buf))" \
        "torch.load(io.BytesIO(buf), weights_only=False)"
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiofiles
    aiohttp
    importlib-metadata
    nest-asyncio
    numpy
    psutil
    pyyaml
    torch
    typing-extensions
  ];

  disabledTests = [
    # torch.distributed.elastic.multiprocessing.errors.ChildFailedError:
    # AssertionError: "Socket Timeout" does not match "wait timeout after 5000ms
    "test_linear_barrier_timeout"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # aarch64-linux fails cpuinfo test, because /sys/devices/system/cpu/ does not exist in the sandbox:
    # RuntimeError: Failed to initialize cpuinfo!
    "test_tensor_copy"
  ];

  pyproject = true;
  pythonImportsCheck = [ "torchsnapshot" ];

  meta = {
    description = "Performant, memory-efficient checkpointing library for PyTorch applications, designed with large, complex distributed workloads in mind";
    homepage = "https://github.com/pytorch/torchsnapshot/";
    changelog = "https://github.com/pytorch/torchsnapshot/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];

    badPlatforms = [
      # test suite gets stuck and eventually times out with: "torch.distributed.DistNetworkError: The client socket has timed out after"
      lib.systems.inspect.patterns.isDarwin
    ];
  };
})
