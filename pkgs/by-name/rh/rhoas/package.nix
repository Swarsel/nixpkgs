{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  rhoas,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "rhoas";
  version = "0.53.0";

  src = fetchFromGitHub {
    owner = "redhat-developer";
    repo = "app-services-cli";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-9fydRgp2u1LWf0lEDMi1OxxFURd14oKCBDKACqrgWII=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  # Networking tests fail.
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd rhoas \
      --bash <(HOME=$TMP $out/bin/rhoas completion bash) \
      --fish <(HOME=$TMP $out/bin/rhoas completion fish) \
      --zsh <(HOME=$TMP $out/bin/rhoas completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/redhat-developer/app-services-cli/internal/build.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "HOME=$TMP rhoas version";
    package = rhoas;
  };

  meta = {
    description = "Command Line Interface for Red Hat OpenShift Application Services";
    homepage = "https://github.com/redhat-developer/app-services-cli";
    changelog = "https://github.com/redhat-developer/app-services-cli/releases/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stehessel ];
    mainProgram = "rhoas";
  };
})
