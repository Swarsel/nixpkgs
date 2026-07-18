{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "parpd";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "NetworkConfiguration";
    repo = "parpd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6qmoAW9jm7xMRHZUMQLpe0N+UeVnQP8dC4+Iq+d5Eaw=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Proxy ARP Daemon that complies with RFC 1027";
    homepage = "https://roy.marples.name/projects/parpd";
    changelog = "https://github.com/NetworkConfiguration/parpd/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "parpd";
  };
})
