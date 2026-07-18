{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "dapr-cli";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "dapr";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2zi8r4LIguWPrsvpvz+sYF4sXqBVmWJtzHLm5nRHFCU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-P7zrfUcb/Hxo7QbIQfq9JSf2d7meZShQ++GG8HkEoLE=";

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  postInstall = ''
    mv $out/bin/cli $out/bin/dapr

    installShellCompletion --cmd dapr \
      --bash <($out/bin/dapr completion bash) \
      --zsh <($out/bin/dapr completion zsh)
  '';

  ldflags = [
    "-X main.version=${finalAttrs.version}"
    "-X main.apiVersion=1.0"
    "-X github.com/dapr/cli/pkg/standalone.gitcommit=${finalAttrs.src.rev}"
    "-X github.com/dapr/cli/pkg/standalone.gitversion=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "." ];

  meta = {
    description = "CLI for managing Dapr, the distributed application runtime";
    homepage = "https://dapr.io";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      joshvanl
      lucperkins
    ];

    mainProgram = "dapr";
  };
})
