{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "benthos";
  version = "4.63.1";

  src = fetchFromGitHub {
    owner = "redpanda-data";
    repo = "benthos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dcVPTLzRVhyWEkzXfzQKOv7bfjzsxV7odcdPzLP64bQ=";
  };

  vendorHash = "sha256-WMnhjGgkIG+yz2SgKoibWSPdNbET7NxY87v5WtMDl8I=";

  #  doCheck = false;
  ldflags = [
    "-s"
    "-w"
    "-X github.com/redpanda-data/benthos/v4/internal/cli.Version=${finalAttrs.version}"
  ];

  proxyVendor = true;

  subPackages = [
    "cmd/benthos"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fancy stream processing made operationally mundane";
    homepage = "https://www.benthos.dev";
    changelog = "https://github.com/benthosdev/benthos/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sagikazarmark ];
    mainProgram = "benthos";
  };
})
