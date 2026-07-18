{
  lib,
  stdenv,
  fetchFromGitHub,
  afl-persistent,
  buildDunePackage,
  calendar,
  cmdliner,
  fpath,
  pprint,
  uucp,
  uunf,
  uutf,
}:

buildDunePackage (finalAttrs: {
  pname = "crowbar";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "stedolan";
    repo = "crowbar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KGDOm9PMymFwyHoe7gp+rl+VxbbkLvnb8ypTXbImSgs=";
  };

  # disable xmldiff tests, so we don't need to package unmaintained and legacy pkgs
  postPatch = "rm -rf examples/xmldiff";

  propagatedBuildInputs = [
    cmdliner
    afl-persistent
  ];

  # uunf is broken on aarch64
  doCheck = !stdenv.hostPlatform.isAarch64;

  checkInputs = [
    calendar
    fpath
    pprint
    uutf
    uunf
    uucp
  ];

  meta = {
    description = "Property fuzzing for OCaml";
    homepage = "https://github.com/stedolan/crowbar";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
