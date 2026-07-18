{
  lib,
  fetchurl,
  clangStdenv,
  libevent,
}:
# Use clang instead of gcc because that issues way less warnings.
# Besides, OpenBSD devs generally prefer clang over gcc, so it is more likely
# that the entire compilation is more tested using clang from an upstream POV.
clangStdenv.mkDerivation (finalAttrs: {
  pname = "openbgpd";
  version = "9.1";

  src = fetchurl {
    url = "mirror://openbsd/OpenBGPD/openbgpd-${finalAttrs.version}.tar.gz";
    hash = "sha256-GUUYWBGdRplN/4zyfQYzMpzULyi6Oou1pfz0Zexem8M=";
  };

  buildInputs = [
    libevent
  ];

  meta = {
    description = "Free implementation of the Border Gateway Protocol, Version 4. It allows ordinary machines to be used as routers exchanging routes with other systems speaking the BGP protocol";
    homepage = "http://www.openbgpd.org/";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ cvengler ];
    platforms = lib.platforms.linux;
  };
})
