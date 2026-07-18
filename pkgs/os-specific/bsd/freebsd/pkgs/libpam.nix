{
  libradius,
  libutil,
  mkDerivation,
  openssl,
  pwd_mkdb,
}:
mkDerivation {
  # TODO
  postPatch = ''
    sed -E -i -e /pam_tacplus/d $BSDSRCDIR/lib/libpam/modules/modules.inc
    sed -E -i -e /pam_krb5/d $BSDSRCDIR/lib/libpam/modules/modules.inc
    sed -E -i -e /pam_ksu/d $BSDSRCDIR/lib/libpam/modules/modules.inc
    sed -E -i -e /pam_ssh/d $BSDSRCDIR/lib/libpam/modules/modules.inc
  '';

  buildInputs = [
    libradius
    openssl
    (libutil.override {
      withPwdMkdb = pwd_mkdb;
    })
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I$BSDSRCDIR/lib/libpam/libpam -DOPENPAM_MODULES_DIRECTORY=\"$out/lib\""
  '';

  postInstall = ''
    make $makeFlags installconfig

    export NIX_LDFLAGS="$NIX_LDFLAGS -L$out/lib"
    make -C $BSDSRCDIR/lib/libpam/modules $makeFlags
    make -C $BSDSRCDIR/lib/libpam/modules $makeFlags install
    make -C $BSDSRCDIR/lib/libpam/modules $makeFlags installconfig
  '';

  MK_NIS = "no"; # TODO
  MK_TESTS = "no";

  extraPaths = [
    "lib/libpam"
    "contrib/openpam"
    "lib/Makefile.inc"
    "contrib/pam_modules"
    "crypto/openssh"
  ];

  path = "lib/libpam/libpam";
}
