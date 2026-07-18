{
  lib,
  fetchurl,
  pname,
}:
rec {
  inherit pname;
  version = "4.3.7";

  src = fetchurl {
    url = "mirror://sourceforge/project/linux-gpib/linux-gpib%20for%203.x.x%20and%202.6.x%20kernels/${version}/linux-gpib-${version}.tar.gz";
    hash = "sha256-s/+BJgaGXIW1iwEqQhim/juC0XfIwKvHlcsi20HzrWg=";
  };

  sourceRoot = "${pname}-${version}";

  unpackPhase = ''
    tar xf $src
    tar xf linux-gpib-${version}/${pname}-${version}.tar.gz
  '';

  meta = {
    description = "Support package for GPIB (IEEE 488) hardware";
    homepage = "https://linux-gpib.sourceforge.io/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fsagbuya ];
    platforms = lib.platforms.linux;
  };
}
