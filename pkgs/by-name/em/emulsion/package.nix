{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  libxxf86vm,
  makeWrapper,
  pkg-config,
  python3,
  rustPlatform,
  wayland,
}:
let
  rpathLibs = [
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
    libxxf86vm
    libxcb
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libxkbcommon
    wayland
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "emulsion";
  version = "12.3";

  src = fetchFromGitHub {
    owner = "ArturKovacs";
    repo = "emulsion";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-+C4YB5usNKfNydyEyIvaScnjK0h/PKN1x8gnt7Lz2kQ=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    pkg-config
    python3
  ];

  buildInputs = rpathLibs;
  cargoHash = "sha256-i+lSUSgq98iT9OzsdkZgRidLszc6mJJA1b1Jfq+yk5s=";

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/emulsion
  '';

  meta = {
    description = "Fast and minimalistic image viewer";
    homepage = "https://arturkovacs.github.io/emulsion-website/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.unix;
    mainProgram = "emulsion";
  };
})
