{
  lib,
  fetchFromGitHub,
  gerbilPackages,
  ...
}:

{
  pname = "ftw";
  version = "unstable-2023-11-15";
  gerbil-package = "drewc/ftw";
  gerbilInputs = with gerbilPackages; [ gerbil-utils ];
  git-version = "e5e2f56";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "drewc";
    repo = "ftw";
    rev = "e5e2f56e90bf072ddf9c2987ddfac45f048e8a04";
    sha256 = "04164190vv1fzfk014mgqqmy5cml5amh63df31q2yc2kzvfajfc3";
  };

  softwareName = "FTW: For The Web!";

  meta = {
    description = "Simple web handlers for Gerbil Scheme";
    homepage = "https://github.com/drewc/ftw";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
}
