{
  alcotest,
  astring,
  buildDunePackage,
  cacert,
  cohttp-lwt-unix,
  cstruct,
  digestif,
  fmt,
  fpath,
  git,
  git-unix,
  irmin,
  irmin-test,
  irmin-watcher,
  logs,
  lwt,
  mimic,
  mtime,
  ppx_irmin,
  uri,
}:

buildDunePackage {

  inherit (irmin) version src;
  pname = "irmin-git";

  propagatedBuildInputs = [
    git
    irmin
    ppx_irmin
    digestif
    cstruct
    fmt
    astring
    fpath
    logs
    lwt
    uri
    irmin-watcher
    git-unix
    mimic
    cohttp-lwt-unix
  ];

  doCheck = true;

  checkInputs = [
    mtime
    alcotest
    irmin-test
    cacert
  ];

  meta = irmin.meta // {
    description = "Git backend for Irmin";
  };

}
