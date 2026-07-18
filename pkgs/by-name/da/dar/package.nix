{
  lib,
  stdenv,
  attr,
  bzip2,
  curl,
  e2fsprogs,
  fetchzip,
  gpgme,
  libargon2,
  libgcrypt,
  librsync,
  libthreadar,
  lz4,
  lzo,
  openssl,
  which,
  xz,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dar";
  version = "2.8.5";

  src = fetchzip {
    url = "mirror://sourceforge/dar/dar-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-VPBj5/e67DutuZOBBDkCbM9Hke7gZW8FpvgQH5hcXJ0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ which ];

  buildInputs = [
    curl
    librsync
    libthreadar
    gpgme
    libargon2
    libgcrypt
    openssl
    bzip2
    lz4
    lzo
    xz
    zlib
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    attr
    e2fsprogs
  ];

  configureFlags = [
    "--disable-birthtime"
    "--disable-upx"
    "--disable-dar-static"
    "--disable-build-html"
    "--enable-threadar"
  ];

  postInstall = ''
    # Disable html help
    rm -r "$out"/share/dar
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Disk ARchiver, allows backing up files into indexed archives";
    homepage = "http://dar.linux.free.fr";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ izorkin ];
    platforms = lib.platforms.unix;
  };
})
