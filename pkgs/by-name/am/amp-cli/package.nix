{
  lib,
  fetchurl,
  autoPatchelfHook,
  cctools,
  darwin,
  gzip,
  makeWrapper,
  rcodesign,
  ripgrep,
  stdenvNoCC,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

let
  platforms = {
    aarch64-darwin = "darwin-arm64";
    aarch64-linux = "linux-arm64";
    # Upstream also publishes linux-x64, which is optimized for AVX2. Use the
    # baseline build for nixpkgs so the x86_64-linux package works on all
    # supported x86_64 CPUs instead of depending on the build user's CPU flags.
    x86_64-linux = "linux-x64-baseline";
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "amp-cli";
  version = "0.0.1783629102-g8185a2";
  src = finalAttrs.passthru.sources.${stdenvNoCC.hostPlatform.system};
  strictDeps = true;

  nativeBuildInputs = [
    gzip
    makeWrapper
  ]
  ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec/amp-cli
    gunzip -c $src > $out/libexec/amp-cli/amp
    chmod +x $out/libexec/amp-cli/amp

    makeWrapper $out/libexec/amp-cli/amp $out/bin/amp \
      --set AMP_SKIP_UPDATE_CHECK 1 \
      --prefix PATH : ${lib.makeBinPath [ ripgrep ]}

    runHook postInstall
  '';

  postInstall = lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    '${lib.getExe' cctools "${cctools.targetPrefix}install_name_tool"}' $out/libexec/amp-cli/amp \
      -change /usr/lib/libicucore.A.dylib '${lib.getLib darwin.ICU}/lib/libicucore.A.dylib'
    '${lib.getExe rcodesign}' sign --code-signature-flags linker-signed $out/libexec/amp-cli/amp
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  dontFixup = !stdenvNoCC.hostPlatform.isLinux;
  dontStrip = true;
  dontUnpack = true;
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgram = "${placeholder "out"}/bin/amp";
  versionCheckProgramArg = "--version";

  passthru = {
    sources = lib.mapAttrs (
      system': platform:
      fetchurl {
        hash =
          {
            aarch64-darwin = "sha256-agoKx8pXQf1HGUwsfqpgeZBubwhnPG+xqIfu3Y+AK2Y=";
            aarch64-linux = "sha256-HJf1Ikmai/h/Y2HybYcKxRhx5VhiyoPaubocCkoxF3s=";
            x86_64-linux = "sha256-KNXCbNhY7njmGQlv3NxBmkIDciVVZlXl9JedBerdrZM=";
          }
          .${system'};

        url = "https://static.ampcode.com/cli/${finalAttrs.version}/amp-${platform}.gz";
      }
    ) platforms;

    updateScript = ./update.sh;
  };

  meta = {
    description = "CLI for Amp, an agentic coding agent in research preview from Sourcegraph";
    homepage = "https://ampcode.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      keegancsmith
      burmudar
    ];

    platforms = builtins.attrNames platforms;
    mainProgram = "amp";
    downloadPage = "https://ampcode.com/install";
  };
})
