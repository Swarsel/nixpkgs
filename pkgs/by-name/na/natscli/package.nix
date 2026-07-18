{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "natscli";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "nats-io";
    repo = "natscli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NF2A4bkGczaH+TYwQnLSvt21uQIk5FZomQuVl22CP30=";
  };

  vendorHash = "sha256-yHLJWpdCUISdehE9nGiodHRrlnIR9j17ua1gBa3JGYA=";

  preCheck = ''
    # Remove tests that depend on CLI output
    substituteInPlace internal/asciigraph/asciigraph_test.go \
      --replace-fail "TestPlot" "SkipPlot"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "nats" ];

  meta = {
    description = "NATS Command Line Interface";
    homepage = "https://github.com/nats-io/natscli";
    changelog = "https://github.com/nats-io/natscli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      bengsparks
      fab
    ];

    mainProgram = "nats";
  };
})
