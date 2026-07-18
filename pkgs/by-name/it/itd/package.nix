{
  lib,
  buildGoModule,
  fetchFromGitea,
}:

buildGoModule (finalAttrs: {
  pname = "itd";
  version = "1.1.0";

  # https://gitea.elara.ws/Elara6331/itd/tags
  src = fetchFromGitea {
    owner = "Elara6331";
    repo = "itd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-95/9Qy0HhrX+ORuv6g1T4/Eq1hf539lYG5fTkLeY6B0=";
    domain = "gitea.elara.ws";
  };

  vendorHash = "sha256-ZkAxNs4yDUFBhhmIRtzxQlEQtsa/BTuHy0g3taFcrMM=";

  preBuild = ''
    echo r${finalAttrs.version} > version.txt
  '';

  postInstall = ''
    install -Dm644 itd.toml $out/etc/itd.toml
  '';

  subPackages = [
    "."
    "cmd/itctl"
  ];

  meta = {
    description = "Daemon to interact with the PineTime running InfiniTime";
    homepage = "https://gitea.elara.ws/Elara6331/itd";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mindavi
      raphaelr
    ];

    platforms = lib.platforms.linux;
  };
})
