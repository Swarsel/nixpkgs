{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libstrophe,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xmpp-bridge";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "majewsky";
    repo = "xmpp-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JXhVi2AiV/PmWPfoQJl/N92GAZQ9UxReAiCkiDxgdFY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    libstrophe
  ];

  # Makefile is hardcoded to install to /usr, install manually
  installPhase = ''
    runHook  preInstall

    install -D -m 0755 build/xmpp-bridge "$out/bin/xmpp-bridge"
    installManPage xmpp-bridge.1

    runHook postInstall
  '';

  meta = {
    description = "Connect command-line programs to XMPP";
    homepage = "https://github.com/majewsky/xmpp-bridge";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ gigahawk ];
    platforms = lib.platforms.unix;
    mainProgram = "xmpp-bridge";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
