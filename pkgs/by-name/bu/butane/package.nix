{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "butane";
  version = "0.29.0";

  src = fetchFromGitHub {
    owner = "coreos";
    repo = "butane";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lijMfxhUBopwbfEP4fEgszXh7zaRz7Xy1Y8PmatXXTE=";
  };

  vendorHash = null;
  doCheck = false;

  postInstall = ''
    mv $out/bin/{internal,butane}
  '';

  ldflags = [
    "-X github.com/coreos/butane/internal/version.Raw=v${finalAttrs.version}"
  ];

  subPackages = [ "internal" ];

  meta = {
    description = "Translates human-readable Butane configs into machine-readable Ignition configs";
    homepage = "https://github.com/coreos/butane";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      elijahcaine
      ruuda
    ];

    mainProgram = "butane";
  };
})
