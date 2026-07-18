{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  cpio,
  fetchzip,
  installShellFiles,
  versionCheckHook,
  xar,
}:

let
  inherit (stdenv.hostPlatform) system;
  fetch =
    srcPlatform: hash: extension:
    let
      args = {
        inherit hash;
        url = "https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_${srcPlatform}_v${version}.${extension}";
      }
      // lib.optionalAttrs (extension == "zip") { stripRoot = false; };
    in
    if extension == "zip" then fetchzip args else fetchurl args;

  pname = "1password-cli";
  version = "2.34.1";
  sources = {
    aarch64-darwin =
      fetch "apple_universal" "sha256-vp1Y1M6DUanx1CAVhLrqgBovwws6Y/5jOgnwTZE8Hhc="
        "pkg";

    aarch64-linux = fetch "linux_arm64" "sha256-uEukRq71eeayvNguD9XepvP1Br5AkE2Ag/Chv2idf4A=" "zip";
    i686-linux = fetch "linux_386" "sha256-p/F3YZLJnlimrVE2qxTHvIB4m47kuwhoCWTC40VIvMs=" "zip";
    x86_64-linux = fetch "linux_amd64" "sha256-oAABMlwwv5X91TT6FK2aPpg+e2CvmHT1rqIVRTjQNCQ=" "zip";
  };
  platforms = builtins.attrNames sources;
  mainProgram = "op";
in

stdenv.mkDerivation {
  inherit pname version;

  src =
    if (builtins.elem system platforms) then
      sources.${system}
    else
      throw "Source for 1password-cli is not available for ${system}";

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux autoPatchelfHook
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xar
    cpio
  ];

  installPhase = ''
    runHook preInstall
    install -D op $out/bin/op
    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    HOME=$TMPDIR
    installShellCompletion --cmd op \
      --bash <($out/bin/op completion bash) \
      --fish <($out/bin/op completion fish) \
      --zsh <($out/bin/op completion zsh)
  '';

  doInstallCheck = true;
  dontStrip = stdenv.hostPlatform.isDarwin;

  unpackPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    xar -xf $src
    zcat op.pkg/Payload | cpio -i
  '';

  versionCheckProgram = "${placeholder "out"}/bin/op";

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    inherit mainProgram platforms;
    description = "1Password command-line tool";
    homepage = "https://developer.1password.com/docs/cli/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      joelburget
      khaneliman
      savtrip
    ];

    downloadPage = "https://app-updates.agilebits.com/product_history/CLI2";
  };
}
