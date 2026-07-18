{
  lib,
  stdenv,
  fetchFromGitHub,
  aflplusplus,
  bison,
  flex,
  glib,
  pixman,
  pkg-config,
  python3,
}:

# this derivation assumes x86_64-linux
assert stdenv.targetPlatform.system == "x86_64-linux";

stdenv.mkDerivation {
  pname = "QEMU-Nyx";
  version = builtins.readFile (aflplusplus.src + "/nyx_mode/QEMU_NYX_VERSION");
  src = aflplusplus.src;

  nativeBuildInputs = [
    python3
    pkg-config
    flex
    bison
  ];

  buildInputs = [
    glib
    pixman
  ];

  # same flags for ./configure as ./compile_qemu_nyx.sh static would set
  configureFlags = [
    "--target-list=x86_64-softmmu"
    "--disable-docs"
    "--disable-gtk"
    "--disable-werror"
    "--disable-capstone"
    "--disable-libssh"
    "--disable-tools"
    "--enable-nyx"
    "--enable-nyx-static"
  ];

  preConfigure = ''
    CAPSTONE_ROOT=$PWD/capstone_v4
    LIBXDC_ROOT=$PWD/libxdc

    make -C $CAPSTONE_ROOT -j$(nproc)
    make -C $LIBXDC_ROOT -j$(nproc) clean

    # For some reason the Makefile of libxdc clears LDFLAGS; we remove that line
    # so ld can find libcapstone.so.4
    sed -i '3d' $LIBXDC_ROOT/Makefile

    NO_LTO=1 LDFLAGS="-L$CAPSTONE_ROOT -L$LIBXDC_ROOT" CFLAGS="-I$CAPSTONE_ROOT/include/" make -C $LIBXDC_ROOT -j$(nproc)

    export LIBS="-L$CAPSTONE_ROOT -L$LIBXDC_ROOT/"
    export QEMU_CFLAGS="-I$CAPSTONE_ROOT/include/ -I$LIBXDC_ROOT/ $QEMU_CFLAGS"
  '';

  enableParallelBuilding = true;

  postUnpack = ''
    sourceRoot="$sourceRoot/nyx_mode/QEMU-Nyx"
  '';

  meta = {
    description = "Nyx's fork of QEMU";
    homepage = "https://github.com/nyx-fuzz/QEMU-Nyx";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ekzyis ];
    platforms = lib.platforms.x86_64;
  };
}
