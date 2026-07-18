{
  lib,
  stdenv,
  fetchFromGitHub,
  libsixel,
  libxcb,
  makeBinaryWrapper,
  mpv,
  openssl,
  pkg-config,
  python3,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "youtube-tui";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "Siriusmart";
    repo = "youtube-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bTdhncgtQaC367P7OLfX5om+Zn0+V5HHGaWJ252xnrA=";
  };

  nativeBuildInputs = [
    pkg-config
    python3
    makeBinaryWrapper
  ];

  buildInputs = [
    openssl
    libxcb
    libsixel
    mpv
  ];

  cargoHash = "sha256-Mq0FyapMGufTyPJXfRVZtPa3XMdimZ8nSXqTue1tdA0=";

  # sixel-sys is dynamically linked to libsixel
  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    wrapProgram $out/bin/youtube-tui \
      --prefix DYLD_LIBRARY_PATH : "${lib.makeLibraryPath [ libsixel ]}"
  '';

  meta = {
    description = "Aesthetically pleasing YouTube TUI written in Rust";
    homepage = "https://siriusmart.github.io/youtube-tui";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Ruixi-rebirth ];
    mainProgram = "youtube-tui";
  };
})
