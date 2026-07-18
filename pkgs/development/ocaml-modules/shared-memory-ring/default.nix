{
  lib,
  fetchurl,
  buildDunePackage,
  cstruct,
  lwt,
  ounit,
  ppx_cstruct,
}:

buildDunePackage rec {
  pname = "shared-memory-ring";
  version = "3.2.1";

  src = fetchurl {
    url = "https://github.com/mirage/shared-memory-ring/releases/download/v${version}/shared-memory-ring-${version}.tbz";
    hash = "sha256-qSdntsPQo0/8JlbOoO6NAYtoa86HJy5yWHUsWi/PGDM=";
  };

  buildInputs = [
    ppx_cstruct
  ];

  propagatedBuildInputs = [
    cstruct
  ];

  doCheck = true;

  checkInputs = [
    lwt
    ounit
  ];

  duneVersion = "3";

  meta = {
    description = "Shared memory rings for RPC and bytestream communications";
    homepage = "https://github.com/mirage/shared-memory-ring";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
}
