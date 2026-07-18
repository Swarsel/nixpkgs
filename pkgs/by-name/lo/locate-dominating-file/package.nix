{
  lib,
  fetchFromGitHub,
  bash,
  bats,
  coreutils,
  getopt,
  resholve,
}:
let
  version = "0.0.1";
in
resholve.mkDerivation {
  inherit version;
  pname = "locate-dominating-file";

  src = fetchFromGitHub {
    owner = "roman";
    repo = "locate-dominating-file";
    rev = "v${version}";
    hash = "sha256-gwh6fAw7BV7VFIkQN02QIhK47uxpYheMk64UeLyp2IY=";
  };

  postPatch = ''
    for file in $(find src tests -type f); do
      patchShebangs "$file"
    done
  '';

  buildInputs = [
    getopt
    coreutils
  ];

  doCheck = true;

  checkInputs = [
    (bats.withLibraries (p: [
      p.bats-support
      p.bats-assert
    ]))
  ];

  checkPhase = ''
    runHook preCheck

    bats -t tests

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp src/locate-dominating-file.sh $out/bin/locate-dominating-file

    runHook postInstall
  '';

  solutions.default = {
    inputs = [
      coreutils
      getopt
    ];

    interpreter = "${bash}/bin/bash";
    scripts = [ "bin/locate-dominating-file" ];
  };

  meta = {
    description = "Program that looks up in a directory hierarchy for a given filename";
    homepage = "https://github.com/roman/locate-dominating-file";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.roman ];
    platforms = lib.platforms.all;
    mainProgram = "locate-dominating-file";
  };
}
