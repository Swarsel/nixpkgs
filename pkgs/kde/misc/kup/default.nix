{
  lib,
  fetchFromGitLab,
  libgit2,
  mkKdeDerivation,
}:
mkKdeDerivation rec {
  pname = "kup";
  version = "0.10.0";

  src = fetchFromGitLab {
    owner = "system";
    repo = "kup";
    rev = "${pname}-${version}";
    hash = "sha256-G/GXmcQI1OBnCE7saPHeHDAMeL2WR6nVttMlKV2e01I=";
    domain = "invent.kde.org";
  };

  extraBuildInputs = [ libgit2 ];

  meta = {
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.pwoelfel ];
    teams = [ ];
  };
}
