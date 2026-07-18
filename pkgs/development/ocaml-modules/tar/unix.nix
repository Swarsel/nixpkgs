{
  buildDunePackage,
  fpath,
  git,
  logs,
  lwt,
  tar,
}:

buildDunePackage {
  inherit (tar) version src doCheck;
  pname = "tar-unix";

  propagatedBuildInputs = [
    tar
    fpath
    logs
    lwt
  ];

  nativeCheckInputs = [
    git
  ];

  meta = tar.meta // {
    description = "Decode and encode tar format files from Unix";
  };
}
