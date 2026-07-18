{
  lib,
  fetchFromGitHub,
  buildNimPackage,
  makeWrapper,
  nim,
  nix-update-script,
  openssl,
}:

buildNimPackage (
  final: prev: {
    pname = "nimble";
    version = "0.20.1";

    src = fetchFromGitHub {
      owner = "nim-lang";
      repo = "nimble";
      rev = "v${final.version}";
      hash = "sha256-DV/cheAoG0UviYEYqfaonhrAl4MgjDwFqbbKx7jUnKE=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ openssl ];
    doCheck = false; # it works on their machine

    postInstall = ''
      wrapProgram $out/bin/nimble \
        --suffix PATH : ${lib.makeBinPath [ nim ]}
    '';

    nimFlags = [ "--define:git_revision_override=${final.src.rev}" ];
    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Package manager for the Nim programming language";
      homepage = "https://github.com/nim-lang/nimble";
      changelog = "https://github.com/nim-lang/nimble/releases/tag/v${final.version}";
      license = lib.licenses.bsd3;
      mainProgram = "nimble";
      teams = [ lib.teams.nim ];
    };
  }
)
