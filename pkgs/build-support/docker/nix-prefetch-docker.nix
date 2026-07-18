{
  lib,
  stdenv,
  coreutils,
  jq,
  makeWrapper,
  nix,
  skopeo,
}:

stdenv.mkDerivation {
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -vD ${./nix-prefetch-docker} $out/bin/$name;
    wrapProgram $out/bin/$name \
      --prefix PATH : ${
        lib.makeBinPath [
          nix
          skopeo
          jq
          coreutils
        ]
      } \
      --set HOME /homeless-shelter
  '';

  dontUnpack = true;
  name = "nix-prefetch-docker";
  preferLocalBuild = true;

  meta = {
    description = "Script used to obtain source hashes for dockerTools.pullImage";
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "nix-prefetch-docker";
  };
}
