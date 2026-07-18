{
  lib,
  stdenv,
  fetchurl,
  bashNonInteractive,
  # for passthru.tests
  bind,
  byacc, # can also use bison, but byacc has fewer dependencies
  curl,
  darwin,
  fetchpatch,
  keyutils,
  libedit,
  libverto,
  nixosTests,
  openldap,
  openssh,
  openssl,
  perl,
  pkg-config,
  postgresql,
  python3,
  # This is called "staticOnly" because krb5 does not support
  # builting both static and shared, see below.
  staticOnly ? false,
  # Extra Arguments
  withLdap ? false,
  withLibedit ? true,
  withVerto ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krb5";
  version = "1.22.2";

  src = fetchurl {
    url = "https://kerberos.org/dist/krb5/${lib.versions.majorMinor finalAttrs.version}/krb5-${finalAttrs.version}.tar.gz";
    hash = "sha256-MkP/vI6k1Kwi3cfdKh3FTFeHTEBki2D/lwCXY1VOrxM=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  patches = [
    # https://github.com/krb5/krb5/pull/1505
    ./CVE-2026-11850.patch
    # https://github.com/krb5/krb5/pull/1506
    ./CVE-2026-40355-and-CVE-2026-40356.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-l8ev+WrDKbTqwgBRYhfJGELkCCE8mJTqVHFBvvCPvgE=";
      name = "fix-missing-ENODATA.patch";
      url = "https://cgit.freebsd.org/ports/plain/security/krb5-122/files/patch-lib_krad_packet.c?id=0501f716c4aff7880fde56e42d641ef504593b7d";
    })
  ];

  postPatch = ''
    substituteInPlace config/shlib.conf \
      --replace "'ld " "'${stdenv.cc.targetPrefix}ld "
  ''
  # this could be accomplished by updateAutotoolsGnuConfigScriptsHook, but that causes infinite recursion
  # necessary for FreeBSD code path in configure
  + ''
    substituteInPlace ./config/config.guess --replace-fail /usr/bin/uname uname
  '';

  strictDeps = true;

  nativeBuildInputs = [
    byacc
    perl
    pkg-config
  ]
  # Provides the mig command used by the build scripts
  ++ lib.optional stdenv.hostPlatform.isDarwin darwin.bootstrap_cmds;

  buildInputs = [
    openssl
    bashNonInteractive # cannot use bashInteractive because of a dependency cycle
  ]
  ++ lib.optionals (
    stdenv.hostPlatform.isLinux
    && stdenv.hostPlatform.libc != "bionic"
    && !(stdenv.hostPlatform.useLLVM or false)
  ) [ keyutils ]
  ++ lib.optionals withLdap [ openldap ]
  ++ lib.optionals withLibedit [ libedit ]
  ++ lib.optionals withVerto [ libverto ];

  configureFlags = [
    "--localstatedir=/var/lib"
    (lib.withFeature withLdap "ldap")
    (lib.withFeature withLibedit "libedit")
    (lib.withFeature withVerto "system-verto")
  ]
  # krb5's ./configure does not allow passing --enable-shared and --enable-static at the same time.
  # See https://bbs.archlinux.org/viewtopic.php?pid=1576737#p1576737
  ++ lib.optionals staticOnly [
    "--enable-static"
    "--disable-shared"
  ]
  ++ lib.optional stdenv.hostPlatform.isFreeBSD "WARN_CFLAGS="
  ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "krb5_cv_attr_constructor_destructor=yes,yes"
    "ac_cv_func_regcomp=yes"
    "ac_cv_printf_positional=yes"
  ];

  env = {
    # The release 1.21.3 is not compatible with c23, which changed the meaning of
    #
    #     void foo();
    #
    # declaration.
    NIX_CFLAGS_COMPILE = "-std=gnu17" + lib.optionalString stdenv.hostPlatform.isStatic " -fcommon";
  };

  # To avoid cyclic outputs, we can't let lib depend on out in any way. Unfortunately, the configure
  # options don't give us enough granularity to specify that, so we have to override the generated
  # Makefiles manually.
  postConfigure = ''
    find "''${libFolders[@]}" -type f -name Makefile -print0 | while IFS= read -rd "" f; do
      substituteInPlace "$f" --replace-fail "$out" "$lib"
    done
  '';

  doCheck = false; # fails with "No suitable file for testing purposes"

  preInstall = ''
    mkdir -p "$lib"/{bin,sbin,lib/pkgconfig,share/{et,man/man1}}
  '';

  postInstall = ''
    # not via outputBin, due to reference from libkrb5.so
    moveToOutput bin/krb5-config "$dev"
    moveToOutput sbin/krb5-send-pr "$out"
    moveToOutput bin/compile_et "$out"
  '';

  # Disable _multioutDocs in stdenv by overriding it to be a no-op.
  # We do this because $lib has its own docs and we don't want to squash them into $out.
  preFixup = ''
    _multioutDocs() {
      echo Skipping multioutDocs
    }
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  libFolders = [
    "util"
    "include"
    "lib"
    "build-tools"
  ];

  outputChecks.lib.disallowedRequisites = [
    # bash cannot be here because of a dependency cycle
    bashNonInteractive
  ];

  # While "out" acts as the bin output, most packages only care about the lib output.
  # We set prefix such that all the pkg-config configuration stays inside the dev and lib outputs.
  # stdenv will take care of overriding bindir, sbindir, etc. such that "out" contains the binaries.
  prefix = placeholder "lib";
  sourceRoot = "krb5-${finalAttrs.version}/src";

  passthru = {
    implementation = "krb5";

    tests = {
      inherit (nixosTests) kerberos;
      inherit (python3.pkgs) requests-credssp;
      bind = bind.override { enableGSSAPI = true; };
      curl = curl.override { gssSupport = true; };
      openssh = openssh.override { withKerberos = true; };
      postgresql = postgresql.override { gssSupport = true; };
    };
  };

  meta = {
    description = "MIT Kerberos 5";
    homepage = "http://web.mit.edu/kerberos/";
    changelog = "https://web.mit.edu/Kerberos/krb5-${lib.versions.majorMinor finalAttrs.version}/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };
})
