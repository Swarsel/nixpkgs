{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cf-terraforming,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "cf-terraforming";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "cf-terraforming";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-jj8bU6n5dpuF9Gg+xh/JXYWODR1C+Q3Lq9oaKJRnm7E=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-JrHt7Av305bwl/RUf2ORz/lRVnoZfUVE4T400DQwjl0=";
  # The test suite insists on downloading a binary release of Terraform from
  # Hashicorp at runtime, which isn't going to work in a nix build
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cf-terraforming \
      --bash <($out/bin/cf-terraforming completion bash) \
      --fish <($out/bin/cf-terraforming completion fish) \
      --zsh <($out/bin/cf-terraforming completion zsh)
  '';

  ldflags = [
    "-X github.com/cloudflare/cf-terraforming/internal/app/cf-terraforming/cmd.versionString=${finalAttrs.version}"
  ];

  passthru.tests = testers.testVersion {
    command = "cf-terraforming version";
    package = cf-terraforming;
  };

  meta = {
    description = "Command line utility to facilitate terraforming your existing Cloudflare resources";
    homepage = "https://github.com/cloudflare/cf-terraforming/";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ benley ];
    mainProgram = "cf-terraforming";
  };
})
