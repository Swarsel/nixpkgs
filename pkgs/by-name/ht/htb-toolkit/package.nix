{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  gnome-keyring,
  gzip,
  killall,
  libsecret,
  openssl,
  openvpn,
  pkg-config,
  rustPlatform,
  unstableGitUpdater,
}:

rustPlatform.buildRustPackage {
  pname = "htb-toolkit";
  version = "0-unstable-2025-12-19";

  src = fetchFromGitHub {
    owner = "D3vil0p3r";
    repo = "htb-toolkit";
    # https://github.com/D3vil0p3r/htb-toolkit/issues/3
    rev = "4f1c6bded11d8c907c951fcbe63f1fc44568a9f9";
    hash = "sha256-pkZ5KVSgtrWfXhJ3knmyOIArIjyAjMmm5WcrrB2pCKY=";
  };

  # Patch to disable prompt change of the shell when a target machine is run. Needed due to Nix declarative nature
  patches = [
    ./disable-shell-prompt-change.patch
  ];

  postPatch = ''
    substituteInPlace src/utils.rs \
      --replace-fail "\"base64\"" "\"${coreutils}/bin/base64\"" \
      --replace-fail "\"gunzip\"" "\"${gzip}/bin/gunzip\""
    substituteInPlace src/appkey.rs \
      --replace-fail secret-tool ${lib.getExe libsecret}
    substituteInPlace src/vpn.rs \
      --replace-fail "arg(\"openvpn\")" "arg(\"${openvpn}/bin/openvpn\")" \
      --replace-fail "arg(\"killall\")" "arg(\"${killall}/bin/killall\")"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    gnome-keyring
  ];

  cargoHash = "sha256-ReEe8pyW66GXIPwAy6IKsFEAUjxHmzw5mj21i/h4quQ=";
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Play Hack The Box directly on your system";
    homepage = "https://github.com/D3vil0p3r/htb-toolkit";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "htb-toolkit";
  };
}
