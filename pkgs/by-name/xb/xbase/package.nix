{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xbase";
  version = "3.1.2";

  src = fetchurl {
    url = "mirror://sourceforge/xdb/xbase64-${finalAttrs.version}.tar.gz";
    sha256 = "17287kz1nmmm64y7zp9nhhl7slzlba09h6cc83w4mvsqwd9w882r";
  };

  patches = [
    ./xbase-fixes.patch
    (fetchurl {
      sha256 = "1kpcrkkcqdwl609yd0qxlvp743icz3vni13993sz6fkgn5lah8yl";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-db/xbase/files/xbase-3.1.2-gcc47.patch?id=0b9005ad4b5b743707922877e5157ba6ecdf224f";
    })
    (fetchurl {
      sha256 = "1994pqiip5njkcmm5czb1bg6zdldkx1mpandgmvzqrja0iacf953";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-db/xbase/files/xbase-3.1.2-gcc6.patch?id=0b9005ad4b5b743707922877e5157ba6ecdf224f";
    })
    (fetchurl {
      sha256 = "1304gn9dbdv8xf61crkg0fc8cal0h4qkyhlbqa8y618w134cxh1q";
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-db/xbase/files/xbase-3.1.2-gcc7.patch?id=0b9005ad4b5b743707922877e5157ba6ecdf224f";
    })
  ];

  postPatch = ''
    sed -i '1i#include <cstdarg>' xbase64/xbstring.cpp
  '';

  prePatch = "find . -type f -not -name configure -print0 | xargs -0 chmod -x";

  meta = {
    description = "C++ class library formerly known as XDB";
    homepage = "https://sourceforge.net/projects/xdb/";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = lib.platforms.linux;
  };
})
