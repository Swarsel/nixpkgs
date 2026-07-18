{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "dnslookup";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "ameshkov";
    repo = "dnslookup";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RxplKQ21mskowAoMpgl4OVRyO7y89XS9CDcFd0RZVIg=";
  };

  vendorHash = "sha256-DSicC/NbLOku7kYw1Ketur5qGk3Nh66Kj3NZoP7X524=";

  meta = {
    description = "Simple command line utility to make DNS lookups to the specified server";
    homepage = "https://github.com/ameshkov/dnslookup";
    changelog = "https://github.com/ameshkov/dnslookup/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.philiptaron ];
    mainProgram = "dnslookup";
  };
})
