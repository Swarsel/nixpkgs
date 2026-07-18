{
  lib,
  fetchFromGitHub,
  buildOctavePackage,
  fpl,
  msh,
}:

buildOctavePackage rec {
  pname = "bim";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "carlodefalco";
    repo = "bim";
    tag = "v${version}";
    sha256 = "sha256-nK/VZ+thMuMU5RBiNYpzylOuVxKbcfSyrXZfka5+g4I=";
  };

  requiredOctavePackages = [
    fpl
    msh
  ];

  meta = {
    description = "Package for solving Diffusion Advection Reaction (DAR) Partial Differential Equations";
    homepage = "https://gnu-octave.github.io/packages/bim/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
