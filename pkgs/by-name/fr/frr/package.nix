{
  lib,
  stdenv,
  fetchFromGitHub,
  # build time
  autoreconfHook,
  bison,
  buildPackages,
  # runtime
  c-ares,
  elfutils,
  fetchpatch,
  flex,
  grpc,
  json_c,
  libcap,
  libunwind,
  libyang,
  lua53Packages,
  net-snmp,
  # tests
  net-tools,
  nixosTests,
  openssl,
  pam,
  pcre2,
  perl,
  pkg-config,
  protobuf,
  protobufc,
  python3,
  readline,
  rtrlib,
  sqlite,
  texinfo,
  which,
  babeldSupport ? true,
  bfddSupport ? true,
  # BGP options
  bgpAnnounce ? true,
  bgpBmp ? true,
  bgpVnc ? true,
  # routing daemon options
  bgpdSupport ? true,
  cumulusSupport ? false,
  eigrpdSupport ? true,
  fabricdSupport ? true,
  # Experimental as of 10.1, reconsider if upstream changes defaults
  grpcSupport ? false,
  irdpSupport ? true,
  isisdSupport ? true,
  ldpdSupport ? true,
  mgmtdSupport ? true,
  nhrpdSupport ? true,
  numMultipath ? 64,
  ospf6dSupport ? true,
  # OSPF options
  ospfApi ? true,
  ospfdSupport ? true,
  pathdSupport ? true,
  pbrdSupport ? true,
  pim6dSupport ? true,
  pimdSupport ? true,
  ripdSupport ? true,
  ripngdSupport ? true,
  rpkiSupport ? true,
  scriptingSupport ? true,
  sharpdSupport ? true,
  # general options
  snmpSupport ? true,
  staticdSupport ? true,
  vrrpdSupport ? true,
  watchfrrSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "frr";
  version = "10.6.1";

  src = fetchFromGitHub {
    owner = "FRRouting";
    repo = "frr";
    rev = "frr-${finalAttrs.version}";
    hash = "sha256-sSvw9tfVNUyQjEOELoUAIQkEvXg765MsWvVKM0gsYUc=";
  };

  postPatch = ''
    substituteInPlace tools/frr-reload \
      --replace-quiet /usr/lib/frr/ $out/libexec/frr/
    sed -i '/^PATH=/ d' tools/frr.in tools/frrcommon.sh.in
  '';

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    perl
    pkg-config
    protobufc
    python3.pkgs.sphinx
    texinfo
  ]
  ++ lib.optionals grpcSupport [
    which
  ];

  buildInputs = [
    c-ares
    json_c
    libunwind
    libyang
    openssl
    pam
    pcre2
    protobufc
    python3
    readline
    rtrlib
    sqlite
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap
  ]
  ++ lib.optionals snmpSupport [
    net-snmp
  ]
  ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform elfutils) [
    elfutils
  ]
  ++ lib.optionals grpcSupport [
    grpc
    protobuf
  ]
  ++ lib.optionals scriptingSupport [
    lua53Packages.lua
  ];

  configureFlags = [
    "--disable-zeromq"
    "--disable-silent-rules"
    "--enable-configfile-mask=0640"
    "--enable-group=frr"
    "--enable-logfile-mask=0640"
    "--enable-multipath=${toString numMultipath}"
    "--enable-config-rollbacks"
    "--enable-user=frr"
    "--enable-vty-group=frrvty"
    "--localstatedir=/var"
    "--sbindir=${placeholder "out"}/libexec/frr"
    "--sysconfdir=/etc"
    "--with-clippy=${finalAttrs.clippy-helper}/bin/clippy"
    # general options
    (lib.strings.enableFeature snmpSupport "snmp")
    (lib.strings.enableFeature rpkiSupport "rpki")
    (lib.strings.enableFeature watchfrrSupport "watchfrr")
    (lib.strings.enableFeature irdpSupport "irdp")
    (lib.strings.enableFeature mgmtdSupport "mgmtd")
    (lib.strings.enableFeature grpcSupport "grpc")
    (lib.strings.enableFeature scriptingSupport "scripting")

    # routing protocols
    (lib.strings.enableFeature bgpdSupport "bgpd")
    (lib.strings.enableFeature ripdSupport "ripd")
    (lib.strings.enableFeature ripngdSupport "ripngd")
    (lib.strings.enableFeature ospfdSupport "ospfd")
    (lib.strings.enableFeature ospf6dSupport "ospf6d")
    (lib.strings.enableFeature ldpdSupport "ldpd")
    (lib.strings.enableFeature nhrpdSupport "nhrpd")
    (lib.strings.enableFeature eigrpdSupport "eigrpd")
    (lib.strings.enableFeature babeldSupport "babeld")
    (lib.strings.enableFeature isisdSupport "isisd")
    (lib.strings.enableFeature pimdSupport "pimd")
    (lib.strings.enableFeature pim6dSupport "pim6d")
    (lib.strings.enableFeature sharpdSupport "sharpd")
    (lib.strings.enableFeature fabricdSupport "fabricd")
    (lib.strings.enableFeature vrrpdSupport "vrrpd")
    (lib.strings.enableFeature pathdSupport "pathd")
    (lib.strings.enableFeature bfddSupport "bfdd")
    (lib.strings.enableFeature pbrdSupport "pbrd")
    (lib.strings.enableFeature staticdSupport "staticd")
    # BGP options
    (lib.strings.enableFeature bgpAnnounce "bgp-announce")
    (lib.strings.enableFeature bgpBmp "bgp-bmp")
    (lib.strings.enableFeature bgpVnc "bgp-vnc")
    # OSPF options
    (lib.strings.enableFeature ospfApi "ospfapi")
    # Cumulus options
    (lib.strings.enableFeature cumulusSupport "cumulus")
  ]
  ++ lib.optionals snmpSupport [
    # Used during build for paths, `dev` has build shebangs so can be run during build.
    "NETSNMP_CONFIG=${lib.getDev net-snmp}/bin/net-snmp-config"
  ];

  # Without the std explicitly set, we may run into abseil-cpp
  # compilation errors.
  env.CXXFLAGS = "-std=gnu++23";
  doCheck = true;

  nativeCheckInputs = [
    net-tools
    python3.pkgs.pytest
  ];

  # cross-compiling: clippy is compiled with the build host toolchain, split it out to ease
  # navigation in dependency hell
  clippy-helper = buildPackages.callPackage ./clippy-helper.nix {
    frrSource = finalAttrs.src;
    frrVersion = finalAttrs.version;
  };

  # otherwise in cross-compilation: "configure: error: no working python version found"
  depsBuildBuild = [
    buildPackages.python3
  ]
  ++ lib.optionals scriptingSupport [
    buildPackages.lua53Packages.lua
  ];

  enableParallelBuilding = true;
  passthru.tests = { inherit (nixosTests) frr; };

  meta = {
    description = "FRR BGP/OSPF/ISIS/RIP/RIPNG routing daemon suite";

    longDescription = ''
      FRRouting (FRR) is a free and open source Internet routing protocol suite
      for Linux and Unix platforms. It implements BGP, OSPF, RIP, IS-IS, PIM,
      LDP, BFD, Babel, PBR, OpenFabric and VRRP, with alpha support for EIGRP
      and NHRP.

      FRR’s seamless integration with native Linux/Unix IP networking stacks
      makes it a general purpose routing stack applicable to a wide variety of
      use cases including connecting hosts/VMs/containers to the network,
      advertising network services, LAN switching and routing, Internet access
      routers, and Internet peering.

      FRR has its roots in the Quagga project. In fact, it was started by many
      long-time Quagga developers who combined their efforts to improve on
      Quagga’s well-established foundation in order to create the best routing
      protocol stack available. We invite you to participate in the FRRouting
      community and help shape the future of networking.

      Join the ranks of network architects using FRR for ISPs, SaaS
      infrastructure, web 2.0 businesses, hyperscale services, and Fortune 500
      private clouds.
    '';

    homepage = "https://frrouting.org/";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [
      woffs
      thillux
    ];

    # adapt to platforms stated in http://docs.frrouting.org/en/latest/overview.html#supported-platforms
    platforms = (
      lib.platforms.linux ++ lib.platforms.freebsd ++ lib.platforms.netbsd ++ lib.platforms.openbsd
    );
  };
})
