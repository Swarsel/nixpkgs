{
  lib,
  fetchurl,
  buildOctavePackage,
  nettle,
  pkg-config,
}:

buildOctavePackage rec {
  pname = "general";
  version = "2.1.4";

  src = fetchurl {
    url = "mirror://sourceforge/octave/${pname}-${version}.tar.gz";
    sha256 = "sha256-sTd31PWTLmiR8qrBPaF/IrjJuLT/jtAXllnr0ZEkFI8=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    nettle
  ];

  meta = {
    description = "General tools for Octave";
    homepage = "https://gnu-octave.github.io/packages/general/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
