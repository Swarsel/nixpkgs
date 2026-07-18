{
  lib,
  stdenv,
  fetchFromGitLab,
  libpulseaudio,
  libx11,
  libxcb,
  libxscrnsaver,
  patchelf,
  pkg-config,
  python3,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xidlehook";
  version = "0.10.0";

  src = fetchFromGitLab {
    owner = "jD91mZM2";
    repo = "xidlehook";
    rev = finalAttrs.version;
    sha256 = "1pl7f8fhxfcy0c6c08vkagp0x1ak96vc5wgamigrk1nkd6l371lb";
  };

  nativeBuildInputs = [
    pkg-config
    patchelf
    python3
  ];

  buildInputs = [
    libx11
    libxcb
    libxscrnsaver
    libpulseaudio
  ];

  cargoHash = "sha256-U1kjOWrFEp1pZnbawW2MCtC4UN7ELD/kcYWfEmn94Pg=";
  doCheck = false;

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    RPATH="$(patchelf --print-rpath $out/bin/xidlehook)"
    patchelf --set-rpath "$RPATH:${libpulseaudio}/lib" $out/bin/xidlehook
  '';

  buildFeatures = lib.optional (!stdenv.hostPlatform.isLinux) "pulse";
  buildNoDefaultFeatures = !stdenv.hostPlatform.isLinux;

  meta = {
    description = "xautolock rewrite in Rust, with a few extra features";
    homepage = "https://github.com/jD91mZM2/xidlehook";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "xidlehook";
  };
})
