{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  bzip2,
  fetchpatch,
  libxcrypt,
  newt,
  openssl,
  pkg-config,
  slang,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "partimage";
  version = "0.6.9";

  src = fetchurl {
    url = "mirror://sourceforge/partimage/partimage-${finalAttrs.version}.tar.bz2";
    sha256 = "0db6xiphk6xnlpbxraiy31c5xzj0ql6k4rfkmqzh665yyj0nqfkm";
  };

  patches = [
    ./gentoos-zlib.patch
    (fetchpatch {
      name = "openssl-1.1.patch";
      sha256 = "1hs0krxrncxq1w36bhad02yk8yx71zcfs35cw87c82sl2sfwasjg";

      url =
        "https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-block/partimage/files/"
        + "partimage-0.6.9-openssl-1.1-compatibility.patch?id=3fe8e9910002b6523d995512a646b063565d0447";
    })
    (fetchpatch {
      sha256 = "0xid5636g58sxbhxnjmfjdy7y8rf3c77zmmpfbbqv4lv9jd2gmxm";
      url = "https://sources.debian.org/data/main/p/partimage/0.6.9-8/debian/patches/04-fix-FTBFS-glic-2.28.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    bzip2
    zlib
    newt
    newt
    openssl
    slang
    libxcrypt
  ];

  configureFlags = [ "--with-ssl-headers=${openssl.dev}/include/openssl" ];
  enableParallelBuilding = true;

  meta = {
    description = "Opensource disk backup software";
    homepage = "https://www.partimage.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
