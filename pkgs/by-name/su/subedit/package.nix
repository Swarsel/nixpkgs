{
  lib,
  stdenv,
  fetchFromGitHub,
  dos2unix,
  file,
  libuchardet,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "subedit";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "helixarch";
    repo = "subedit";
    rev = "74e11816d7b4813064a2434a5abc0f78f66c0e53";
    sha256 = "sha256-3ywBBCWbwDqNNkxRupNJX6mYKxVFnoCFKav3Hc4E+8A=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    libuchardet
    dos2unix
    file
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -m555 subedit $out/bin/
  '';

  postFixup = ''
    wrapProgram $out/bin/subedit --prefix PATH : "${
      lib.makeBinPath [
        libuchardet
        dos2unix
        file
      ]
    }"
  '';

  meta = {
    description = "Command-line subtitle editor written in BASH";
    homepage = "https://github.com/helixarch/subedit";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ppom ];
    mainProgram = "subedit";
  };
}
