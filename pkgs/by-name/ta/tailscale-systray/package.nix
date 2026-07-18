{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gtk3,
  libayatana-appindicator,
  pkg-config,
}:
buildGoModule {
  pname = "tailscale-systray";
  version = "2022-10-19";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = "tailscale-systray";
    rev = "e7f8893684e7b8779f34045ca90e5abe6df6056d";
    sha256 = "sha256-3kozp6jq0xGllxoK2lGCNUahy/FvXyq11vNSxfDehKE=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk3
    libayatana-appindicator
  ];

  vendorHash = "sha256-YJ74SeZAMS+dXyoPhPTJ3L+5uL5bF8gumhMOqfvmlms=";
  proxyVendor = true;

  meta = {
    description = "Tailscale systray";
    homepage = "https://github.com/mattn/tailscale-systray";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ qbit ];
    mainProgram = "tailscale-systray";
  };
}
