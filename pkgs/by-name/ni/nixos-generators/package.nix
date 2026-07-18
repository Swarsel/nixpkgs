{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  coreutils,
  findutils,
  jq,
  makeWrapper,
  nix,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nixos-generators";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nixos-generators";
    rev = finalAttrs.version;
    sha256 = "sha256-wHmtB5H8AJTUaeGHw+0hsQ6nU4VyvVrP2P4NeCocRzY=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  postFixup = ''
    wrapProgram $out/bin/nixos-generate \
      --prefix PATH : ${
        lib.makeBinPath [
          jq
          coreutils
          findutils
          nix
        ]
      }
  '';

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Collection of image builders";
    homepage = "https://github.com/nix-community/nixos-generators";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lassulus ];
    platforms = lib.platforms.unix;
    mainProgram = "nixos-generate";
  };
})
