{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeBinaryWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "cloud-nuke";
  version = "0.52.0";

  src = fetchFromGitHub {
    owner = "gruntwork-io";
    repo = "cloud-nuke";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UW6n1TFKkricWX71/zHGwLY+0fLtZRkAUU8bQQc5Lwg=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  vendorHash = "sha256-ztaQ4PnBk5lr5PXK6O0MYt+dUNKIxB+/gpGZ4izaqWs=";
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/cloud-nuke --set-default DISABLE_TELEMETRY true
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.VERSION=${finalAttrs.version}"
  ];

  meta = {
    description = "Tool for cleaning up your cloud accounts by nuking (deleting) all resources within it";
    homepage = "https://github.com/gruntwork-io/cloud-nuke";
    changelog = "https://github.com/gruntwork-io/cloud-nuke/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "cloud-nuke";
  };
})
