{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
  libpcap,
}:

buildGoModule (finalAttrs: {
  pname = "goreplay";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "probelabs";
    repo = "goreplay";
    rev = finalAttrs.version;
    sha256 = "sha256-FiY9e5FgpPu+K8eoO8TsU3xSaSoPPDxYEu0oi/S8Q1w=";
  };

  patches = [
    # Fix build on arm64-linux, see https://github.com/probelabs/goreplay/pull/1140
    (fetchpatch {
      sha256 = "sha256-w3aVe/Fucwd2OuK5Fu2jJTbmMci8ilWaIjYjsWuLRlo=";
      url = "https://github.com/probelabs/goreplay/commit/a01afa1e322ef06f36995abc3fda3297bdaf0140.patch";
    })
  ];

  buildInputs = [ libpcap ];
  vendorHash = "sha256-jDMAtcq3ZowFdky5BdTkVNxq4ltkhklr76nXYJgGALg=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Open-source tool for capturing and replaying live HTTP traffic";
    homepage = "https://github.com/probelabs/goreplay";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
    mainProgram = "goreplay";
  };
})
