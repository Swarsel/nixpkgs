{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "complgen";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "adaszko";
    repo = "complgen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0oC/jpCKM2Y1yag+qIUu+b3sCIPmHs/GUBSPHi7KaVI=";
  };

  cargoHash = "sha256-skdtXxNUuC7xLtZSol3b1prdN1YT62uvwo+F7rtFVVQ=";

  meta = {
    description = "Generate {bash,fish,zsh} completions from a single EBNF-like grammar";
    homepage = "https://github.com/adaszko/complgen";
    changelog = "https://github.com/adaszko/complgen/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hythera ];
    mainProgram = "complgen";
  };
})
