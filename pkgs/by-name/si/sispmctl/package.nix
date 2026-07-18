{
  lib,
  stdenv,
  fetchurl,
  libusb-compat-0_1,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sispmctl";
  version = "4.12";

  src = fetchurl {
    url = "mirror://sourceforge/sispmctl/sispmctl-${finalAttrs.version}.tar.gz";
    hash = "sha256-51eGOkg42m4cpypXrcWspvxH/73ccqaQUtir10PVcII=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libusb-compat-0_1
  ];

  meta = {
    description = "USB controlled powerstrips management software";
    homepage = "https://sispmctl.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers._9R ];
    platforms = lib.platforms.unix;
    mainProgram = "sispmctl";
  };
})
