{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "etherguard";
  version = "0.3.5-f5";

  src = fetchFromGitHub {
    owner = "KusakabeShi";
    repo = "EtherGuard-VPN";
    rev = "v${finalAttrs.version}";
    hash = "sha256-67ocXHf+AN3nyPt4636ZJHGRqWSjkpTiDvU5243urBw=";
  };

  vendorHash = "sha256-9+zpQ/AhprMMfC4Om64GfQLgms6eluTOB6DdnSTNOlk=";

  meta = {
    description = "Layer 2 version of WireGuard with Floyd Warshall implementation in Go";
    homepage = "https://github.com/KusakabeShi/EtherGuard-VPN";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.linux;
    mainProgram = "EtherGuard-VPN";
  };
})
