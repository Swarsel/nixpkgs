{
  lib,
  fetchFromGitHub,
  gtk4,
  pango,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "packetry";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "packetry";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mgQmorh/MSSufVyOspVtZhBn4nS1vITAiiDXv+/dc/o=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    pango
  ];

  cargoHash = "sha256-qku45EAnsZetQ3Q0Y5Pr1OL/St0j6DGIjnlohA8+pDs=";

  # Disable test_replay tests as they need a gui
  preCheck = ''
    substituteInPlace src/ui/test_replay.rs \
      --replace-fail '#[test]' '#[test] #[ignore]'
  '';

  # packetry-cli is only necessary on windows https://github.com/greatscottgadgets/packetry/pull/154
  postInstall = ''
    rm $out/bin/packetry-cli
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "USB 2.0 protocol analysis application for use with Cynthion";
    homepage = "https://github.com/greatscottgadgets/packetry";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ carlossless ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "packetry";
  };
})
