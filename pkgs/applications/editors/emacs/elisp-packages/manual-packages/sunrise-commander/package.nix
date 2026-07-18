{
  lib,
  fetchFromGitHub,
  melpaBuild,
}:

melpaBuild {
  pname = "sunrise-commander";
  version = "0-unstable-2021-09-27";

  src = fetchFromGitHub {
    owner = "sunrise-commander";
    repo = "sunrise-commander";
    rev = "16e6df7e86c7a383fb4400fae94af32baf9cb24e";
    hash = "sha256-D36qiRi5OTZrBtJ/bD/javAWizZ8NLlC/YP4rdLCSsw=";
  };

  ename = "sunrise";

  meta = {
    description = "Orthodox (two-pane) file manager for Emacs";
    homepage = "https://github.com/sunrise-commander/sunrise-commander/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
