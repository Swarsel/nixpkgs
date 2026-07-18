{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  cmocka,
  fstrm,
  gitUpdater,
  jemalloc,
  json_c,
  libcap,
  libidn2,
  libkrb5,
  libtool,
  liburcu,
  libuv,
  libxml2,
  nghttp2,
  nixosTests,
  openssl,
  perl,
  pkg-config,
  protobufc,
  python3,
  removeReferencesTo,
  tzdata,
  enableGSSAPI ? true,
  enablePython ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bind";
  version = "9.20.24";

  src = fetchurl {
    url = "https://downloads.isc.org/isc/bind9/${finalAttrs.version}/bind-${finalAttrs.version}.tar.xz";
    hash = "sha256-mJ/vH8iOpZ0EzYb4VNylpGFqIKmWi83ePBo2aKs2vgg=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
    "dnsutils"
    "host"
  ];

  patches = [
    ./dont-keep-configure-flags.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    perl
    pkg-config
    protobufc
    removeReferencesTo
  ];

  buildInputs = [
    libidn2
    libtool
    libxml2
    json_c
    openssl
    liburcu
    libuv
    nghttp2
    jemalloc
    fstrm
    protobufc
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libcap
  ++ lib.optional enableGSSAPI libkrb5
  ++ lib.optional enablePython (python3.withPackages (ps: with ps; [ ply ]));

  configureFlags = [
    "--localstatedir=/var"
    "--without-lmdb"
    "--enable-dnstap"
    "--with-libidn2"
  ]
  ++ lib.optional enableGSSAPI "--with-gssapi=${libkrb5.dev}/bin/krb5-config"
  ++ lib.optional (stdenv.hostPlatform != stdenv.buildPlatform) "BUILD_CC=$(CC_FOR_BUILD)";

  doCheck = false;

  checkInputs = [
    cmocka
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isMusl) [
    tzdata
  ];

  preCheck =
    lib.optionalString stdenv.hostPlatform.isMusl ''
      # musl doesn't respect TZDIR, skip timezone-related tests
      sed -i '/^ISC_TEST_ENTRY(isc_time_formatISO8601L/d' tests/isc/time_test.c
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      # Test timeouts on Darwin
      sed -i '/^ISC_TEST_ENTRY(tcpdns_recv_one/d' tests/isc/netmgr_test.c
    '';

  postInstall = ''
    moveToOutput bin/bind9-config $dev

    moveToOutput bin/host $host

    moveToOutput bin/dig $dnsutils
    moveToOutput bin/delv $dnsutils
    moveToOutput bin/nslookup $dnsutils
    moveToOutput bin/nsupdate $dnsutils

    for f in "$lib/lib/"*.la "$dev/bin/"bind*-config; do
      sed -i "$f" -e 's|-L${openssl.dev}|-L${lib.getLib openssl}|g'
    done

    mkdir -p $out/etc
    cat <<EOF >$out/etc/rndc.conf
    include "/etc/bind/rndc.key";
    options {
        default-key "rndc-key";
        default-server 127.0.0.1;
        default-port 953;
    };
    EOF
  '';

  postFixup = ''
    remove-references-to -t "$out" "$dnsutils/bin/delv"
  '';

  # TODO: investigate failures; see this and linked discussions:
  # https://github.com/NixOS/nixpkgs/pull/192962
  /*
    doCheck = with stdenv.hostPlatform; !isStatic && !(isAarch64 && isLinux)
      # https://gitlab.isc.org/isc-projects/bind9/-/issues/4269
      && !is32bit;
  */
  checkTarget = "unit";
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;

  passthru = {
    tests = {
      inherit (nixosTests) bind;
      prometheus-exporter = nixosTests.prometheus-exporters.bind;
      withCheck = finalAttrs.finalPackage.overrideAttrs { doCheck = true; };
    }
    // lib.optionalAttrs (stdenv.hostPlatform.system == "x86_64-linux") {
      kubernetes-dns-multi-node = nixosTests.kubernetes.dns-multi-node;
      kubernetes-dns-single-node = nixosTests.kubernetes.dns-single-node;
    };

    updateScript = gitUpdater {
      # Avoid unstable 9.19 releases.
      odd-unstable = true;
      rev-prefix = "v";
      # No nicer place to find latest stable release.
      url = "https://gitlab.isc.org/isc-projects/bind9.git";
    };
  };

  meta = {
    description = "Domain name server";
    homepage = "https://www.isc.org/bind/";

    changelog = "https://downloads.isc.org/isc/bind9/cur/${lib.versions.majorMinor finalAttrs.version}/doc/arm/html/notes.html#notes-for-bind-${
      lib.replaceStrings [ "." ] [ "-" ] finalAttrs.version
    }";

    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;

    outputsToInstall = [
      "out"
      "dnsutils"
      "host"
    ];
  };
})
