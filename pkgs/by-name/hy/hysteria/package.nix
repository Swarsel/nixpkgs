{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "hysteria";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "apernet";
    repo = "hysteria";
    rev = "app/v${finalAttrs.version}";
    hash = "sha256-pWiEY1H9iX5aX2nR/K8fNKeAbzLOCZhEe5KLk4arot4=";
  };

  vendorHash = "sha256-IFC/LMI28cGfUTtgTYf045OAEaMdPgd1bzhdSngQlrA=";
  # Network required
  doCheck = false;

  postInstall = ''
    mv $out/bin/app $out/bin/hysteria
  '';

  ldflags =
    let
      cmd = "github.com/apernet/hysteria/app/cmd";
    in
    [
      "-s"
      "-w"
      "-X ${cmd}.appVersion=${finalAttrs.version}"
      "-X ${cmd}.appType=release"
    ];

  proxyVendor = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Feature-packed proxy & relay utility optimized for lossy, unstable connections";
    homepage = "https://github.com/apernet/hysteria";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oluceps ];
    platforms = lib.platforms.unix;
    mainProgram = "hysteria";
  };
})
