{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "runiq";
  version = "2.0.0-unstable-2024-08-19";

  src = fetchFromGitHub {
    owner = "whitfin";
    repo = "runiq";
    rev = "a642926f6ec09d4faeebebb563d4aed89e0d36fb";
    hash = "sha256-DWP0kbTjXlyUI/+bHgom9/XJ2XW/BJEU4xvIisPVug0=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Efficient way to filter duplicate lines from input, à la uniq";
    homepage = "https://github.com/whitfin/runiq";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "runiq";
  };
}
