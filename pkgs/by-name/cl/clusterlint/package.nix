{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "clusterlint";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "digitalocean";
    repo = "clusterlint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6QgWWSiwVZv8rYJNvfzxNsrxCqJbR/MBcCr3ESrO6Fc=";
  };

  vendorHash = null;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # One subpackage fails to build
  excludedPackages = [ "example-plugin" ];
  ldflags = [ "-X main.Version=${finalAttrs.version}" ];

  meta = {
    description = "Best practices checker for Kubernetes clusters";
    homepage = "https://github.com/digitalocean/clusterlint";
    changelog = "https://github.com/digitalocean/clusterlint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jherland ];
    mainProgram = "clusterlint";
  };
})
