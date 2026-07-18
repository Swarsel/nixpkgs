{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rippkgs";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "replit";
    repo = "rippkgs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nRaGbJg1zCHTL8y/Tk5dM1dSu2v06ECsZYyMPIQTlvg=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    sqlite
  ];

  cargoHash = "sha256-bSgQ/dmOffWOYpgeNn0vTdzrM/aFkD3znN9c1u/sjQ0=";

  meta = {
    description = "CLI for indexing and searching packages in Nix expressions";
    homepage = "https://github.com/replit/rippkgs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cdmistman ];
    mainProgram = "rippkgs";
  };
})
