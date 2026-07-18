{
  lib,
  fetchFromGitHub,
  installShellFiles,
  openssl,
  pkg-config,
  rustPlatform,
  scdoc,
  which,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "phetch";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "xvxx";
    repo = "phetch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J+ka7/B37WzVPPE2Krkd/TIiVwuKfI2QYWmT0JHgBGQ=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    scdoc
    which
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-2lbQAM3gdytXsoMFzKwLWA1hvQIJf1vBdMRpYx/VLVg=";
  doCheck = true;

  postInstall = ''
    make manual
    installManPage doc/phetch.1
  '';

  meta = {
    description = "Quick lil gopher client for your terminal, written in rust";

    longDescription = ''
      phetch is a terminal client designed to help you quickly navigate the gophersphere.
      - <1MB executable for Linux, Mac, and NetBSD
      - Technicolor design (based on GILD)
      - No-nonsense keyboard navigation
      - Supports Gopher searches, text and menu pages, and downloads
      - Save your favorite Gopher sites with bookmarks
      - Opt-in history tracking
      - Secure Gopher support (TLS)
      - Tor support
    '';

    homepage = "https://github.com/xvxx/phetch";
    changelog = "https://github.com/xvxx/phetch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ felixalbrigtsen ];
    mainProgram = "phetch";
  };
})
