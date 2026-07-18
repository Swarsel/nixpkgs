{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "surfboard_exporter";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ipstatic";
    repo = "surfboard_exporter";
    rev = finalAttrs.version;
    sha256 = "11qms26648nwlwslnaflinxcr5rnp55s908rm1qpnbz0jnxf5ipw";
  };

  patches = [
    ./add-go-mod.patch
  ];

  vendorHash = null;
  passthru.tests = { inherit (nixosTests.prometheus-exporters) surfboard; };

  meta = {
    description = "Arris Surfboard signal metrics exporter";
    homepage = "https://github.com/ipstatic/surfboard_exporter";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "surfboard_exporter";
  };
})
