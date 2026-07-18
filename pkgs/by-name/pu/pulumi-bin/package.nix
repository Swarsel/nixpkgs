{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  installShellFiles,
  makeWrapper,
}:

let
  data = import ./data.nix { };
in
stdenv.mkDerivation {
  inherit (data) version;
  pname = "pulumi";

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [ stdenv.cc.cc.libgcc or null ];

  installPhase = ''
    install -D -t $out/bin/ *
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/pulumi --set LD_LIBRARY_PATH "${lib.getLib stdenv.cc.cc}/lib"
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pulumi \
      --bash <($out/bin/pulumi completion bash) \
      --fish <($out/bin/pulumi completion fish) \
      --zsh  <($out/bin/pulumi completion zsh)
  '';

  postUnpack = ''
    mv pulumi-* pulumi
  '';

  srcs = map fetchurl data.pulumiPkgs.${stdenv.hostPlatform.system};

  meta = {
    description = "Pulumi is a cloud development platform that makes creating cloud programs easy and productive";
    homepage = "https://pulumi.io/";
    license = with lib.licenses; [ asl20 ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      jlesquembre
      cpcloud
      wrbbz
    ];

    platforms = builtins.attrNames data.pulumiPkgs;
    hydraPlatforms = [ ]; # Hydra fails with "Output limit exceeded"
  };
}
