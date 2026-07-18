{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uwuify";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "Daniel-Liu-c0deb0t";
    repo = "uwu";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-MzXObbxccwEG7egmQMCdhUukGqZS+NgbYwZjTaqME7I=";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  cargoHash = "sha256-gR3FL1GeD9Dx5TKeThmPScMCRJQ2THlO4pBViXlI9XM=";

  meta = {
    description = "Fast text uwuifier";
    homepage = "https://github.com/Daniel-Liu-c0deb0t/uwu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.x86; # uses SSE instructions
    mainProgram = "uwuify";
  };
})
