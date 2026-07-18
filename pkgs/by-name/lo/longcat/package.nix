{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

let
  version = "0.0.18";
in
buildGoModule {
  inherit version;
  pname = "longcat";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = "longcat";
    tag = "v${version}";
    hash = "sha256-5D+hGWwpjRLDNw1zwM+tkVPHRebERU83Gye6WQZUuhg=";
  };

  vendorHash = "sha256-VcNhzQyhd7gDvlrz7Lh2QRUkMjZj40s2hanNP6gsnMs=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Renders a picture of a long cat on the terminal";
    homepage = "https://github.com/mattn/longcat";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bubblepipe
    ];

    platforms = lib.platforms.all;
    mainProgram = "longcat";
  };
}
