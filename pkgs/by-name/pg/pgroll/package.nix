{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libpg_query,
  testers,
  xxhash,
}:

buildGoModule (finalAttrs: {
  pname = "pgroll";
  version = "0.16.2";

  src = fetchFromGitHub {
    owner = "xataio";
    repo = "pgroll";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pvc+hKWUY8OPKMU4QNwuTlw8ewhiDrFcS1q/hcOzqSk=";
  };

  buildInputs = [
    libpg_query
    xxhash
  ];

  vendorHash = "sha256-/oEZbST2Q2HG+qu8nH+mdk/U58aTMznndDHDbFg8fCk=";
  # Tests require a running docker daemon
  doCheck = false;

  excludedPackages = [
    "dev"
    "tools"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/xataio/pgroll/cmd.Version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "PostgreSQL zero-downtime migrations made easy";
    homepage = "https://github.com/xataio/pgroll";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ilyakooo0 ];
    mainProgram = "pgroll";
  };
})
