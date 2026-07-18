{
  lib,
  fetchFromGitHub,
  buildGoModule,
  mockgen,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "terragrunt";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "gruntwork-io";
    repo = "terragrunt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uOX+PTNL6VPu+QN9RiWNonV+WRWYNEadRLvljy49M5Q=";
  };

  nativeBuildInputs = [
    mockgen
  ];

  vendorHash = "sha256-LqkHHkX1kMuF4XtpxFPc6Xwas4B+jSMfMxSyv1nzerc=";

  preBuild = ''
    make generate-mocks
  '';

  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  excludedPackages = [ "test/flake" ];

  ldflags = [
    "-s"
    "-X github.com/gruntwork-io/go-commons/version.Version=v${finalAttrs.version}"
    "-extldflags '-static'"
  ];

  proxyVendor = true;
  versionCheckProgramArg = "--version";

  meta = {
    description = "Thin wrapper for Terraform that supports locking for Terraform state and enforces best practices";
    homepage = "https://terragrunt.gruntwork.io";
    changelog = "https://github.com/gruntwork-io/terragrunt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jk
      qjoly
      kashw2
    ];

    mainProgram = "terragrunt";
  };
})
