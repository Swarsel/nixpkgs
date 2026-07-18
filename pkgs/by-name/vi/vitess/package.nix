{
  lib,
  fetchFromGitHub,
  buildGoModule,
  sqlite,
}:

buildGoModule (finalAttrs: {
  pname = "vitess";
  version = "23.0.3";

  src = fetchFromGitHub {
    owner = "vitessio";
    repo = "vitess";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cLpVpdYpMzJX5Y4RBuUp2SbedBHiqG+SRu8Oh+dowFY=";
  };

  buildInputs = [ sqlite ];
  vendorHash = "sha256-YhWa5eUeMCqmA+8Mi3lxQTSQ29xMpWWAb2BQPN1/+N8=";
  # integration tests require access to syslog and root
  doCheck = false;
  subPackages = [ "go/cmd/..." ];

  meta = {
    description = "Database clustering system for horizontal scaling of MySQL";
    homepage = "https://vitess.io/";
    changelog = "https://github.com/vitessio/vitess/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
