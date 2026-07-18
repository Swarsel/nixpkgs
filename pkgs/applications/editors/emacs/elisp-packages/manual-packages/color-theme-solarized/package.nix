{
  lib,
  fetchFromGitHub,
  melpaBuild,
}:

melpaBuild {
  pname = "color-theme-solarized";
  version = "0-unstable-2023-02-09";

  src = fetchFromGitHub {
    owner = "sellout";
    repo = "emacs-color-theme-solarized";
    rev = "b186e5d62d0b83cbf5cf38f7eb7a199dea9a3ee3";
    hash = "sha256-7E8r56dzfD06tsQEnqU5mWSbwz9x9QPbzken2J/fhlg=";
  };

  ename = "solarized-theme";
  files = ''(:defaults (:exclude "color-theme-solarized-pkg.el"))'';

  meta = {
    description = "Precision colors for machines and people; Emacs implementation";
    homepage = "http://ethanschoonover.com/solarized";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
