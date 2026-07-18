{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  clang_20,
  libsecret,
  pkg-config,
}:

buildNpmPackage {
  pname = "solidity-language-server";
  version = "0.0.185";

  src = fetchFromGitHub {
    owner = "juanfranblanco";
    repo = "vscode-solidity";
    rev = "5198201a23874e79248e6b09558ca30e5bf5cdcf";
    hash = "sha256-GHa2VbMyYn0FXEhd1my0851rbtoWtlOGmsAF6JDzLkc=";
  };

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ clang_20 ]; # clang_21 breaks keytar
  buildInputs = [ libsecret ];
  npmDepsHash = "sha256-zXhWtPuiu+CRk712KskuHP4vglogJmFoCak6qWczPFM=";
  npmBuildScript = "build:cli";

  meta = {
    description = "Language Server for solidity code";
    homepage = "https://github.com/juanfranblanco/vscode-solidity";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rookeur ];
    mainProgram = "solidity-language-server";
  };
}
