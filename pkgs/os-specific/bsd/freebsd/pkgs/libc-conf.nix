{
  mkDerivation,
}:
mkDerivation {
  postPatch = ''
    sed -E -i -e '/afterinstallconfig/d' -e '/master.passwd/d' "lib/libc/gen/Makefile.inc"
  '';

  MK_TESTS = "no";
  dontBuild = true;

  extraPaths = [
    "lib/libc_nonshared"
    "lib/libsys"
    "sys/sys"
  ];

  installTargets = [ "installconfig" ];
  path = "lib/libc";
}
