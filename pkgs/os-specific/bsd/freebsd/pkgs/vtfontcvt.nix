{ mkDerivation }:
mkDerivation {
  NIX_CFLAGS_COMPILE = [
    "-Wno-unterminated-string-initialization"
  ];

  extraPaths = [ "sys/cddl/contrib/opensolaris/common/lz4" ];
  path = "usr.bin/vtfontcvt";
}
