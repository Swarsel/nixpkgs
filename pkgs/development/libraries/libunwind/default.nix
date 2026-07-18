{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
  testers,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libunwind";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "libunwind";
    repo = "libunwind";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ed+FUPApDxNHxznXMhiTeNr8yRxRDSCyJJdIhouGNho=";
  };

  outputs = [
    "out"
    "dev"
    "devman"
  ];

  postPatch =
    if (stdenv.cc.isClang || stdenv.hostPlatform.isStatic) then
      ''
        substituteInPlace configure.ac --replace "-lgcc_s" ""
      ''
    else
      lib.optionalString stdenv.hostPlatform.isMusl ''
        substituteInPlace configure.ac --replace "-lgcc_s" "-lgcc_eh"
      '';

  nativeBuildInputs = [ autoreconfHook ];
  propagatedBuildInputs = [ xz ];

  configureFlags = [
    # Starting from 1.8.1 libunwind installs testsuite by default.
    # As we don't run the tests we disable it (this also fixes circular
    # reference install failure).
    "--disable-tests"
    # Without latex2man, no man pages are installed despite being
    # prebuilt in the source tarball.
    "LATEX2MAN=${buildPackages.coreutils}/bin/true"
  ];

  doCheck = false; # fails

  postInstall = ''
    find $out -name \*.la | while read file; do
      sed -i 's,-llzma,${xz.out}/lib/liblzma.la,' $file
    done
  '';

  enableParallelBuilding = true;

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    versionCheck = true;
  };

  meta = {
    description = "Portable and efficient API to determine the call-chain of a program";
    homepage = "https://www.nongnu.org/libunwind";
    license = lib.licenses.mit;
    maintainers = [ ];

    # https://github.com/libunwind/libunwind#libunwind
    platforms = [
      "aarch64-linux"
      "armv5tel-linux"
      "armv6l-linux"
      "armv7a-linux"
      "armv7l-linux"
      "i686-freebsd"
      "i686-linux"
      "loongarch64-linux"
      "mips64el-linux"
      "mipsel-linux"
      "powerpc-linux"
      "powerpc64-linux"
      "powerpc64le-linux"
      "riscv64-linux"
      "s390x-linux"
      "x86_64-freebsd"
      "x86_64-linux"
      "x86_64-solaris"
    ];

    pkgConfigModules = [
      "libunwind"
      "libunwind-coredump"
      "libunwind-generic"
      "libunwind-ptrace"
      "libunwind-setjmp"
    ];
  };
})
