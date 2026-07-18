{ buildRedist, zlib }:
buildRedist {
  pname = "fabricmanager";

  outputs = [
    "out"
    "bin"
    "dev"
    "include"
    "lib"
  ];

  buildInputs = [ zlib ];
  allowFHSReferences = true;
  redistName = "cuda";
  meta.homepage = "https://docs.nvidia.com/datacenter/tesla/fabric-manager-user-guide";
}
