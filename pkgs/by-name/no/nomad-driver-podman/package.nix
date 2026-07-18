{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "nomad-driver-podman";
  version = "0.6.5";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad-driver-podman";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ZUZr992bK4e08bh6peYN5B35N7PEVTOSySUWwQ132iA=";
  };

  vendorHash = "sha256-AmG4YQNW20wRfNHl9l8RkByrTIfmAjBxnWvndf1jqYU=";
  # some tests require a running podman service
  doCheck = false;
  subPackages = [ "." ];

  meta = {
    description = "Podman task driver for Nomad";
    homepage = "https://www.github.com/hashicorp/nomad-driver-podman";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ cpcloud ];
    platforms = lib.platforms.linux;
    mainProgram = "nomad-driver-podman";
  };
})
