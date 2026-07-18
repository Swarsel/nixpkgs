{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
  libxcrypt-legacy,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "resilio-sync";
  version = "3.1.1.1075";

  src =
    {
      aarch64-linux = fetchurl {
        hash = "sha256-P3gUwj3Vr9qn9S6iqlgGfZpK7x5u4U96b886JCE3CYY=";
        url = "https://download-cdn.resilio.com/${finalAttrs.version}/linux/arm64/0/resilio-sync_arm64.tar.gz";
      };

      x86_64-linux = fetchurl {
        hash = "sha256-FgRMK5dOxkbaXyi0BPYQZK0tR/ZZuuUGAciwThqICBk=";
        url = "https://download-cdn.resilio.com/${finalAttrs.version}/linux/x64/0/resilio-sync_x64.tar.gz";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    autoPatchelfHook
    installShellFiles
  ];

  buildInputs = [
    stdenv.cc.libc
    libxcrypt-legacy
  ];

  installPhase = ''
    runHook preInstall

    installBin rslsync

    runHook postInstall
  '';

  dontStrip = true; # Don't strip, otherwise patching the rpaths breaks
  sourceRoot = ".";

  meta = {
    description = "Automatically sync files via secure, distributed technology";
    homepage = "https://www.resilio.com/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      thoughtpolice
      cwoac
    ];

    platforms = lib.platforms.linux;
    mainProgram = "rslsync";
  };
})
