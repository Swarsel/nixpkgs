{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gost";
  version = "3.2.6";

  src = fetchFromGitHub {
    owner = "go-gost";
    repo = "gost";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zq9UrzXbKVraqq8eGY5XOHOMdpfuOog5V17+wh9vwIc=";
  };

  vendorHash = "sha256-LbmGYV85+JmiLlJhdozAyzWIql4QxpHj2C4hjo+PT1k=";
  # i/o timeout
  doCheck = !stdenv.hostPlatform.isDarwin;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  # Based on ldflags in upstream's .goreleaser.yaml
  ldflags = [
    "-s"
    "-X main.version=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = "-V";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple tunnel written in golang";
    homepage = "https://github.com/go-gost/gost";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pmy
      ramblurr
      moraxyc
    ];

    mainProgram = "gost";
  };
})
