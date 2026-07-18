{
  lib,
  fetchFromSourcehut,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "swayr";
  version = "0.28.2";

  src = fetchFromSourcehut {
    owner = "~tsdh";
    repo = "swayr";
    rev = "swayr-${finalAttrs.version}";
    hash = "sha256-uT8MYgH9kANQ0t+7jqjOOvQIZf5ImdQruZLLlCejwcc=";
  };

  patches = [
    ./icon-paths.patch
  ];

  cargoHash = "sha256-Aj4U2xyfNhf3HDSEd1SQ5TyO2MXn2/hrfnG0ZayzMtU=";

  preCheck = ''
    export HOME=$TMPDIR
  '';

  # don't build swayrbar
  buildAndTestSubdir = finalAttrs.pname;

  meta = {
    description = "Window switcher (and more) for sway";
    homepage = "https://git.sr.ht/~tsdh/swayr";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
    mainProgram = "swayr";
  };
})
