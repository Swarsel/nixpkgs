{
  lib,
  fetchFromGitHub,
  gccStdenv,
}:

gccStdenv.mkDerivation rec {
  pname = "muscle";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "rcedgar";
    repo = "muscle";
    rev = version;
    hash = "sha256-NpnJziZXga/T5OavUt3nQ5np8kJ9CFcSmwyg4m6IJsk=";
  };

  patches = [
    ./muscle-darwin-g++.patch
  ];

  installPhase =
    let
      target = if gccStdenv.hostPlatform.isDarwin then "Darwin" else "Linux";
    in
    ''
      install -m755 -D ${target}/muscle $out/bin/muscle
    '';

  sourceRoot = "${src.name}/src";

  meta = {
    description = "Multiple sequence alignment with top benchmark scores scalable to thousands of sequences";
    homepage = "https://www.drive5.com/muscle/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      unode
    ];

    mainProgram = "muscle";
  };
}
