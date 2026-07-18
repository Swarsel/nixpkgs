{
  lib,
  fetchCrate,
  gtk4,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "process-viewer";
  version = "0.5.11";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-d2qEcb9iPnhNnRFbzbktk36hyL16opcDgE9xOnmlJGg=";
    pname = "process_viewer";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk4 ];
  cargoHash = "sha256-UD0eTRfHimp6ZGStvrP1upUe3yO3Mw96Sq3OG4Y7zn0=";

  postInstall = ''
    install -Dm644 assets/fr.guillaume_gomez.ProcessViewer.desktop -t $out/share/applications
    install -Dm644 assets/fr.guillaume_gomez.ProcessViewer.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm644 assets/fr.guillaume_gomez.ProcessViewer.metainfo.xml -t $out/share/metainfo
  '';

  __structuredAttrs = true;

  meta = {
    description = "Process viewer GUI in rust";
    homepage = "https://github.com/guillaumegomez/process-viewer";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      matthiasbeyer
      kybe236
    ];

    mainProgram = "process_viewer";
  };
})
