{
  lib,
  stdenv,
  fetchurl,
  readline,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lci";
  version = "0.6";

  src = fetchurl {
    url = "mirror://sourceforge/lci/lci-${finalAttrs.version}.tar.gz";
    sha256 = "204f1ca5e2f56247d71ab320246811c220ed511bf08c9cb7f305cf180a93948e";
  };

  buildInputs = [ readline ];

  meta = {
    description = "Lambda calculus interpreter";
    homepage = "https://www.chatzi.org/lci/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = with lib.platforms; linux;
    mainProgram = "lci";
  };
})
