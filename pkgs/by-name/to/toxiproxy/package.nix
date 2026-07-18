{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  toxiproxy,
}:

buildGoModule (finalAttrs: {
  pname = "toxiproxy";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "Shopify";
    repo = "toxiproxy";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-CqJr3h2n+fzN6Ves38H7fYXd5vlpDVfF3kg4Tr8ThPc=";
  };

  vendorHash = "sha256-4nKWTjB9aV5ILgHVceV76Ip0byBxlEY5TTAQwNLvL2s=";

  checkFlags = [
    "-short"
    "-skip=TestVersionEndpointReturnsVersion|TestFullstreamLatencyBiasDown"
  ];

  postInstall = ''
    mv $out/bin/cli $out/bin/toxiproxy-cli
    mv $out/bin/server $out/bin/toxiproxy-server
  '';

  # Fixes tests on Darwin
  __darwinAllowLocalNetworking = true;
  excludedPackages = [ "test/e2e" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Shopify/toxiproxy/v2.Version=${finalAttrs.version}"
  ];

  passthru.tests = {
    cliVersion = testers.testVersion {
      inherit (finalAttrs) version;
      command = "${toxiproxy}/bin/toxiproxy-cli -version";
      package = toxiproxy;
    };

    serverVersion = testers.testVersion {
      inherit (finalAttrs) version;
      command = "${toxiproxy}/bin/toxiproxy-server -version";
      package = toxiproxy;
    };
  };

  meta = {
    description = "Proxy for for simulating network conditions";
    homepage = "https://github.com/Shopify/toxiproxy";
    changelog = "https://github.com/Shopify/toxiproxy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ avnik ];
  };
})
