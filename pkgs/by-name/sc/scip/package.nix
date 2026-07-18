{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  iana-etc,
  libredirect,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "scip";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "scip-code";
    repo = "scip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3iUDxZAde1aVpZNFKvuITHg/b+3+sXHQvmjq/f6AIzM=";
  };

  vendorHash = "sha256-p4/YFp+FY83c0HO+8DBI8qQu4EV0DbXa2rEdfkgfsI4=";
  env.GOWORK = "off";
  nativeCheckInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libredirect.hook ];

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/services=${iana-etc}/etc/services
  '';

  doInstallCheck = stdenv.hostPlatform.isLinux;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-X=main.Reproducible=true"
  ];

  subPackages = [ "cmd/scip" ];

  meta = {
    description = "SCIP Code Intelligence Protocol CLI";
    homepage = "https://github.com/scip-code/scip";
    changelog = "https://github.com/scip-code/scip/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nicolas-guichard ];
    mainProgram = "scip";
  };
})
