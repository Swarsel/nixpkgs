{
  lib,
  bsdSetupHook,
  byacc,
  csu,
  defaultMakeFlags,
  flex,
  genassym,
  gencat,
  groff,
  headers,
  install,
  lorder,
  makeMinimal,
  mandoc,
  mkDerivation,
  netbsdSetupHook,
  rpcgen,
  statHook,
  tsort,
}:

mkDerivation {
  pname = "libcMinimal-netbsd";

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    # https://mail-index.netbsd.org/tech-toolchain/2024/06/24/msg004438.html
    #
    # The patch is vendored because the archive software inlined my
    # attachment so I am not sure how to programmatically download it.
    ./0001-Allow-building-libc-without-generating-tags.patch
  ];

  postPatch = ''
    sed -i 's,/usr\(/include/sys/syscall.h\),${headers}\1,g' lib/lib*/sys/Makefile.inc
  '';

  nativeBuildInputs = [
    bsdSetupHook
    netbsdSetupHook
    makeMinimal
    install
    tsort
    lorder
    mandoc
    groff
    statHook
    flex
    byacc
    gencat
  ];

  buildInputs = [
    headers
    csu
  ];

  makeFlags = defaultMakeFlags ++ [ "FILESDIR=$(out)/var/db" ];
  env.NIX_CFLAGS_COMPILE = "-B${csu}/lib -fcommon";

  postInstall = ''
    pushd ${headers}
    find include -type d -exec mkdir -p "$dev/{}" ';'
    find include '(' -type f -o -type l ')' -exec cp -pr "{}" "$dev/{}" ';'
    popd

    pushd ${csu}
    find lib -type d -exec mkdir -p "$out/{}" ';'
    find lib '(' -type f -o -type l ')' -exec cp -pr "{}" "$out/{}" ';'
    popd
  '';

  MKPICINSTALL = "yes";
  MKPROFILE = "no";
  MK_LIBC_TAGS = "no";
  NLSDIR = "$(out)/share/nls";
  SHLIBINSTALLDIR = "$(out)/lib";
  USE_FORT = "yes";

  extraPaths = [
    "common"
    "lib/i18n_module"
    "libexec/ld.elf_so"
    "sys"
    "external/bsd/jemalloc"
  ];

  noLibc = true;
  path = "lib/libc";
  meta.platforms = lib.platforms.netbsd;
}
