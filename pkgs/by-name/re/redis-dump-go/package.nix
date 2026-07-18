{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "redis-dump-go";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "yannh";
    repo = "redis-dump-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+5iYigtMQvd6D90mpKyMa7ZKm2UDtCG91uFZ7dURBT4=";
  };

  vendorHash = null;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Dump Redis keys to a file in RESP format using multiple connections";
    homepage = "https://github.com/yannh/redis-dump-go";
    changelog = "https://github.com/yannh/redis-dump-go/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.richiejp ];
  };
})
