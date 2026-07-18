{
  buildDunePackage,
  cmdliner,
  dns,
  domain-name,
  duration,
  fmt,
  happy-eyeballs,
  ipaddr,
  logs,
  lwt,
  mtime,
}:

buildDunePackage {
  inherit (happy-eyeballs) src version;
  pname = "happy-eyeballs-lwt";

  buildInputs = [
    cmdliner
    duration
    domain-name
    ipaddr
    fmt
    mtime
  ];

  propagatedBuildInputs = [
    dns
    happy-eyeballs
    logs
    lwt
  ];

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = happy-eyeballs.meta // {
    description = "Connecting to a remote host via IP version 4 or 6 using Lwt_unix";
    mainProgram = "happy_eyeballs_client";
  };
}
