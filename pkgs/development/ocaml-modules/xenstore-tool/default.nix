{
  buildDunePackage,
  camlp-streams,
  lwt,
  xenstore,
  xenstore_transport,
}:

buildDunePackage {
  inherit (xenstore_transport) src version;
  pname = "xenstore-tool";

  buildInputs = [
    camlp-streams
    xenstore_transport
    xenstore
    lwt
  ];

  meta = xenstore_transport.meta // {
    description = "Command line tool for interfacing with xenstore";
  };
}
