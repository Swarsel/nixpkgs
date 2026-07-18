{
  lib,
  fetchFromGitHub,
  bzip2,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mdbook-epub";
  version = "0.4.37";

  src = fetchFromGitHub {
    owner = "michael-f-bryan";
    repo = "mdbook-epub";
    tag = finalAttrs.version;
    hash = "sha256-ddWClkeGabvqteVUtuwy4pWZGnarrKrIbuPEe62m6es=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ bzip2 ];
  cargoHash = "sha256-3R81PJCOFc22QDHH2BqGB9jjvEcMc1axoySSJLJD3wI=";

  meta = {
    description = "mdbook backend for generating an e-book in the EPUB format";
    homepage = "https://michael-f-bryan.github.io/mdbook-epub";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "mdbook-epub";
  };
})
