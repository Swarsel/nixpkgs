{
  lib,
  fetchFromGitHub,
  lcms2,
  libpng,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pngquant";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "kornelski";
    repo = "pngquant";
    tag = finalAttrs.version;
    hash = "sha256-u2zEp9Llo+c/+1QGW4V4r40KQn/ATHCTEsrpy7bRf/I=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpng
    zlib
    lcms2
  ];

  cargoHash = "sha256-W+/y79KkSVHqBybouUazGVfTQAuelXvn6EXtu+TW7j4=";
  doCheck = false; # Has no Rust-based tests

  postInstall = ''
    install -Dpm0444 pngquant.1 $man/share/man/man1/pngquant.1
  '';

  cargoPatches = [
    # https://github.com/kornelski/pngquant/issues/347
    ./add-Cargo.lock.patch
  ];

  meta = {
    description = "Tool to convert 24/32-bit RGBA PNGs to 8-bit palette with alpha channel preserved";
    homepage = "https://pngquant.org/";
    changelog = "https://github.com/kornelski/pngquant/raw/${finalAttrs.version}/CHANGELOG";

    license = with lib.licenses; [
      gpl3Plus
      hpnd
      bsd2
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "pngquant";
  };
})
