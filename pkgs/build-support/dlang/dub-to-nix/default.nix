{
  lib,
  makeWrapper,
  nix,
  nix-prefetch-git,
  python3,
  runCommand,
}:

let
  binPath = lib.makeBinPath [
    nix
    nix-prefetch-git
  ];
in
runCommand "dub-to-nix"
  {
    pname = "dub-to-nix";
    version = lib.trivial.release;
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ python3 ];
  }
  ''
    install -Dm755 ${./dub-to-nix.py} "$out/bin/dub-to-nix"
    patchShebangs "$out/bin/dub-to-nix"
    wrapProgram "$out/bin/dub-to-nix" \
        --prefix PATH : ${binPath}
  ''
