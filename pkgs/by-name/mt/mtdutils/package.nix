{
  lib,
  stdenv,
  acl,
  autoreconfHook,
  cmocka,
  fetchgit,
  libuuid,
  lzo,
  pkg-config,
  util-linux,
  zlib,
  zstd,
}:

stdenv.mkDerivation rec {
  pname = "mtd-utils";
  version = "2.3.1";

  src = fetchgit {
    url = "git://git.infradead.org/mtd-utils.git";
    rev = "v${version}";
    hash = "sha256-+2wHGgwWzjj3DRbU82MLvrwB7AtgMg+7m+0MwPE4V1o=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace ubifs-utils/mount.ubifs \
      --replace-fail "/bin/mount" "${util-linux}/bin/mount"
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ]
  ++ lib.optional doCheck cmocka;

  buildInputs = [
    acl
    libuuid
    lzo
    util-linux
    zlib
    zstd
  ];

  configureFlags = [
    (lib.enableFeature doCheck "unit-tests")
    (lib.enableFeature doCheck "tests")
  ];

  makeFlags = [ "AR:=$(AR)" ];
  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postInstall = ''
    mkdir -p $dev/lib
    mv *.a $dev/lib/
    mv include $dev/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Tools for MTD filesystems";
    homepage = "http://www.linux-mtd.infradead.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ skeuchel ];
    platforms = with lib.platforms; linux;
    downloadPage = "https://git.infradead.org/mtd-utils.git";
  };
}
