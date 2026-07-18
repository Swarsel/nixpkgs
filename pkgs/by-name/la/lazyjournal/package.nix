{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
let
  version = "0.8.4";
in
buildGoModule {
  inherit version;
  pname = "lazyjournal";

  src = fetchFromGitHub {
    owner = "Lifailon";
    repo = "lazyjournal";
    tag = version;
    hash = "sha256-7/eQZUht8xs8JoivLR3UNxRQ4Gajyp4vhxF4wM0GpPg=";
  };

  vendorHash = "sha256-Wl8DmEBt1YtTk9QEvWybSWRQm0Lnfd5q3C/wg+gP33g=";
  # All checks expect a FHS environment with e.g. log files present,
  # which is evidently not possible in a build environment
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI for journalctl, file system logs, as well as Docker and Podman containers";
    homepage = "https://github.com/Lifailon/lazyjournal";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "lazyjournal";
  };
}
