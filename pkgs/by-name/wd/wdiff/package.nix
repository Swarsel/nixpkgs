{
  lib,
  stdenv,
  fetchurl,
  texinfo,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wdiff";
  version = "1.2.2";

  src = fetchurl {
    url = "mirror://gnu/wdiff/wdiff-${finalAttrs.version}.tar.gz";
    sha256 = "0sxgg0ms5lhi4aqqvz1rj4s77yi9wymfm3l3gbjfd1qchy66kzrl";
  };

  strictDeps = true;
  # for makeinfo
  nativeBuildInputs = [ texinfo ];
  buildInputs = [ texinfo ];
  nativeCheckInputs = [ which ];

  meta = {
    description = "Comparing files on a word by word basis";
    homepage = "https://www.gnu.org/software/wdiff/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    platforms = lib.platforms.unix;
    mainProgram = "wdiff";
  };
})
