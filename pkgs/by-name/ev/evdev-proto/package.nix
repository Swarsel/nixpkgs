{
  lib,
  stdenv,
  buildPackages,
  freebsd,
  linuxHeaders,
  runCommandCC,
}:

stdenv.mkDerivation {
  inherit (linuxHeaders) version;
  pname = "evdev-proto";
  src = freebsd.ports;
  nativeBuildInputs = [ freebsd.makeMinimal ];
  makeFlags = [ "DIST_SUBDIR=evdev-proto" ];

  env = {
    ABI_FILE = runCommandCC "abifile" { } "$CC -shared -o $out";
    ARCH = freebsd.makeMinimal.MACHINE_ARCH;
    AWK = "awk";
    CHMOD = "chmod";
    CLEAN_FETCH_ENV = true;
    FIND = "find";
    INSTALL_AS_USER = true;
    MKDIR = "mkdir -p";
    NO_CHECKSUM = true;
    NO_MTREE = true;
    OPSYS = "FreeBSD";
    PKG_BIN = "${buildPackages.pkg}/bin/pkg";
    RM = "rm -f";
    SED = "${buildPackages.freebsd.sed}/bin/sed";
    SETENV = "env";
    SH = "sh";
    SRC_BASE = freebsd.source;
    TOUCH = "touch";
    XARGS = "xargs";
    _OSRELEASE = "${lib.versions.majorMinor freebsd.makeMinimal.version}-RELEASE";
  };

  postInstall = ''
    mv $prefix $out
  '';

  preUnpack = ''
    export MAKE_JOBS_NUMBER="$NIX_BUILD_CORES"

    export DISTDIR="$PWD/distfiles"
    export PKG_DBDIR="$PWD/pkg"
    export PREFIX="$prefix"

    mkdir -p "$DISTDIR/evdev-proto"
    tar -C "$DISTDIR/evdev-proto" \
        -xf ${linuxHeaders.src} \
        --strip-components 4 \
        linux-${linuxHeaders.version}/include/uapi/linux
  '';

  sourceRoot = "${freebsd.ports.name}/devel/evdev-proto";
  useTempPrefix = true;

  meta = {
    description = "Input event device header files for FreeBSD";
    homepage = "https://cgit.freebsd.org/ports";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = lib.platforms.freebsd;
  };
}
