{
  lib,
  fetchFromGitHub,
  pipewire,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pwmenu";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "e-tho";
    repo = "pwmenu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aaYXW9QX8JKk1Zk3wk3g4YGjP7DplQKqEzx7YC8w+Ts=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    pipewire
  ];

  cargoHash = "sha256-EMrGub0Dwxmky9c2W3pZKTaGvLbIHy44HejKuuL+PrE=";

  meta = {
    description = "Launcher-driven audio manager for Linux";

    longDescription = ''
      Use `pwmenu --launcher <launcher command>`
      Supported launchers are: `dmenu`, `fuzzel`, `rofi`, `walker` and `custom` with `stdin`
      for details refer to https://github.com/e-tho/pwmenu/blob/main/README.md#usage
    '';

    homepage = "https://github.com/e-tho/pwmenu";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ vuimuich ];
    platforms = lib.platforms.linux;
    mainProgram = "pwmenu";
  };
})
