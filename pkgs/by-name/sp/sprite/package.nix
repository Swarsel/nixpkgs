{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sprite";
  version = "0.0.1-rc45";

  src = fetchurl {
    url = "https://sprites-binaries.t3.storage.dev/client/v${finalAttrs.version}/sprite-${
      if stdenv.hostPlatform.isLinux then "linux" else "darwin"
    }-${if stdenv.hostPlatform.isx86_64 then "amd64" else "arm64"}.tar.gz";

    hash =
      {
        aarch64-darwin = "sha256-0EbsXuNdSC9lfTR9lQFgGk9nYg200f+tZY8xcXmqTzc=";
        aarch64-linux = "sha256-4a7LrFWgxe5wUcPLMDvo2/HmpCnELkJSyr2nAA9RBwk=";
        x86_64-linux = "sha256-FfWZ9PFhorfbf8/YsdcFAnpA2QtA1LqAfQiGrc8sesQ=";
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook;

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 sprite $out/bin/
    wrapProgram $out/bin/sprite --set UPGRADE_CHECK false
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  sourceRoot = ".";
  versionCheckKeepEnvironment = "HOME";
  versionCheckProgramArg = "--version";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Command Line Interactive for sprites, stateful sandbox environments with checkpoint & restore";
    homepage = "https://sprites.dev";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ drawbu ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "sprite";
  };
})
