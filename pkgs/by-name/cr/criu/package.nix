{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  buildPackages,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchpatch2,
  gnutar,
  gzip,
  iproute2,
  iptables,
  libbsd,
  libcap,
  libnet,
  libnl,
  libpaper,
  libuuid,
  makeWrapper,
  nftables,
  perl,
  pkg-config,
  protobuf,
  protobufc,
  python3,
  which,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "criu";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "checkpoint-restore";
    repo = "criu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SfpJskXX7r3jbAwgZl2qpa7j1M4i8/sV6rlAWiUEoQs=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    (fetchpatch2 {
      hash = "sha256-J8n4TjqjzJLLULnpJdR/6YWa/8moFQMn+wNo4a0otgE=";
      name = "conflicting-redefinition-of-rseq-enums.patch";
      url = "https://github.com/checkpoint-restore/criu/commit/3f3acc3200a23140abaa32a2017ae159d3c2d02c.patch?full_index=1";
    })
  ];

  postPatch = ''
    substituteInPlace ./Documentation/Makefile \
      --replace-fail "2>/dev/null" "" \
      --replace-fail "-m custom.xsl" "-m custom.xsl --skip-validation -x ${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl"
    substituteInPlace ./Makefile \
      --replace-fail "head-name := \$(shell git tag -l v\$(CRIU_VERSION))" "head-name = ${finalAttrs.version}.0"
    ln -sf ${protobuf}/include/google/protobuf/descriptor.proto ./images/google/protobuf/descriptor.proto
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    asciidoc
    xmlto
    libpaper
    docbook_xsl
    which
    makeWrapper
    docbook_xml_dtd_45
    python3
    python3.pkgs.wrapPython
    perl
  ];

  buildInputs = [
    protobuf
    libnl
    libcap
    libnet
    nftables
    libbsd
    libuuid
  ];

  propagatedBuildInputs = [
    protobufc
  ]
  ++ (with python3.pkgs; [
    python
    python3.pkgs.protobuf
  ]);

  makeFlags =
    let
      # criu's Makefile infrastructure expects to be passed a target architecture
      # which neither matches the config-tuple's first part, nor the
      # targetPlatform.linuxArch attribute. Thus we take the latter and map it
      # onto the expected string:
      linuxArchMapping = {
        "arm" = "arm";
        "arm64" = "aarch64";
        "loongarch" = "loongarch64";
        "mips" = "mips";
        "powerpc" = "ppc64";
        "s390" = "s390";
        "x86_64" = "x86";
      };
    in
    [
      "PREFIX=$(out)"
      "ASCIIDOC=${buildPackages.asciidoc}/bin/asciidoc"
      "XMLTO=${buildPackages.xmlto}/bin/xmlto"
    ]
    ++ (lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
      "ARCH=${linuxArchMapping."${stdenv.hostPlatform.linuxArch}"}"
      "CROSS_COMPILE=${stdenv.hostPlatform.config}-"
    ]);

  preBuild = ''
    # No idea why but configure scripts break otherwise.
    export SHELL=""
  '';

  # dropping fortify here as well as package uses it by default:
  # command-line>:0:0: error: "_FORTIFY_SOURCE" redefined [-Werror]
  postFixup = ''
    wrapProgram $out/bin/criu \
      --set-default CR_IPTABLES ${iptables}/bin/iptables \
      --set-default CR_IP_TOOL ${iproute2}/bin/ip \
      --prefix PATH : ${
        lib.makeBinPath [
          gnutar
          gzip
        ]
      }
    wrapPythonPrograms
  '';

  depsBuildBuild = [
    protobufc
    buildPackages.stdenv.cc
  ];

  enableParallelBuilding = true;

  hardeningDisable = [
    "stackprotector"
    "fortify"
  ];

  meta = {
    description = "Userspace checkpoint/restore for Linux";
    homepage = "https://criu.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.thoughtpolice ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "armv7l-linux"
      "loongarch64-linux"
    ];
  };
})
