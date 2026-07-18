{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dmidecode";
  version = "3.7";

  src = fetchurl {
    url = "mirror://savannah/dmidecode/dmidecode-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-LDrtEshaHmqUENQG1eQXxFVGbcG8fIkni7Ms98rZHoo=";
  };

  outputs = [
    "out"
    "man"
    "doc"
  ];

  makeFlags = [
    "prefix=$(out)"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  meta = {
    description = "Tool that reads information about your system's hardware from the BIOS according to the SMBIOS/DMI standard";
    homepage = "https://www.nongnu.org/dmidecode/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "dmidecode";
  };
})
