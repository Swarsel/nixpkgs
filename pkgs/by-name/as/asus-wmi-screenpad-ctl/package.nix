{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
let
  version = "1.0.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "asus-wmi-screenpad-ctl";

  src = fetchFromGitHub {
    owner = "aldenparker";
    repo = "asus-wmi-screenpad-ctl";
    tag = "v${version}";
    hash = "sha256-TV61Kh8A7PFJPRONqeCK1xEK2AHfiV/eoZOCL0SZ+5M=";
  };

  cargoHash = "sha256-ZluFoV9TclY6NOB5sHBN+1ht3zovmb4H+q7qT/Ywwmc=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Brightness control program for the asus-wmi-screenpad kernel module";
    homepage = "https://github.com/aldenparker/asus-wmi-screenpad-ctl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aldenparker ];
    platforms = lib.platforms.linux;
    mainProgram = "asus-wmi-screenpad-ctl";
  };
}
