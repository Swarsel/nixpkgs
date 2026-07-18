{
  buildDunePackage,
  cmdliner,
  domain-name,
  duration,
  fmt,
  happy-eyeballs,
  ipaddr,
  logs,
  miou,
  mtime,
}:

buildDunePackage {
  inherit (happy-eyeballs) src version;
  pname = "happy-eyeballs-miou-unix";

  buildInputs = [
    cmdliner
    duration
    domain-name
    fmt
    ipaddr
    mtime
  ];

  propagatedBuildInputs = [
    happy-eyeballs
    logs
    miou
  ];

  doCheck = true;

  meta = happy-eyeballs.meta // {
    description = "Connecting to a remote host via IP version 4 or 6 using Miou";
  };
}
