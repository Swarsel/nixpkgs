{
  lib,
  stdenv,
  fetchurl,
  e2fsprogs,
  fetchpatch,
  pam,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pam_mktemp";
  version = "1.1.1";

  src = fetchurl {
    url = "https://openwall.com/pam/modules/pam_mktemp/pam_mktemp-${finalAttrs.version}.tar.gz";
    hash = "sha256-Zs+AwYQ5yjRW25ZALy7qwUsaBQPMHRvn8rFtXwefPz0=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-xe44fi2xH9jqlStlIR4QPB0KS7spflRdOsvNPEmxJpU";
      name = "inherit_private_prefix_from_home.patch";
      url = "https://git.altlinux.org/gears/p/pam_mktemp.git?p=pam_mktemp.git;a=commitdiff_plain;h=3d2e8ad6da6a44c047bf7a8afa1e1bb2a6e36a55";
    })
    (fetchpatch {
      hash = "sha256-TouysUVlNnl+m7lJ2VKPxUTYD2om1Jh5FEJ6NHMAI4U=";
      name = "allow_private_prefix_to_be_stricter.patch";
      url = "https://git.altlinux.org/gears/p/pam_mktemp.git?p=pam_mktemp.git;a=commitdiff_plain;h=bb2cee0c695d22310e5364c30d74bccb0dbf3205";
    })
  ];

  buildInputs = [
    pam
    e2fsprogs
  ];

  makeFlags = [ "DESTDIR=$(out)" ];
  dontConfigure = true;
  enableParallelBuilding = true;
  patchFlags = "-p2";

  meta = {
    description = "PAM for login service to provide per-user private directories";
    homepage = "https://www.openwall.com/pam/";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ wladmis ];
    platforms = lib.platforms.linux;
  };
})
