{
  lib,
  fetchFromGitHub,
  alsa-lib,
  libxkbcommon,
  makeWrapper,
  onnxruntime,
  openssl,
  pkg-config,
  rustPlatform,
  systemdLibs,
  versionCheckHook,
  # hardware acceleration can be enabled by overriding whisper-cpp/onnxruntime or by editing config.cudaSupport/config.rocmSupport globals
  whisper-cpp,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyprwhspr-rs";
  version = "0.3.32";

  src = fetchFromGitHub {
    owner = "better-slop";
    repo = "hyprwhspr-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z1ITwHiiBubeCnMw/e40XDtLyayDs4UmyEP3CrwlwFQ=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
    alsa-lib
    onnxruntime
    systemdLibs
    libxkbcommon
  ];

  cargoHash = "sha256-MbAUCxTvPw+ERjEa/2C9rjujq9rZG1oU8xvI6jKxHlI=";

  # provide onnx runtime libraries to prevent default behavior of downloading them during the build step
  env = {
    ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
    ORT_STRATEGY = "system";
  };

  postInstall = ''
    wrapProgram $out/bin/hyprwhspr-rs \
      --prefix PATH : ${lib.makeBinPath [ whisper-cpp ]}
    # default voice activation sounds
    install -Dm644 assets/* -t $out/share/assets
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Native speech-to-text voice dictation for Hyprland";
    homepage = "https://github.com/better-slop/hyprwhspr-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CodeF53 ];
    platforms = lib.platforms.linux;
    mainProgram = "hyprwhspr-rs";
  };
})
