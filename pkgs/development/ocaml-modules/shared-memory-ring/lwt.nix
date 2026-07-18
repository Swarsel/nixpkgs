{
  buildDunePackage,
  cstruct,
  lwt,
  lwt-dllist,
  mirage-profile,
  ounit,
  ppx_cstruct,
  shared-memory-ring,
}:

buildDunePackage {
  inherit (shared-memory-ring) version src;
  pname = "shared-memory-ring-lwt";

  buildInputs = [
    ppx_cstruct
  ];

  propagatedBuildInputs = [
    shared-memory-ring
    cstruct
    lwt
    lwt-dllist
    mirage-profile
  ];

  doCheck = true;

  checkInputs = [
    ounit
  ];

  duneVersion = "3";

  meta = shared-memory-ring.meta // {
    description = "Shared memory rings for RPC and bytestream communications using Lwt";
  };
}
