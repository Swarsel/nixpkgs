{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitea,
  nixosTests,
  sqlite,
}:

buildGoModule (finalAttrs: {
  pname = "magnetico";
  version = "0.13.0";

  src = fetchFromGitea {
    owner = "rnhmjoj";
    repo = "magnetico";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TqzsgUSPIBQT+k+ZrJPkF7uIt8o018ZN5p8nHom8cXM=";
    domain = "maxwell.eurofusion.eu/git";
  };

  buildInputs = [ sqlite ];
  vendorHash = "sha256-ZUtmQib6BD7P07ALYXKp/JAQodYnQCuvWZnWl9888Mg=";
  doCheck = !stdenv.hostPlatform.isStatic;

  ldflags = [
    "-s"
    "-w"
  ];

  tags = [
    "fts5"
    "libsqlite3"
  ];

  passthru.tests = { inherit (nixosTests) magnetico; };

  meta = {
    description = "Autonomous (self-hosted) BitTorrent DHT search engine suite";
    homepage = "https://maxwell.eurofusion.eu/git/rnhmjoj/magnetico";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    badPlatforms = lib.platforms.darwin;
  };
})
