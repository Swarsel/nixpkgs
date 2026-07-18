{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:
let
  version = "1.8.4";
in
buildGoModule {
  inherit version;
  pname = "algolia-cli";

  src = fetchFromGitHub {
    owner = "algolia";
    repo = "cli";
    tag = "v${version}";
    hash = "sha256-ltr31AnZPTtnfMWaUtsswUnIOXfR76X8pjM9D0uiLJo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-WdNuwUz64IZq3gfvFhXX536/tZ/67Ki0xiqIj7sLSEM=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd algolia \
      --bash <($out/bin/algolia completion bash) \
      --fish <($out/bin/algolia completion fish) \
      --zsh <($out/bin/algolia completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/algolia/cli/pkg/version.Version=${version}"
  ];

  subPackages = [ "cmd/algolia" ];

  meta = {
    description = "Algolia’s official CLI devtool";
    homepage = "https://algolia.com/doc/tools/cli/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "algolia";
  };
}
