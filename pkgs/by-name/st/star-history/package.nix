{
  lib,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "star-history";
  version = "1.0.32";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-JilIVnxSXEK525TK+mHal+37G7PYcaQogVC2ozYeLY4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-9qKdn3q4d4N36+jng4ZKfazcxR9iMOh1PeUNYfZz8pg=";

  meta = {
    description = "Command line program to generate a graph showing number of GitHub stars of a user, org or repo over time";
    homepage = "https://github.com/dtolnay/star-history";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = [ lib.maintainers.matthiasbeyer ];
    mainProgram = "star-history";
  };
})
