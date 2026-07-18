{
  lib,
  fetchFromGitHub,
  adrgen,
  buildGoModule,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "adrgen";
  version = "0.4.1-beta";

  src = fetchFromGitHub {
    owner = "asiermarques";
    repo = "adrgen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9EiJe5shhwbjLIvUQMUTSGTgCA+r3RdkLkPRPoWvZ3g=";
  };

  vendorHash = "sha256-RXwwv3Q/kQ6FondpiUm5XZogAVK2aaVmKu4hfr+AnAM=";

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "adrgen version";
    package = adrgen;
  };

  meta = {
    description = "Command-line tool for generating and managing Architecture Decision Records";
    homepage = "https://github.com/asiermarques/adrgen";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "adrgen";
  };
})
