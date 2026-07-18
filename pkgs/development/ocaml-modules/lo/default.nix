{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  fetchpatch,
  liblo,
}:

buildDunePackage (finalAttrs: {
  pname = "lo";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-lo";
    rev = "v${finalAttrs.version}";
    sha256 = "0mi8h6f6syxjkxz493l5c3l270pvxx33pz0k3v5465wqjsnppar2";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-Y5xewkKgTX9WIpbmVA9uA6N7KOPPhNguTWvowgoAcNU=";
      url = "https://github.com/savonet/ocaml-lo/commit/0b43bdf113c7e2c27d55c6a5f81f2fa4b30b5454.patch";
    })
  ];

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ liblo ];
  minimalOCamlVersion = "4.06";

  meta = {
    description = "Bindings for LO library";
    homepage = "https://github.com/savonet/ocaml-lo";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
