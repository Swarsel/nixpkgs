{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  fetchpatch,
}:

let
  pname = "camlgpc";
  version = "1.2";
in
buildDunePackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "johnwhitington";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+Dx8BuRlxb8xh41jHskrNcKGV/HgedauLt1vo1tADHw=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-znm+mX60RwYNCYXwm9HYCO8BRbzUM0Bm6dI1f1FzncA=";
      name = "camlgpc-pr-5-switch-to-dune";
      url = "https://github.com/johnwhitington/camlgpc/pull/5.diff";
    })
  ];

  doCheck = true;

  meta = {
    description = "OCaml interface to Alan Murta's General Polygon Clipper";
    homepage = "https://github.com/johnwhitington/camlgpc";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vog ];
  };
}
