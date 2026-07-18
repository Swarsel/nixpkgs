{
  lib,
  fetchFromGitHub,
  ffmpeg_6,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gifski";
  version = "1.34.0";

  src = fetchFromGitHub {
    owner = "ImageOptim";
    repo = "gifski";
    rev = finalAttrs.version;
    hash = "sha256-8EAC8YH3AIbvYdTL7HtqTL7WqztzCwvDwIVkhiqvtrQ=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    ffmpeg_6
  ];

  cargoHash = "sha256-ZppSO3TyZBbNhG+YW71+C9kMu7ok2+kbnnCRbAKsbfs=";
  buildFeatures = [ "video" ];
  # When the default checkType of release is used, we get the following error:
  #
  #   error: the crate `gifski` is compiled with the panic strategy `abort` which
  #   is incompatible with this crate's strategy of `unwind`
  #
  # It looks like https://github.com/rust-lang/cargo/issues/6313, which does not
  # outline a solution.
  #
  checkType = "debug";

  meta = {
    description = "GIF encoder based on libimagequant (pngquant)";
    homepage = "https://gif.ski/";
    changelog = "https://github.com/ImageOptim/gifski/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
    mainProgram = "gifski";
  };
})
