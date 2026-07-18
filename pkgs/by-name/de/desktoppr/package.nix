{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  swift,
  swiftpm,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "desktoppr";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "scriptingosx";
    repo = "desktoppr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eEVcYSa1ntyX/Wdj4HUyXyXIrK+T11Thg23ntNoIgH0=";
  };

  patches = [
    # Update version in the code from 0.5b (beta) to 0.5 (release)
    (fetchpatch {
      hash = "sha256-7A3hsXO0hZYlZMrX1U0zC2vy59M9H5OZebEbPY8E9fA=";
      includes = [ "desktoppr/main.swift" ];
      url = "https://github.com/scriptingosx/desktoppr/commit/419363c28c99eb0f391bf231813af5e507c35573.patch";
    })
    # Adds support for building with swiftpm
    (fetchpatch {
      hash = "sha256-8sAUNnTGqQ2UHIFUPwTP0dd3QKgI0HfOrG0HzcIStMM=";
      url = "https://github.com/scriptingosx/desktoppr/commit/eaf08da7cdd5fe9aa656516b3a5a0a9ac9969e72.patch";
    })
  ];

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$(swiftpmBinPath)/desktoppr" -t "$out/bin"
    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Simple command line tool to read and set the desktop picture/wallpaper";
    homepage = "https://github.com/scriptingosx/desktoppr";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ andre4ik3 ];
    platforms = lib.platforms.darwin;
    mainProgram = "desktoppr";
  };
})
