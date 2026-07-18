{
  lib,
  buildPackages,
  mkDerivation,
  mtree,
  rpcgen,
}:

mkDerivation {
  # The makefiles define INCSDIR per subdirectory, so we have to set
  # something else on the command line so those definitions aren't
  # overridden.
  postPatch = ''
    find "$BSDSRCDIR" -name Makefile -exec \
      sed -i -E \
        -e 's_/usr/include_''${INCSDIR0}_' \
        {} \;
    sed -E -i -e "/_PATH_LOGIN/d" $BSDSRCDIR/include/paths.h
  '';

  makeFlags = [ "RPCGEN_CPP=${buildPackages.stdenv.cc.cc}/bin/cpp" ];

  # multiple header dirs, see above
  postConfigure = ''
    makeFlags=''${makeFlags/INCSDIR/INCSDIR0}
  '';

  MK_HESIOD = "yes";

  extraNativeBuildInputs = [
    rpcgen
    mtree
  ];

  extraPaths = [
    "contrib/libc-vis"
    "etc/mtree/BSD.include.dist"
    "sys"
    # Used for aarch64-freebsd
    "lib/msun/arm"
  ];

  headersOnly = true;
  noLibc = true;
  path = "include";
  meta.platforms = lib.platforms.freebsd;
}
