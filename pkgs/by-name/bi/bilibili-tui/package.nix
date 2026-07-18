{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  mpv-unwrapped,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  yt-dlp-light,
  withMpv ? true,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bilibili-tui";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "MareDevi";
    repo = "bilibili-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LACNDpVhlYEgT3fN+Ff2MVipblUqPlqwOUpTLaXSCbk=";
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ pkg-config ];
  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ openssl ];
  cargoHash = "sha256-q3jRjmzQA64sZjVShoEmu1x2CFOAgBGgZYyTq7Lg4is=";
  env.OPENSSL_NO_VENDOR = true;

  # Wrap mpv as fallback; users should prefer their system's mpv in PATH
  postInstall = lib.optionalString withMpv ''
    wrapProgram $out/bin/bilibili-tui \
      --suffix PATH : ${
        lib.makeBinPath [
          mpv-unwrapped
          yt-dlp-light
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal user interface (TUI) client for Bilibili";
    homepage = "https://maredevi.moe/projects/bilibili-tui/";
    changelog = "https://github.com/MareDevi/bilibili-tui/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puiyq ];
    mainProgram = "bilibili-tui";
    downloadPage = "https://github.com/MareDevi/bilibili-tui/releases";
  };
})
