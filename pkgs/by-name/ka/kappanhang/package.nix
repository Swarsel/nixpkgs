{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  pkg-config,
  pulseaudio,
}:

buildGoModule (finalAttrs: {
  pname = "kappanhang";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "nonoo";
    repo = "kappanhang";
    rev = "v${finalAttrs.version}";
    hash = "sha256-l0V2NVzLsnpPe5EJcr5i9U7OGaYzNRDd1f/ogrdCnvk=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pulseaudio ];
  vendorHash = "sha256-CnZTUP2JBbhG8VUHbVX+vicfQJC9Y8endlwQHdmzMus=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Remote control for Icom radio transceivers";
    homepage = "https://github.com/nonoo/kappanhang";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mvs ];
    platforms = lib.platforms.linux;
    mainProgram = "kappanhang";
  };
})
