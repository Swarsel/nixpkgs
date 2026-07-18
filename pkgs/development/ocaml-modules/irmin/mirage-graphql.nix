{
  buildDunePackage,
  cohttp-lwt,
  git,
  irmin-graphql,
  irmin-mirage,
  lwt,
  mirage-clock,
  uri,
}:

buildDunePackage {
  inherit (irmin-mirage) version src;
  inherit (irmin-mirage) meta;
  pname = "irmin-mirage-graphql";

  propagatedBuildInputs = [
    irmin-mirage
    irmin-graphql
    mirage-clock
    cohttp-lwt
    lwt
    uri
    git
  ];
}
