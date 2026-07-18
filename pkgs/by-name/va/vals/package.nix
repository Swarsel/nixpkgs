{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  vals,
}:

buildGoModule (finalAttrs: {
  pname = "vals";
  version = "0.44.4";

  src = fetchFromGitHub {
    owner = "helmfile";
    repo = "vals";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-R9TVsajh/IaXWAwdz2b85GuhNP9G/rP1CAxeMEqApt8=";
  };

  vendorHash = "sha256-xSeT1QnQBj66n9hexSxFi3NHdR2PArljJQqL9p6pdPc=";
  # Tests require connectivity to various backends.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  passthru.tests.version = testers.testVersion {
    command = "vals version";
    package = vals;
  };

  meta = {
    description = "Helm-like configuration values loader with support for various sources";
    homepage = "https://github.com/helmfile/vals";
    changelog = "https://github.com/helmfile/vals/releases/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stehessel ];
    mainProgram = "vals";
  };
})
