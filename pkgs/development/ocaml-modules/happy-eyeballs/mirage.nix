{
  buildDunePackage,
  domain-name,
  duration,
  fmt,
  happy-eyeballs,
  ipaddr,
  logs,
  lwt,
  mirage-mtime,
  mirage-sleep,
  tcpip,
}:

buildDunePackage {
  inherit (happy-eyeballs) src version;
  pname = "happy-eyeballs-mirage";

  buildInputs = [
    duration
    ipaddr
    domain-name
    fmt
    mirage-mtime
    mirage-sleep
  ];

  propagatedBuildInputs = [
    happy-eyeballs
    logs
    lwt
    tcpip
  ];

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = happy-eyeballs.meta // {
    description = "Connecting to a remote host via IP version 4 or 6 using Mirage";
  };
}
