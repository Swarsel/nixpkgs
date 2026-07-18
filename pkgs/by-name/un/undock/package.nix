{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "undock";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "crazy-max";
    repo = "undock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PA2v5k2EciNtcDhLNJCRstLWpuk1RfKOhc9oyYaNehc=";
  };

  vendorHash = null;
  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/cmd $out/bin/undock
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  tags = [
    "containers_image_openpgp"
    "exclude_graphdriver_btrfs"
    "exclude_graphdriver_devicemapper"
  ];

  meta = {
    description = "Extract contents of a container image in a local folder";
    homepage = "https://crazymax.dev/undock/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nolith
    ];

    mainProgram = "undock";
  };
})
