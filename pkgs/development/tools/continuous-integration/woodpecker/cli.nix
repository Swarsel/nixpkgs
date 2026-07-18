{
  lib,
  stdenv,
  buildGoModule,
  callPackage,
  installShellFiles,
}:
let
  common = callPackage ./common.nix { };
in
buildGoModule {
  inherit (common)
    version
    src
    ldflags
    vendorHash
    ;

  pname = "woodpecker-cli";
  nativeBuildInputs = [ installShellFiles ];
  env.CGO_ENABLED = 0;

  postInstall = ''
    ${common.postInstall}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd woodpecker-cli \
      --bash <($out/bin/woodpecker-cli completion bash) \
      --fish <($out/bin/woodpecker-cli completion fish ) \
      --zsh <($out/bin/woodpecker-cli completion zsh)
  '';

  subPackages = "cmd/cli";

  meta = common.meta // {
    description = "Command line client for the Woodpecker Continuous Integration server";
    mainProgram = "woodpecker-cli";
  };
}
