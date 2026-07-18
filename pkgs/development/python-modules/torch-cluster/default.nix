{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # passthru
  nix-update-script,
  # buildInputs
  pybind11,
  # tests
  pytestCheckHook,
  # dependencies
  scipy,
  # build-system
  setuptools,
  torch,
}:

buildPythonPackage.override { inherit (torch) stdenv; } (finalAttrs: {
  pname = "torch-cluster";
  version = "1.6.3-unstable-2026-06-05";

  # Last stable release is from 2023
  # Development is still active, but nothing was properly tagged on GitHub or Pypi
  # See: https://github.com/rusty1s/pytorch_cluster/issues/270
  src = fetchFromGitHub {
    owner = "rusty1s";
    repo = "pytorch_cluster";
    rev = "e9a855c284b45edcbf0282cf70ac09bee0ce4e49";
    hash = "sha256-0VgJBo37IUXZT3NC40fQ9pttDM3J6l2ks0061Mv3hk8=";
  };

  buildInputs = [
    pybind11
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Otherwise python imports torch_cluster from /build/source instead of $out/..., which fails when
  # trying to load the inexistant .so artifacts.
  preCheck = ''
    rm -rf torch_cluster
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
    torch
  ];

  dependencies = [
    scipy
  ];

  disabledTests = lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # aarch64-linux fails cpuinfo test, because /sys/devices/system/cpu/ does not exist in the sandbox:
    # RuntimeError: Failed to initialize cpuinfo!
    "test_fps"
    "test_nearest"
  ];

  pyproject = true;
  pythonImportsCheck = [ "torch_cluster" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "PyTorch Extension Library of Optimized Graph Cluster Algorithms";
    homepage = "https://github.com/rusty1s/pytorch_cluster";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
