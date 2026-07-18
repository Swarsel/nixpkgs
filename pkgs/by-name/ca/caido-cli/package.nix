{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libgcc,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "caido-cli";
  version = "0.57.0";

  src = fetchurl (
    {
      aarch64-darwin = {
        hash = "sha256-FwbKLEwjiFzZWdBS6RgsDtc/EkI9AT2CBGwdmgEdDnw=";
        url = "https://caido.download/releases/v${finalAttrs.version}/caido-cli-v${finalAttrs.version}-mac-aarch64.zip";
      };

      aarch64-linux = {
        hash = "sha256-d1xzF0N6emShCQpotFiQEj1wV3hdt1DK7R+6Smlxrmg=";
        url = "https://caido.download/releases/v${finalAttrs.version}/caido-cli-v${finalAttrs.version}-linux-aarch64.tar.gz";
      };

      x86_64-linux = {
        hash = "sha256-ujpGYERNceUPartkgx4o38xUfPwWvnmiEnjkvmEbybA=";
        url = "https://caido.download/releases/v${finalAttrs.version}/caido-cli-v${finalAttrs.version}-linux-x86_64.tar.gz";
      };
    }
    .${stdenv.hostPlatform.system}
      or (throw "caido-cli: unsupported system ${stdenv.hostPlatform.system}")
  );

  nativeBuildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ unzip ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libgcc ];

  installPhase = ''
    runHook preInstall
    install -m 755 -D caido-cli $out/bin/caido-cli
    runHook postInstall
  '';

  sourceRoot = ".";

  meta = {
    description = "Caido CLI — lightweight web security auditing toolkit";
    homepage = "https://caido.io/";
    changelog = "https://github.com/caido/caido/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      blackzeshi
      m0streng0
      octodi
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "caido-cli";
  };
})
