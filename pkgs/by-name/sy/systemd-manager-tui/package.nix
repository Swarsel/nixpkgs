{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "systemd-manager-tui";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "Matheus-git";
    repo = "systemd-manager-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cai+5DugKSupFZASNg4QelB3sPi4MvTy5YkA0hB13wo=";
  };

  cargoHash = "sha256-y3RoekDMK+COaC0zuSTD6l/Ugl81qLG/3VSWYTDRA5o=";

  meta = {
    description = "Program for managing systemd services through a TUI";
    homepage = "https://github.com/Matheus-git/systemd-manager-tui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vuimuich ];
    platforms = lib.platforms.linux;
    mainProgram = "systemd-manager-tui";
  };
})
