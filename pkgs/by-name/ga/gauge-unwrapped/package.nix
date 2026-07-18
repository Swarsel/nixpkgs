{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gauge";
  version = "1.6.32";

  src = fetchFromGitHub {
    owner = "getgauge";
    repo = "gauge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j8nT39mwRvccZQyrhviQxPbM3Cd7F2x4X24OYFq3LYQ=";
  };

  patches = [
    # adds a check which adds an error message when trying to
    # install plugins imperatively when using the wrapper
    ./nix-check.patch
  ];

  vendorHash = "sha256-OmGKpgsouK5W/DWFi8vNT/0HSX5HqaAzNdN8eEAhNhk=";

  excludedPackages = [
    "build"
    "man"
  ];

  meta = {
    description = "Light weight cross-platform test automation";
    homepage = "https://gauge.org";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      vdemeester
    ];

    mainProgram = "gauge";
  };
})
