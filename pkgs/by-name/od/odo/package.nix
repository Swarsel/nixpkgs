{
  lib,
  fetchFromGitHub,
  buildGoModule,
  odo,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "odo";
  version = "3.16.1";

  src = fetchFromGitHub {
    owner = "redhat-developer";
    repo = "odo";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-zEN8yfjW3JHf6OzPQC6Rg2/hJ+3d9d2nYhz60BdSK9s=";
  };

  vendorHash = null;

  buildPhase = ''
    make bin
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -a odo $out/bin
  '';

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "odo version";
    package = odo;
  };

  meta = {
    description = "Developer-focused CLI for OpenShift and Kubernetes";
    homepage = "https://odo.dev";
    changelog = "https://github.com/redhat-developer/odo/releases/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stehessel ];
    mainProgram = "odo";
  };
})
