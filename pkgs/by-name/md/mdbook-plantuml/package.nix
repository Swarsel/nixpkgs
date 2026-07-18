{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "mdbook-plantuml";
  version = "v2.0.0";

  src = fetchFromGitHub {
    owner = "sytsereitsma";
    repo = "mdbook-plantuml";
    rev = "dae70cfd3deb8438127cc369a92ecefe24acb6a2";
    hash = "sha256-PNVWeXbYDX/PYFCSPKKeqdbhLl9hmDOK7i7lWQlbEK0=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-8DKnINclcX0WwRtCTv7DUBx/6omRvda3qg3a1g1lyFA=";

  meta = {
    description = "mdBook preprocessor to render PlantUML diagrams to png images in the book output directory";
    homepage = "https://github.com/sytsereitsma/mdbook-plantuml";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jcouyang
      matthiasbeyer
    ];

    mainProgram = "mdbook-plantuml";
  };
}
