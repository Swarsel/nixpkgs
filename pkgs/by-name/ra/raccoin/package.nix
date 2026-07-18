{
  lib,
  fetchFromGitHub,
  alsa-lib,
  cairo,
  fontconfig,
  freetype,
  harfbuzz,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  nix-update-script,
  openssl,
  pango,
  pkg-config,
  rustPlatform,
  wayland,
  withWayland ? true,
  withX11 ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "raccoin";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "bjorn";
    repo = "raccoin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6BwRFU8qU6K0KqKdK+soKcWU2LPxkKKPOcn2gupunGg=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    cairo
    pango
    harfbuzz
    fontconfig
    freetype
    alsa-lib
    libGL
    openssl
    libxkbcommon
  ]
  ++ lib.optionals withWayland [
    wayland
  ]
  ++ lib.optionals withX11 [
    libx11
    libxcursor
    libxi
    libxrandr
  ];

  cargoHash = "sha256-pz3dwIIBQZIwTammiI/UQwM0Iy1ZgC9ntK+qNGv3s24=";
  # upstream has no tests
  doCheck = false;

  # alternatively when tests are added later
  #doCheck = true;
  #checkPhase = ''
  #  cargo test --lib -- --nocapture
  #'';
  #passthru.tests.version = testers.testVersion { package = raccoin; };
  postFixup = ''
    patchelf --set-rpath "${
      lib.makeLibraryPath (
        [
          fontconfig
          libxkbcommon
          openssl
        ]
        ++ lib.optional withX11 libx11
      )
    }" \
      $out/bin/raccoin
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Crypto portfolio & capital-gains reporting tool (Rust + Slint)";

    longDescription = ''
      This GUI Tool enables accounting with the quite basic principle
      "first in, first out" (FIFO) in multiple wallets. It is for
      e.g. bitcoiners that actually use the currency and want
      reports on their holdings.
    '';

    homepage = "https://raccoin.org";
    changelog = "https://github.com/bjorn/raccoin/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ vv01f ];
    platforms = lib.platforms.linux;
    mainProgram = "raccoin";
  };
})
