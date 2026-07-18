{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mdbook-pagecrypt";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Wybxc";
    repo = "mdbook-pagecrypt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JO6keFFTvpyE7Qefstxi1tZuyJcwqF/HD8hf3Mi/y4g=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-+cw/F6JZAwhdUjdhGT3qfvAf8qZ7J4ftHsfRTz6McWE=";

  meta = {
    description = "Encrypt your mdBook-built site with password protection";
    homepage = "https://github.com/Wybxc/mdbook-pagecrypt";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ jhult ];
    mainProgram = "mdbook-pagecrypt";
  };
})
