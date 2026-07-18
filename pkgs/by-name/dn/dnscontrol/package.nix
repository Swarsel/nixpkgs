{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "dnscontrol";
  version = "4.42.0";

  src = fetchFromGitHub {
    owner = "DNSControl";
    repo = "dnscontrol";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iB2PFPvcASRwpBkFJQ3Vi2r89H3a9BBbC1moAymWDOI=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-8rL5v/0Vb+gxmbDaEB57UsQEnKCJtbZh0lFUyKYMZgs=";

  preCheck = ''
    # requires network
    rm pkg/spflib/flatten_test.go pkg/spflib/parse_test.go
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd dnscontrol \
      --bash <($out/bin/dnscontrol shell-completion bash) \
      --zsh <($out/bin/dnscontrol shell-completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-X=github.com/DNSControl/dnscontrol/v${lib.versions.major finalAttrs.version}/pkg/version.version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Synchronize your DNS to multiple providers from a simple DSL";
    homepage = "https://dnscontrol.org/";
    changelog = "https://github.com/DNSControl/dnscontrol/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      SuperSandro2000
      zowoq
    ];

    mainProgram = "dnscontrol";
  };
})
