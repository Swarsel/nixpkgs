{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

let
  features = [
    "rustls-webpki"
    "geosparql"
    "rdf-12"
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oxigraph";
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "oxigraph";
    repo = "oxigraph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J4cx/fzdsgRXeWsP9Gt5q/0crWoc1OP8+xbuvQJTj34=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    installShellFiles
  ];

  cargoHash = "sha256-BvL1rGJcU28TLkxJ3pKah6qfaa0SdUt143UgBYJrLsE=";

  # Man pages and autocompletion
  postInstall = ''
    MAN_DIR="$(find target/*/release -name man)"
    installManPage "$MAN_DIR"/*.1
    COMPLETE_DIR="$(find target/*/release -name complete)"
    installShellCompletion --bash --name oxigraph.bash "$COMPLETE_DIR/oxigraph.bash"
    installShellCompletion --fish --name oxigraph.fish "$COMPLETE_DIR/oxigraph.fish"
    installShellCompletion --zsh --name _oxigraph "$COMPLETE_DIR/_oxigraph"
  '';

  buildAndTestSubdir = "cli";
  buildFeatures = features;
  buildNoDefaultFeatures = true;
  cargoCheckFeatures = features;
  cargoCheckNoDefaultFeatures = true;

  meta = {
    description = "SPARQL graph database";
    homepage = "https://github.com/oxigraph/oxigraph";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      astro
      tnias
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "oxigraph";
  };
})
