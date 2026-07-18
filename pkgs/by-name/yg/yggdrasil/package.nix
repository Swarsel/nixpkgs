{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "yggdrasil";
  version = "0.5.14";

  src = fetchFromGitHub {
    owner = "yggdrasil-network";
    repo = "yggdrasil-go";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bjyn8p7hu1QYGjfB73g/1pbfaG65u/fBsBXdkq4xqgA=";
  };

  vendorHash = "sha256-viQ70685CpvxK/lXu/2hQEebcX0Xu7g+tlSNXayArEM=";

  ldflags = [
    "-X github.com/yggdrasil-network/yggdrasil-go/src/version.buildVersion=${finalAttrs.version}"
    "-X github.com/yggdrasil-network/yggdrasil-go/src/version.buildName=yggdrasil"
    "-X github.com/yggdrasil-network/yggdrasil-go/src/config.defaultAdminListen=unix:///var/run/yggdrasil/yggdrasil.sock"
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/genkeys"
    "cmd/yggdrasil"
    "cmd/yggdrasilctl"
  ];

  passthru.tests.basic = nixosTests.yggdrasil;

  meta = {
    description = "Experiment in scalable routing as an encrypted IPv6 overlay network";
    homepage = "https://yggdrasil-network.github.io/";
    license = lib.licenses.lgpl3;

    maintainers = with lib.maintainers; [
      gazally
      lassulus
      peigongdsd
    ];

    mainProgram = "yggdrasil";
  };
})
