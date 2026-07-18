{
  bsdSetupHook,
  buildPackages,
  install,
  makeMinimal,
  mkDerivation,
  mtree,
  openbsdSetupHook,
  pax,
  rpcgen,
}:
mkDerivation {
  nativeBuildInputs = [
    bsdSetupHook
    install
    makeMinimal
    mtree
    openbsdSetupHook
    pax
    rpcgen
  ];

  makeFlags = [
    "RPCGEN_CPP=${buildPackages.stdenv.cc.cc}/bin/cpp"
    "-B"
  ];

  extraPaths = [
    "lib"
    #"sys"
    "sys/arch"
    # LDIRS from the mmakefile
    "sys/crypto"
    "sys/ddb"
    "sys/dev"
    "sys/isofs"
    "sys/miscfs"
    "sys/msdosfs"
    "sys/net"
    "sys/netinet"
    "sys/netinet6"
    "sys/netmpls"
    "sys/net80211"
    "sys/nfs"
    "sys/ntfs"
    "sys/scsi"
    "sys/sys"
    "sys/ufs"
    "sys/uvm"
  ];

  headersOnly = true;
  noCC = true;
  path = "include";
}
