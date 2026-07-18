{
  lib,
  stdenv,
  fetchurl,
  liburcu,
  numactl,
  pkg-config,
  python3,
}:

# NOTE:
#   ./configure ...
#   [...]
#   LTTng-UST will be built with the following options:
#
#   Java support (JNI): Disabled
#   sdt.h integration:  Disabled
#   [...]
#
# Debian builds with std.h (systemtap).

stdenv.mkDerivation (finalAttrs: {
  pname = "lttng-ust";
  version = "2.12.2";

  src = fetchurl {
    url = "https://lttng.org/files/lttng-ust/lttng-ust-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-vNDwZLbKiMcthOdg6sNHKuXIKEEcY0Q1kivun841n8c=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    numactl
    python3
  ];

  propagatedBuildInputs = [ liburcu ];
  configureFlags = [ "--disable-examples" ];

  preConfigure = ''
    patchShebangs .
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "trivialautovarinit" ];

  meta = {
    description = "LTTng Userspace Tracer libraries";
    homepage = "https://lttng.org/";

    license = with lib.licenses; [
      lgpl21Only
      gpl2Only
      mit
    ];

    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.intersectLists lib.platforms.linux liburcu.meta.platforms;
    mainProgram = "lttng-gen-tp";
  };

})
