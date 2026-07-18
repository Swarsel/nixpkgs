{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kmod,
  patchutils,
  perlPackages,
}:
let

  media = fetchFromGitHub rec {
    hash = "sha256-tq92yqJVJgAYy7PTY/nk0Q6sWJ0kdSrw38JEOOhfwGQ=";
    name = repo;
    owner = "tbsdtv";
    repo = "linux_media";
    rev = "3f1faba3930568fd2d472a2fe8c57af8d7084672";
  };

  build = fetchFromGitHub rec {
    hash = "sha256-P0ASmWro3j3dk7LZQbUKXcGL+2c9fdjM7RgEfk0iDMs=";
    name = repo;
    owner = "tbsdtv";
    repo = "media_build";
    rev = "bc02baf59046b02e3eb71653d8aa8d98e79dc4e1";
  };

in
stdenv.mkDerivation {
  pname = "tbs";
  version = "20250510-${kernel.version}";

  postPatch = ''
    patchShebangs .

    sed -i v4l/Makefile \
      -i v4l/scripts/make_makefile.pl \
      -e 's,/sbin/depmod,${kmod}/bin/depmod,g' \
      -e 's,/sbin/lsmod,${kmod}/bin/lsmod,g'

    sed -i v4l/Makefile \
      -e 's,^OUTDIR ?= /lib/modules,OUTDIR ?= ${kernel.dev}/lib/modules,' \
      -e 's,^SRCDIR ?= /lib/modules,SRCDIR ?= ${kernel.dev}/lib/modules,'
  '';

  nativeBuildInputs = [
    patchutils
    kmod
    perlPackages.ProcProcessTable
  ]
  ++ kernel.moduleBuildDependencies;

  buildFlags = [ "VER=${kernel.modDirVersion}" ];

  # https://github.com/tbsdtv/linux_media/wiki
  preConfigure = ''
    make dir DIR=../${media.name}
    make allyesconfig
    sed --regexp-extended --in-place v4l/.config \
      -e 's/(^CONFIG.*_RC.*=)./\1n/g' \
      -e 's/(^CONFIG.*_IR.*=)./\1n/g' \
      -e 's/(^CONFIG_VIDEO_VIA_CAMERA=)./\1n/g'
  '';

  postInstall = ''
    find $out/lib/modules/${kernel.modDirVersion} -name "*.ko" -exec xz {} \;
  '';

  hardeningDisable = [ "pic" ];
  installFlags = [ "DESTDIR=$(out)" ];
  sourceRoot = build.name;

  srcs = [
    media
    build
  ];

  meta = {
    description = "Linux driver for TBSDTV cards";
    homepage = "https://www.tbsdtv.com/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ck3d ];
    broken = kernel.kernelOlder "4.19" || kernel.kernelAtLeast "6.15";
    priority = -1;
  };
}
