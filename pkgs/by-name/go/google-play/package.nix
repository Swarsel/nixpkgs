{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule rec {
  pname = "google-play";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "UlyssesZh";
    repo = "google-play";
    tag = "v${version}";
    hash = "sha256-CmNBE3SJhDyY77mjC56pl0aiyt4ZW6pEYTtOK3FXGhE=";
  };

  vendorHash = "sha256-q0p9+74qUSY2AAnagtM6d6PPEhM1HHF019QWxTemiIo=";

  subPackages = [
    "internal/play"
    "internal/badging"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI app to download APK from Google Play or send API requests";
    homepage = "https://github.com/UlyssesZh/google-play";
    # https://polyformproject.org/licenses/noncommercial/1.0.0
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.unix;
    mainProgram = "play";
  };
}
