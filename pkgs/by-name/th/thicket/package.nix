{
  lib,
  fetchFromGitHub,
  crystal,
}:

crystal.buildCrystalPackage rec {
  pname = "thicket";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "taylorthurlow";
    repo = "thicket";
    rev = "v${version}";
    sha256 = "sha256-sF+fNKEZEfjpW3buh6kFUpL1P0yO9g4SrTb0rhx1uNc=";
  };

  # there is one test that tries to clone a repo
  doCheck = false;
  crystalBinaries.thicket.src = "src/thicket.cr";
  format = "shards";

  meta = {
    description = "Better one-line git log";
    homepage = "https://github.com/taylorthurlow/thicket";
    license = lib.licenses.mit;
    mainProgram = "thicket";
  };
}
