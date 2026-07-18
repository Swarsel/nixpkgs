{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

let
  version = "1.0.15498356";
  platformData = {
    aarch64-darwin = {
      hash = "sha256-E3PC0Ivf6MoYRQu56dSD/49LI8DJZhXL27/o6daH0Sg=";
      url = "https://dl.google.com/android/cli/${version}/darwin_arm64/android-cli";
    };

    x86_64-linux = {
      hash = "sha256-TmwLwLKqnMCxWwtX8m50KflmisfeG3PjZsBs7z9vccU=";
      url = "https://dl.google.com/android/cli/${version}/linux_x86_64/android-cli";
    };
  };

  systemData =
    platformData.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
stdenv.mkDerivation {
  inherit version;
  pname = "android-cli";

  src = fetchurl {
    url = systemData.url;
    hash = systemData.hash;
    name = "android-cli";
  };

  strictDeps = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    install -m755 -D $src $out/bin/android
    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  versionCheckKeepEnvironment = [ "HOME" ];

  meta = with lib; {
    description = "Android Command-Line Tool (CLI) by Google";
    homepage = "https://developer.android.com/tools/agents/android-cli";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ kirillrdy ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "android";
    teams = with teams; [ android ];
  };
}
