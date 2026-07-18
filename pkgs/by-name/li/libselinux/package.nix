{
  lib,
  stdenv,
  fetchurl,
  fts,
  libsepol,
  pcre2,
  pkg-config,
  enablePython ? false,
  python3 ? null,
  python3Packages ? null,
  swig ? null,
}:

assert enablePython -> swig != null && python3 != null && !stdenv.hostPlatform.isStatic;

stdenv.mkDerivation (finalAttrs: {
  inherit (libsepol) se_url;
  pname = "libselinux";
  version = "3.10";

  src = fetchurl {
    url = "${finalAttrs.se_url}/${finalAttrs.version}/libselinux-${finalAttrs.version}.tar.gz";
    hash = "sha256-HvIWxbVvt+ClHNKQl4ehdaF+45HgRniUgHhzU56+dms=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
  ]
  ++ lib.optional enablePython "py";

  patches = [
    (fetchurl {
      hash = "sha256-RiEUibLVzfiRU6N/J187Cs1iPAih87gCZrlyRVI2abU=";
      url = "https://git.yoctoproject.org/meta-selinux/plain/recipes-security/selinux/libselinux/0003-libselinux-restore-drop-the-obsolete-LSF-transitiona.patch?id=62b9c816a5000dc01b28e78213bde26b58cbca9d";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    python3
  ]
  ++ lib.optionals enablePython [
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel
    swig
  ];

  buildInputs = [
    libsepol
    pcre2
    fts
  ]
  ++ lib.optionals enablePython [ python3 ];

  makeFlags = [
    "PREFIX=$(out)"
    "INCDIR=$(dev)/include/selinux"
    "INCLUDEDIR=$(dev)/include"
    "MAN3DIR=$(man)/share/man/man3"
    "MAN5DIR=$(man)/share/man/man5"
    "MAN8DIR=$(man)/share/man/man8"
    "SBINDIR=$(bin)/sbin"
    "SHLIBDIR=$(out)/lib"

    "LIBSEPOLA=${lib.getLib libsepol}/lib/libsepol.a"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
  ]
  ++ lib.optionals (fts != null) [
    "FTS_LDLIBS=-lfts"
  ]
  ++ lib.optionals stdenv.hostPlatform.isStatic [
    "DISABLE_SHARED=y"
  ]
  ++ lib.optionals enablePython [
    "PYTHON=${python3.pythonOnBuildForHost.interpreter}"
    "PYTHONLIBDIR=$(py)/${python3.sitePackages}"
    "PYTHON_SETUP_ARGS=--no-build-isolation"
  ];

  env = {
    NIX_CFLAGS_COMPILE = "-Wno-error -D_FILE_OFFSET_BITS=64";
  }
  //
    lib.optionalAttrs (stdenv.cc.bintools.isLLVM && lib.versionAtLeast stdenv.cc.bintools.version "17")
      {
        NIX_LDFLAGS = "--undefined-version";
      };

  preInstall = lib.optionalString enablePython ''
    mkdir -p $py/${python3.sitePackages}/selinux
  '';

  preFixup = lib.optionalString enablePython ''
    mv $out/${python3.sitePackages}/selinux/* $py/${python3.sitePackages}/selinux/
    rm -rf $out/lib/python*

    # We need to fix this symlink so it's named correctly for cross compiles.
    # e.g. the Makefile would put _selinux.cpython-313-x86_64-linux-gnu.so -> selinux/_selinux.cpython-313-x86_64-linux-gnu.so
    # here on a cross compile for aarch64, but put the aarch64 file in the selinux directory
    pushd .
    cd $py/${python3.sitePackages}
    [ -f "$(ls selinux/_selinux.*${stdenv.hostPlatform.extensions.sharedLibrary})" ] || {
      echo "selinux shared library not found!" >&2
      exit 1
    }
    rm -vf _selinux.*${stdenv.hostPlatform.extensions.sharedLibrary}
    ln -vsf selinux/_selinux.*${stdenv.hostPlatform.extensions.sharedLibrary}
    popd
  '';

  # drop fortify here since package uses it by default, leading to compile error:
  # command-line>:0:0: error: "_FORTIFY_SOURCE" redefined [-Werror]
  hardeningDisable = [ "fortify" ];
  installTargets = [ "install" ] ++ lib.optional enablePython "install-pywrap";

  meta = removeAttrs libsepol.meta [ "outputsToInstall" ] // {
    description = "SELinux core library";
  };
})
