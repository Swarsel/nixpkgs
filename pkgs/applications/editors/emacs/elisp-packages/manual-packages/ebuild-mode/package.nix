{
  lib,
  fetchzip,
  melpaBuild,
}:

melpaBuild (finalAttrs: {
  pname = "ebuild-mode";
  version = "1.84";

  src = fetchzip {
    url = "https://gitweb.gentoo.org/proj/ebuild-mode.git/snapshot/ebuild-mode-${finalAttrs.version}.tar.bz2";
    hash = "sha256-+WbKgOR0eCIvBgQrXzVOk8k2mV7INObY59vc46KvMYo=";
  };

  meta = {
    description = "Major modes for Gentoo package files";
    homepage = "https://gitweb.gentoo.org/proj/ebuild-mode.git/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
})
