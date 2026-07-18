{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:
buildGoModule (finalAttrs: {
  pname = "litestream";
  version = "0.5.11";

  src = fetchFromGitHub {
    owner = "benbjohnson";
    repo = "litestream";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LGlcc/FoBiZ7YiZUyqdYmAoV9BgUm4h2/n/KQ3NzFa4=";
  };

  vendorHash = "sha256-Zf7BdL0mljGFrRTx4JJxAUXUm6Uh/sVJP/zOJ4ef/CU=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.tests = { inherit (nixosTests) litestream; };

  meta = {
    description = "Streaming replication for SQLite";
    homepage = "https://litestream.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fbrs ];
    mainProgram = "litestream";
  };
})
