{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  pcsclite,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "keycard-cli";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "keycard-tech";
    repo = "keycard-cli";
    rev = finalAttrs.version;
    hash = "sha256-H9fipHGxINMAXdxUYhyVZusDXA3HW1iQl8iRX6AF7iE=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcsclite ];
  vendorHash = "sha256-6zZY6pMazapteJp2fsCdwXBEXbwSf/ZEUIcQONJYj2Q=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Command line tool and shell to manage keycards";
    homepage = "https://keycard.status.im";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.zimbatm ];
    mainProgram = "keycard-cli";
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/keycard-cli.x86_64-darwin
  };
})
