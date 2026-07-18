{
  lib,
  fetchFromGitHub,
  dbus,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bzmenu";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "e-tho";
    repo = "bzmenu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O8SC/dfAo1fxnYuaXTTFJCHxOVQgU0sWNdF8lcxdrlU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  cargoHash = "sha256-uoemik9dkAXhpTZ2BBy1aGpwa/WjJ4smLIbtJ8DmNzk=";

  meta = {
    description = "Launcher-driven Bluetooth manager for Linux";

    longDescription = ''
      Use `bzmenu --launcher <launcher command>`
      Supported launchers are: `dmenu`, `fuzzel`, `rofi`, `walker` and `custom` with `stdin`
      for details refer to https://github.com/e-tho/bzmenu/blob/main/README.md#usage
    '';

    homepage = "https://github.com/e-tho/bzmenu";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ vuimuich ];
    platforms = lib.platforms.linux;
    mainProgram = "bzmenu";
  };
})
