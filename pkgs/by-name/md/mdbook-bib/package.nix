{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mdbook-bib";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "francisco-perez-sorrosal";
    repo = "mdbook-bib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IhGwVnUYjnwZmZJkt1Z9yFlNcJ2EObnqFHmmfJNco/M=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-A1rOfXZP4rFtLX3pmLwB99FBws1wMotKnMPfqnYW9m0=";
  __structuredAttrs = true;

  meta = {
    description = "mdBook plugin for creating a bibliography & citations in your books";
    homepage = "https://github.com/francisco-perez-sorrosal/mdbook-bib";
    changelog = "https://github.com/francisco-perez-sorrosal/mdbook-bib/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ markhakansson ];
    mainProgram = "mdbook-bib";
  };
})
