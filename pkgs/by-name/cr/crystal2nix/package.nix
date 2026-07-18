{
  lib,
  fetchFromGitHub,
  crystal,
  makeBinaryWrapper,
  nix-prefetch-git,
}:

crystal.buildCrystalPackage rec {
  pname = "crystal2nix";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "crystal2nix";
    rev = "v${version}";
    hash = "sha256-O8X2kTzl3LYMT97tVqbIZXDcFq24ZTfvd4yeMUhmBFs=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  # temporarily off. We need the checks to execute the wrapped binary
  doCheck = false;

  postInstall = ''
    mkdir -p $out/libexec
    mv $out/bin/${meta.mainProgram} $out/libexec
    makeWrapper $out/libexec/${meta.mainProgram} $out/bin/${meta.mainProgram} \
      --prefix PATH : ${lib.makeBinPath [ nix-prefetch-git ]}
  '';

  doInstallCheck = true;
  format = "shards";
  shardsFile = ./shards.nix;

  meta = {
    description = "Utility to convert Crystal's shard.lock files to a Nix file";
    homepage = "https://github.com/nix-community/crystal2nix";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      peterhoeg
    ];

    mainProgram = "crystal2nix";
  };
}
