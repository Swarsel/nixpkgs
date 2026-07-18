{
  lib,
  fetchFromGitHub,
  haskellPackages,
}:
haskellPackages.mkDerivation rec {
  pname = "pshash";
  version = "0.1.16.0";

  src = fetchFromGitHub {
    owner = "thornoar";
    repo = "pshash";
    tag = "v${version}";
    hash = "sha256-3Qe52Hto3Z96b5q9TLz7XB7BzMfdNBd4p8V6dknH6VM=";
  };

  postPatch = ''
    patchShebangs --build test/output.sh
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    test/output.sh dist/build/pshash/pshash
    runHook postCheck
  '';

  description = "Functional pseudo-hash password creation tool";

  executableHaskellDepends = with haskellPackages; [
    base
    containers
    directory
  ];

  homepage = "https://github.com/thornoar/pshash";
  isExecutable = true;
  isLibrary = false;
  license = lib.licenses.mit;
  mainProgram = "pshash";
  maintainers = with lib.maintainers; [ thornoar ];
}
