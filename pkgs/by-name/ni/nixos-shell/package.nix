{
  lib,
  stdenv,
  fetchFromGitHub,
  jq,
  makeWrapper,
  nix,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nixos-shell";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nixos-shell";
    rev = finalAttrs.version;
    sha256 = "sha256-sVlbbhRVpAJ8fcjdwJFXlw9MOpb9aqFmAzDCzDi0jqo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/nixos-shell \
      --prefix PATH : ${
        lib.makeBinPath [
          nix
          jq
        ]
      }
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Spawns lightweight nixos vms in a shell";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
    platforms = lib.platforms.unix;
    mainProgram = "nixos-shell";
  };
})
