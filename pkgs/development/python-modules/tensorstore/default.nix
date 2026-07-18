{
  lib,
  stdenv,
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  ml-dtypes,
  numpy,
  python,
}:

let
  pythonVersionNoDot = builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion;
  systemToPlatform = {
    "aarch64-darwin" = "macosx_11_0_arm64";
    "aarch64-linux" = "manylinux_2_27_aarch64.manylinux_2_28_aarch64";
    "x86_64-linux" = "manylinux_2_27_x86_64.manylinux_2_28_x86_64";
  };
  hashes = {
    "311-aarch64-darwin" = "sha256-NA/pcfGAjXBg8ic7ju41J4C8tl5QNfeBY/qbiTCqeVo=";
    "311-aarch64-linux" = "sha256-NDUvi6bl77pf6xiRfWjaGpK7/4DmTD/QbT0a9LNDgho=";
    "311-x86_64-linux" = "sha256-iudEUatcyKDNnlGSat8E9N/b2K1awxrHHxyqe9+ygo0=";
    "312-aarch64-darwin" = "sha256-RHfqvibi9RMfGxo0RM2RZ/5p+rwpV56rglnSGDmbnms=";
    "312-aarch64-linux" = "sha256-Os4Azy5F3F1k/joQwsvvYTQ5FWg4CKEKPggSM1ZqcjE=";
    "312-x86_64-linux" = "sha256-ZMgDlVjVYHtzkDlI/OBYclcx30EMXBls9Ys/xiIjlbU=";
    "313-aarch64-darwin" = "sha256-AoRVzM3AXDHxlASM9FmiZmmybTjwUWyvkhPnIZse55o=";
    "313-aarch64-linux" = "sha256-UK+wbFelCQkQFa9qhdpvSDp/WtA3IoTdldVRPYdzNuQ=";
    "313-x86_64-linux" = "sha256-jqU6hR6oaq09mcFKeQyFRo1jJL4Ux6whHx8CZej6twc=";
    "314-aarch64-darwin" = "sha256-19AXdZhfyqKw8QA0l2apU8UIbpLnRr85XpNhUdTY+aw=";
    "314-aarch64-linux" = "sha256-Gy/11VNqipsVlsUbkHXMnUC0xOpObMA8BIARHb5dlW0=";
    "314-x86_64-linux" = "sha256-fJEIrmwprckLcsome6K1dzhsXkEOovjofqvOXr2tMn4=";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "tensorstore";
  version = "0.1.84";

  # The source build involves some wonky Bazel stuff.
  src = fetchPypi {
    inherit (finalAttrs) pname version;

    hash =
      hashes."${pythonVersionNoDot}-${stdenv.system}"
        or (throw "unsupported system/python version combination");

    abi = "cp${pythonVersionNoDot}";
    dist = "cp${pythonVersionNoDot}";
    format = "wheel";
    platform = systemToPlatform.${stdenv.system} or (throw "unsupported system");
    python = "cp${pythonVersionNoDot}";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  __structuredAttrs = true;

  dependencies = [
    ml-dtypes
    numpy
  ];

  format = "wheel";
  pythonImportsCheck = [ "tensorstore" ];

  meta = {
    description = "Library for reading and writing large multi-dimensional arrays";
    homepage = "https://google.github.io/tensorstore";
    changelog = "https://github.com/google/tensorstore/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ samuela ];
  };
})
