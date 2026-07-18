{
  lib,
  stdenv,
  fetchurl,
  ppp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pptpd";
  version = "1.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/poptop/pptpd/pptpd-${finalAttrs.version}/pptpd-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-anJChLHOAOoj99dgjQgYQ6EMio2H2VHLLqhucKobTnc=";
  };

  postPatch = ''
    substituteInPlace plugins/Makefile --replace-fail "install -o root" "install"
  '';

  buildInputs = [ ppp ];

  meta = {
    description = "PPTP Server for Linux";
    homepage = "https://poptop.sourceforge.net/dox/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ obadz ];
    platforms = lib.platforms.linux;
  };
})
