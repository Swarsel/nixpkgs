{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "dcrwallet";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "decred";
    repo = "dcrwallet";
    rev = "release-v${finalAttrs.version}";
    hash = "sha256-1PCxS67hXmwUD08OGyt6szVSgQ5M9e0j8ivNxmitfR8=";
  };

  vendorHash = "sha256-5rI6z7fC7jKPxovWp7nlZrR25NuUEz5obCn2HA6Crpk=";

  checkFlags = [
    # Test fails with:
    # 'x509_test.go:201: server did not report bad certificate error;
    # instead errored with [...] tls: unknown certificate authority (*url.Error)'
    "-skip=^TestUntrustedClientCert$"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Secure Decred wallet daemon written in Go (golang)";
    homepage = "https://decred.org";
    license = with lib.licenses; [ isc ];
    maintainers = with lib.maintainers; [ juaningan ];
    mainProgram = "dcrwallet";
  };
})
