{
  buildDunePackage,
  cohttp,
  conduit-lwt,
  conduit-mirage,
  fmt,
  git,
  git-paf,
  irmin-git,
  irmin-mirage,
  lwt,
  mirage-clock,
  mirage-kv,
  uri,
}:

buildDunePackage {
  inherit (irmin-mirage) version src;
  inherit (irmin-mirage) meta;
  pname = "irmin-mirage-git";

  propagatedBuildInputs = [
    irmin-mirage
    irmin-git
    mirage-kv
    cohttp
    conduit-lwt
    conduit-mirage
    git-paf
    fmt
    git
    lwt
    mirage-clock
    uri
  ];
}
