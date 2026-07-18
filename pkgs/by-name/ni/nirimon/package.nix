{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
  wl-mirror,
}:

buildGoModule (finalAttrs: {
  pname = "nirimon";
  version = "2026.605.1";

  src = fetchFromGitHub {
    owner = "stepbrobd";
    repo = "nirimon";
    tag = finalAttrs.version;
    hash = "sha256-mdBl2QuvAYEltGB2kE0EJhQtWSSZ78qdpSzWKreDZUY=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-txuaYMyYYalKGQ5RIuPL/ERyDt/eMeo85aZSgx4HbZk=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    wrapProgram $out/bin/nirimon --prefix PATH : "${lib.makeBinPath [ wl-mirror ]}"
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "-version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI monitor configuration tool for niri with visual layout, drag-and-drop, and profile management";
    homepage = "https://github.com/stepbrobd/nirimon";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ stepbrobd ];
    platforms = lib.platforms.linux;
    mainProgram = "nirimon";
  };
})
