{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule rec {
  pname = "yeetgif";
  version = "1.23.6";

  src = fetchFromGitHub {
    owner = "sgreben";
    repo = "yeetgif";
    rev = version;
    hash = "sha256-Z05GhtEPj3PLXpjF1wK8+pNUY3oDjbwZWQsYlTX14Rc=";
  };

  patches = [
    # Add Go Modules support
    (fetchpatch {
      hash = "sha256-3eyqbpPyuQHjAN5mjQyZo0xY6L683T5Ytyx02II/iU4=";
      url = "https://github.com/sgreben/yeetgif/commit/5d2067b9832898c2b1ac51bf6a5f107619038270.patch";
    })
  ];

  vendorHash = "sha256-LhkOMCuYO4GHezk21SlI2dP1UPmBp4bv2SdNbUQMKsI=";
  deleteVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "GIF effects CLI";
    homepage = "https://github.com/sgreben/yeetgif";

    license = with lib.licenses; [
      mit
      asl20
      cc-by-nc-sa-40
    ];

    maintainers = with lib.maintainers; [ ajs124 ];
    mainProgram = "gif";
  };
}
