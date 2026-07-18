{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gtk-layer-shell,
  gtk3,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "nwg-dock";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-dock";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Ymk4lpX8RAxWot7U+cFtu1eJd6VHP+JS1I2vF0V1T70=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk3
    gtk-layer-shell
  ];

  vendorHash = "sha256-iR+ytThRwmCvFEMcpSELPRwiramN5jPXAjaJtda4pOw=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "GTK3-based dock for sway";
    homepage = "https://github.com/nwg-piotr/nwg-dock";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "nwg-dock";
  };
})
