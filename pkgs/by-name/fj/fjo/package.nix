{
  lib,
  stdenv,
  fetchFromCodeberg,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fjo";
  version = "0.3.5";

  src = fetchFromCodeberg {
    owner = "VoiDD";
    repo = "fjo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KjH78yqfZoN24TBYyFZuxf7z9poRov0uFYQ8+eq9p/o=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-iF2hIeRnyYYyyg45c1E3NIR9m7oonY18JlGvFSXy/Lc=";

  meta = {
    description = "CLI Tool for Codeberg similar to gh and glab";
    homepage = "https://codeberg.org/VoiDD/fjo";
    license = lib.licenses.agpl3Only;
    mainProgram = "berg";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
