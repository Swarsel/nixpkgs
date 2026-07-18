{
  lib,
  fetchurl,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "trinsic-cli";
  version = "1.14.0";

  src = fetchurl {
    url = "https://github.com/trinsic-id/sdk/releases/download/v${finalAttrs.version}/trinsic-cli-vendor-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-lPw55QcGMvY2YRYJGq4WC0fPbKiika4NF55tlb+i6So=";
  };

  doCheck = false;
  cargoVendorDir = "vendor";

  meta = {
    description = "Trinsic CLI";

    longDescription = ''
      Command line interface for Trinsic Ecosystems
    '';

    homepage = "https://trinsic.id/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tmarkovski ];
    mainProgram = "trinsic";
  };
})
