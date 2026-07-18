{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  makeWrapper,
  pandoc,
  rustPlatform,
  texliveSmall,
}:

rustPlatform.buildRustPackage rec {
  pname = "mdbook-pandoc";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "max-heller";
    repo = "mdbook-pandoc";
    tag = "v${version}";
    hash = "sha256-lLuw6CZPWHZ8DZz/lWTd+eEv688HcbkvsxLRvW38RKs=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-TMFnF/aTJ2UrtnPZ4UOQke6dtUZbUxywf4JIX53mhKY=";

  nativeCheckInputs = [
    pandoc
    # some tests require pdflatex
    texliveSmall
  ];

  passthru = {
    wrapper = callPackage ./wrapper.nix { };
  };

  meta = {
    description = "A mdbook backend powered by Pandoc";
    homepage = "https://github.com/max-heller/mdbook-pandoc";
    changelog = "https://github.com/max-heller/mdbook-pandoc/releases/tag/${src.tag}";

    license = with lib.licenses; [
      asl20
      # or
      mit
    ];

    maintainers = with lib.maintainers; [
      astro
    ];
  };
}
