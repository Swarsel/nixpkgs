{
  lib,
  stdenv,
  fetchurl,
  asciidoc,
  autoreconfHook,
  bison,
  docbook_xml_dtd_45,
  docbook_xsl,
  findXMLCatalogs,
  flex,
  gitUpdater,
  gmp,
  iptables,
  jansson,
  libedit,
  libmnl,
  libnftnl,
  libpcap,
  libxslt,
  ncurses,
  nixosTests,
  pkg-config,
  withCli ? true,
  withDebugSymbols ? false,
  withXtables ? true,
}:

stdenv.mkDerivation rec {
  pname = "nftables";
  version = "1.1.6";

  src = fetchurl {
    url = "https://netfilter.org/projects/nftables/files/${pname}-${version}.tar.xz";
    hash = "sha256-NykxvahVazEGNqL5AgrccQ+bq2b0fv4M6Qv/gArCUww=";
  };

  patches = [
    (fetchurl {
      hash = "sha256-7vMBIoDWcI/JBInYP5yYWp8BnYbATRfMTxqyZr2L9Sk=";
      name = "musl.patch";
      url = "https://lore.kernel.org/netfilter-devel/20241219231001.1166085-2-hi@alyssa.is/raw";
    })

    # Following 4 commits fix reproducibility.
    (fetchurl {
      hash = "sha256-gJi6Q6mpURynzpnTFs1VJmZ+SpnNhyOrCzKarJmu/6w=";
      name = "0001-build-fix-.-configure-with-non-bash-shell.patch";
      url = "https://git.netfilter.org/nftables/patch/?id=2e3c68f26d5bd60c8ea7467fa9018c282a7d8c47";
    })
    (fetchurl {
      hash = "sha256-gzlMHaZTXCqR8IcccIsLaMZie3CaMEPa4lnGr/x7b/o=";
      name = "0002-build-simplify-the-instantation-of-nftversion.h.patch";
      url = "https://git.netfilter.org/nftables/patch/?id=2a0ec8a7246e5c5eb85270e3d4de43e20a00c577";
    })
    (fetchurl {
      hash = "sha256-03nexKi/tH1pGNor2/q+Q5ps9+YQRGBbR/DR164Efpo=";
      name = "0003-build-generate-build-time-stamp-once-at-configure.patch";
      url = "https://git.netfilter.org/nftables/patch/?id=b92571cc59ce49fdd9fe2daac9350529adfb2424";
    })
    (fetchurl {
      hash = "sha256-vK/dsi9YXzEg2iShfbhnwlJJC27LTBA9fIjyJySoeFI=";
      name = "0004-build-support-SOURCE_DATE_EPOCH-for-build-time-stamp.patch";
      url = "https://git.netfilter.org/nftables/patch/?id=ca86f206c92704170a295b8dc7a41f6448835dde";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
    flex
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    findXMLCatalogs
    libxslt
  ]
  ++ lib.optional stdenv.hostPlatform.isStatic ncurses;

  buildInputs = [
    libmnl
    libnftnl
    libpcap
    gmp
    jansson
  ]
  ++ lib.optional withCli libedit
  ++ lib.optional withXtables iptables;

  configureFlags = [
    "--with-json"
    (lib.withFeatureAs withCli "cli" "editline")
  ]
  ++ lib.optional (!withDebugSymbols) "--disable-debug"
  ++ lib.optional withXtables "--with-xtables";

  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isStatic "-lncursesw";
  enableParallelBuilding = true;

  passthru.tests = {
    inherit (nixosTests) firewall-nftables;
    nat = { inherit (nixosTests.nat.nftables) firewall standalone; };
  };

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://git.netfilter.org/nftables";
  };

  meta = {
    description = "Project that aims to replace the existing {ip,ip6,arp,eb}tables framework";
    homepage = "https://netfilter.org/projects/nftables/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ izorkin ];
    platforms = lib.platforms.linux;
    mainProgram = "nft";
  };
}
