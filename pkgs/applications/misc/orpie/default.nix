{
  lib,
  fetchFromGitHub,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage rec {
  pname = "orpie";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "pelzlpj";
    repo = "orpie";
    tag = "release-${version}";
    sha256 = "sha256-LwhH2BO4p8Y8CB2pNkl2heIR7yh42erdTcDsxgy1ouc=";
  };

  patches = [ ./prefix.patch ];
  nativeBuildInputs = [ ocamlPackages.camlp5 ];

  buildInputs = with ocamlPackages; [
    curses
    num
    gsl
  ];

  preConfigure = ''
    substituteInPlace src/orpie/install.ml.in --replace '@prefix@' $out
  '';

  meta = {
    inherit (src.meta) homepage;
    description = "Curses-based RPN calculator";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ obadz ];
  };
}
