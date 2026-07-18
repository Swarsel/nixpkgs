{
  lib,
  stdenv,
  alsa-lib,
  autoPatchelfHook,
  libuuid,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    alsa-lib
    libuuid
  ];

  # libMicrosoft.CognitiveServices.Speech.core.so uses dlopen to load audio.sys.so at runtime.
  # autoPatchelfHook patches direct dependencies but can't detect dlopen calls,
  # so we add the Release directory to RPATH.
  appendRunpaths = lib.optionals stdenv.hostPlatform.isLinux [
    "${placeholder "out"}/share/vscode/extensions/ms-vscode.vscode-speech/node_modules/@vscode/node-speech/build/Release"
  ];

  # Prevent fixup phase from shrinking RPATHs - we need the Release directory
  # in the RPATH for dlopen to find libMicrosoft.CognitiveServices.Speech.extension.audio.sys.so
  dontPatchELF = true;

  mktplcRef =
    let
      sources = {
        "aarch64-darwin" = {
          arch = "darwin-arm64";
          hash = "sha256-JhZWNlGXljsjmT3/xDi9Z7I4a2vsi/9EkWYbnlteE98=";
        };

        "aarch64-linux" = {
          arch = "linux-arm64";
          hash = "sha256-/EaOfoubfq1ufwB7TTQ2hqmh1ZJiZ1+B6QeYu3MoFPI=";
        };

        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-dZwOBehoYEqaYskvcPB55IKnG1CMToioyUJXlndqorA=";
        };
      };
    in
    {
      version = "0.16.0";
      name = "vscode-speech";
      publisher = "ms-vscode";
    }
    // sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "Enables speech-to-text and text-to-speech capabilities in VS Code";
    homepage = "https://github.com/microsoft/vscode";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ pathob ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-speech";
  };
}
