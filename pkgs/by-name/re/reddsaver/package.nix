{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "reddsaver";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "manojkarthick";
    repo = "reddsaver";
    rev = "v${finalAttrs.version}";
    sha256 = "07xsrc0w0z7w2w0q44aqnn1ybf9vqry01v3xr96l1xzzc5mkqdzf";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-xYtdGhuieFudfJz+LxUjP7mV8uItaIvLahCH7vBWTtg=";
  # package does not contain tests as of v0.3.3
  docCheck = false;

  meta = {
    description = "CLI tool to download saved media from Reddit";
    homepage = "https://github.com/manojkarthick/reddsaver";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = [ lib.maintainers.manojkarthick ];
    mainProgram = "reddsaver";
  };

})
