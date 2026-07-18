{
  lib,
  fetchFromGitHub,
  buildGoModule,
  risor,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "risor";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "risor-io";
    repo = "risor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SXUaSJmtWul4LYRdoxv4lXBB4HHp62xrWbEchI691YY=";
  };

  vendorHash = "sha256-WUvCzdDSsCan4K568k53oveYIzFQCxFi2B9gQEaeFEM=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/risor"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "risor version";
      package = risor;
    };
  };

  meta = {
    description = "Fast and flexible scripting for Go developers and DevOps";
    homepage = "https://github.com/risor-io/risor";
    changelog = "https://github.com/risor-io/risor/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "risor";
  };
})
