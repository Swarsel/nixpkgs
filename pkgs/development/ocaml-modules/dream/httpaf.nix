{
  buildDunePackage,
  dream-pure,
  httpun-ws,
  lwt_ppx,
}:

buildDunePackage {
  inherit (dream-pure) version src;
  pname = "dream-httpaf";
  buildInputs = [ lwt_ppx ];

  propagatedBuildInputs = [
    dream-pure
    httpun-ws
  ];

  meta = dream-pure.meta // {
    description = "Shared http/af stack for Dream (server) and Hyper (client)";
  };
}
