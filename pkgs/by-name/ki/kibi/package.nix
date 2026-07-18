{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kibi";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "ilai-deutel";
    repo = "kibi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uGCtFS29XVrYXOHAeTT5QmYwCIQWg2SRmgw3CP5O0+c=";
  };

  nativeBuildInputs = [ makeWrapper ];
  cargoHash = "sha256-lBBIEceZgxwoM2DoD+iFtlNdnO5LkvIf2/8CB2uPH3Y=";

  postInstall = ''
    install -Dm644 syntax.d/* -t $out/share/kibi/syntax.d
    install -Dm644 kibi.desktop -t $out/share/applications
    install -Dm644 assets/kibi.svg -t $out/share/icons/hicolor/scalable/apps
    wrapProgram $out/bin/kibi --prefix XDG_DATA_DIRS : "$out/share"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Text editor in ≤1024 lines of code, written in Rust";
    homepage = "https://github.com/ilai-deutel/kibi";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      robertodr
      ilai-deutel
    ];

    mainProgram = "kibi";
  };
})
