{
  alcotest,
  alcotest-lwt,
  buildDunePackage,
  cacert,
  irmin,
  irmin-fs,
  lwt,
  mtime,
  ppx_irmin,
}:

buildDunePackage {
  inherit (ppx_irmin) src version;
  pname = "irmin-containers";

  nativeBuildInputs = [
    ppx_irmin
  ];

  propagatedBuildInputs = [
    irmin
    irmin-fs
    ppx_irmin
    lwt
    mtime
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    alcotest-lwt
    cacert
  ];

  meta = ppx_irmin.meta // {
    description = "Mergeable Irmin data structures";
  };
}
