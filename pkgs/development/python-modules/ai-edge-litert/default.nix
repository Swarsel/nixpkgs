{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  # dependencies
  backports-strenum,
  buildPythonPackage,
  flatbuffers,
  # optional-dependencies
  lark,
  ml-dtypes,
  numpy,
  # native dependencies
  openvino-native,
  patchelf,
  protobuf,
  python,
  pythonAtLeast,
  tqdm,
  typing-extensions,
}:

let
  release = builtins.fromJSON (builtins.readFile ./release.json);
  platforms = release.src;
  platform =
    platforms.${stdenv.hostPlatform.system}
      or (throw "ai-edge-litert: unsupported platform (${stdenv.hostPlatform.system})");
  pythonMajorMinor = lib.versions.majorMinor python.version;
  source =
    platform.${pythonMajorMinor}
      or (throw "ai-edge-litert: unsupported python version (${pythonMajorMinor})");
in

buildPythonPackage {
  pname = "ai-edge-litert";
  version = release.version;

  src = fetchurl {
    inherit (source)
      url
      hash
      ;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    openvino-native
  ];

  preFixup = ''
    while IFS= read -r -d "" so; do
      ${patchelf}/bin/patchelf --replace-needed libopenvino.so.2620 libopenvino.so "$so"
      ${patchelf}/bin/patchelf --replace-needed libopenvino_tensorflow_lite_frontend.so.2620 libopenvino_tensorflow_lite_frontend.so "$so"
    done < <(find "$out" -type f \( -name '*.so' -o -name '*.so.*' \) -print0)
  '';

  dependencies = [
    backports-strenum
    flatbuffers
    numpy
    protobuf
    tqdm
    typing-extensions
  ];

  format = "wheel";

  optional-dependencies = {
    model-utils = [
      lark
      ml-dtypes
      # TODO :xdsl
    ];
    # TODO: npu-sdk
  };

  pythonImportsCheck = [
    "ai_edge_litert"
    "ai_edge_litert.interpreter"
  ];

  pythonRemoveDeps = lib.optionals (pythonAtLeast "3.12") [
    # https://github.com/google-ai-edge/LiteRT/pull/5298
    "backports.strenum"
  ];

  passthru.updateScript = ./update.py;

  meta = {
    description = "LiteRT is for mobile and embedded devices";
    homepage = "https://www.tensorflow.org/lite/";
    changelog = "https://github.com/google-ai-edge/LiteRT/releases/tag/v${release.version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.attrNames platforms;

    badPlatforms = [
      # elftools.common.exceptions.ELFError: Magic number does not match
      lib.systems.inspect.patterns.isDarwin
    ];

    downloadPage = "https://github.com/google-ai-edge/LiteRT";
  };
}
