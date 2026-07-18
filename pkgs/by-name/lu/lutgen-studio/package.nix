{
  lib,
  fetchFromGitHub,
  fontconfig,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  nix-update-script,
  openssl,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lutgen-studio";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ozwaldorf";
    repo = "lutgen-rs";
    tag = "lutgen-studio-v${finalAttrs.version}";
    hash = "sha256-8sayt1gLJPdhesUvSoykUYjIiGLRJH5avsRSrWLfIVE=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-CJXobmGOFEOiycrtgKjupVwTCYLMQcEI7RdLGpwmSyg=";

  postInstall =
    let
      # Include dynamically loaded libraries
      LD_LIBRARY_PATH = lib.makeLibraryPath [
        fontconfig
        libGL
        libxkbcommon
        openssl
        wayland
        libxcursor
        libxrandr
        libxi
        libx11
      ];
    in
    ''
      wrapProgram "$out/bin/lutgen-studio" \
        --set LD_LIBRARY_PATH "${LD_LIBRARY_PATH}"
    '';

  cargoBuildFlags = [
    "--bin"
    "lutgen-studio"
  ];

  cargoTestFlags = [
    "-p"
    "lutgen-studio"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^lutgen-studio-v([0-9.]+)$" ];
  };

  meta = {
    description = "Official GUI for Lutgen, the best way to apply popular colorschemes to any image or wallpaper";
    homepage = "https://github.com/ozwaldorf/lutgen-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ozwaldorf ];
    mainProgram = "lutgen-studio";
  };
})
