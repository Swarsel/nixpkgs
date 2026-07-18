{
  lib,
  stdenv,
  fetchFromGitHub,
  argparse,
  cmake,
  curl,
  nix-update-script,
  nlohmann_json,
  pkg-config,
  spdlog,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "d2hs";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "neboer";
    repo = "DNS2HostsSyncer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AYORL/efnE5OiRyVAFMlJUsbL1XBG6QAKjGWOYv+iEM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    nlohmann_json
    spdlog
    argparse
    curl
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ./d2hs $out/bin/d2hs
    runHook postInstall
  '';

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Small tool for periodically syncing dns records to hosts";
    homepage = "https://github.com/Neboer/DNS2HostsSyncer";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      peigongdsd
    ];

    platforms = lib.platforms.all;
    mainProgram = "d2hs";
  };
})
