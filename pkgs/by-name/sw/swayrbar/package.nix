{
  lib,
  fetchFromSourcehut,
  makeWrapper,
  pulseaudio,
  rustPlatform,
  withPulseaudio ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "swayrbar";
  version = "0.5.0";

  src = fetchFromSourcehut {
    owner = "~tsdh";
    repo = "swayr";
    tag = "swayrbar-${finalAttrs.version}";
    sha256 = "sha256-uT8MYgH9kANQ0t+7jqjOOvQIZf5ImdQruZLLlCejwcc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-Aj4U2xyfNhf3HDSEd1SQ5TyO2MXn2/hrfnG0ZayzMtU=";

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = lib.optionals withPulseaudio ''
    wrapProgram "$out/bin/swayrbar" \
      --prefix PATH : "$out/bin:${lib.makeBinPath [ pulseaudio ]}"
  '';

  # don't build swayr
  buildAndTestSubdir = finalAttrs.pname;

  meta = {
    description = "Status command for sway's swaybar implementing the swaybar-protocol";
    homepage = "https://git.sr.ht/~tsdh/swayr#a-idswayrbarswayrbara";
    changelog = "https://git.sr.ht/~tsdh/swayr/tree/main/item/swayrbar/NEWS.md";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = lib.platforms.linux;
    mainProgram = "swayrbar";
  };
})
