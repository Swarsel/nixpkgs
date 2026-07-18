{
  lib,
  buildDunePackage,
  curl,
  opam-format,
  patch,
}:

buildDunePackage {
  inherit (opam-format) src version;
  pname = "opam-repository";

  propagatedBuildInputs = [
    opam-format
    patch
  ];

  configureFlags = [ "--disable-checks" ];

  meta = opam-format.meta // {
    description = "OPAM repository and remote sources handling, including curl/wget, rsync, git, mercurial, darcs backends";
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
}
