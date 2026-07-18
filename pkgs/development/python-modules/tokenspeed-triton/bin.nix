{
  lib,
  stdenv,
  # nativeBuildInputs
  autoPatchelfHook,
  buildPythonPackage,
  fetchPypi,
  pypaInstallHook,
  python,
  pythonAtLeast,
  wheelUnpackHook,
  # buildInputs
  zlib,
}:
let
  inherit (stdenv.hostPlatform) system;
  pythonVersion = if pythonAtLeast "3.12" then "3.12" else python.pythonVersion;
  abiTag = if pythonAtLeast "3.12" then "abi3" else pythonTag;
  pythonTag = "cp${lib.replaceStrings [ "." ] [ "" ] pythonVersion}";

  hashes = {
    aarch64-linux = {
      abi3 = "sha256-Fs0KP8HP/rRYp+A+hohxT0n98LWhCL/KmZ9GWXw/qrs=";
      cp310 = "sha256-rRex0Y8vvOsLsJO+gxeZNkRF+iT/79IWQ5ShvwZJm3Y=";
      cp311 = "sha256-Ds3Y1+o63Z19ckG4NcgMEthCZSvWsg3NhNsYojXhYIQ=";
    };

    x86_64-linux = {
      abi3 = "sha256-uQrEHn8VkzeXVF/xqegDqdi+tMqbpw9tQang/CZIT1w=";
      cp310 = "sha256-GGrclq8qFWW1Z27JIvYSZdf+u5pK6KK/5ioTigYMJ7Y=";
      cp311 = "sha256-Ur4JbdxSJcbyNF4NCQrStWRmqFu+uGbMEaIOD+Pd4b8=";
    };
  };
in
buildPythonPackage (finalAttrs: {
  pname = "tokenspeed-triton";
  version = "3.7.10.post20260531";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = hashes.${system}.${abiTag} or (throw "Unsupported system: ${system}");
    abi = abiTag;
    dist = pythonTag;
    format = "wheel";
    platform = "manylinux_2_27_${stdenv.hostPlatform.uname.processor}.manylinux_2_28_${stdenv.hostPlatform.uname.processor}";
    pname = "tokenspeed_triton";
    python = pythonTag;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    pypaInstallHook
    wheelUnpackHook
  ];

  buildInputs = [ zlib ];
  __structuredAttrs = true;
  pyproject = false;
  pythonImportsCheck = [ "tokenspeed_triton" ];

  meta = {
    description = "Language and compiler for custom Deep Learning operations";
    homepage = "https://github.com/lightseekorg/triton";
    changelog = "https://github.com/lightseekorg/triton/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.attrNames hashes;
    downloadPage = "https://pypi.org/project/tokenspeed-triton/#files";
  };
})
