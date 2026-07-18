{
  lib,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "radio-cli";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "margual56";
    repo = "radio-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-De/3tkvHf8dp04A0hug+aCbiXUc+XUYeHWYOiJ/bac0=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-mxSlyQpMzLbiIbcVQUILHDyLsCf/9fanX9/yf0hyXHA=";

  postInstall = ''
    wrapProgram "$out/bin/radio-cli" \
      --suffix PATH : ${lib.makeBinPath [ mpv ]}
  '';

  meta = {
    description = "Simple radio CLI written in rust";
    homepage = "https://github.com/margual56/radio-cli";
    changelog = "https://github.com/margual56/radio-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ luftmensch-luftmensch ];
    platforms = lib.platforms.unix;
    mainProgram = "radio-cli";
  };
})
