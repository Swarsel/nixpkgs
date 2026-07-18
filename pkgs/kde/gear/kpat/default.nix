{
  _7zz,
  black-hole-solver,
  freecell-solver,
  libkdegames,
  mkKdeDerivation,
  qtsvg,
  shared-mime-info,
}:
mkKdeDerivation {
  pname = "kpat";

  extraBuildInputs = [
    qtsvg
    black-hole-solver
    freecell-solver
  ];

  extraNativeBuildInputs = [
    _7zz
    shared-mime-info
  ];

  qtWrapperArgs = [ "--prefix XDG_DATA_DIRS : ${libkdegames}/share" ];
  meta.mainProgram = "kpat";
}
