{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  librsvg,
  pkg-config,
  wrapGAppsHook3,
}:

buildGoModule (finalAttrs: {
  pname = "ymuse";
  version = "0.22";

  src = fetchFromGitHub {
    owner = "yktoo";
    repo = "ymuse";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WbIeqOAhdqxU8EvHEsG7ASwy5xZG1domZKT5ccOggHg=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    glib
    gobject-introspection
    gdk-pixbuf
    gettext
  ];

  buildInputs = [
    gtk3
    librsvg
  ];

  vendorHash = "sha256-YT4JiieVI6/t4inezE3K2WQBI51W+/MoWr7R/uBzn+8=";
  # IDK how to deal with tests that open up display.
  doCheck = false;

  postInstall = ''
    install -Dm644 ./resources/com.yktoo.ymuse.desktop -t $out/share/applications
    install -Dm644 ./resources/metainfo/com.yktoo.ymuse.metainfo.xml -t $out/share/metainfo
    cp -r ./resources/icons $out/share

    app_id="ymuse"
    find ./resources/i18n -type f -name '*.po' |
    while read file; do
        # Language is the filename without the extension
        lang="$(basename "$file")"
        lang="''${lang%.*}"

        # Create the target dir if needed
        target_dir="$out/share/locale/$lang/LC_MESSAGES"
        mkdir -p "$target_dir"

        # Compile the .po into a .mo
        echo "Compiling $file" into "$target_dir/$app_id.mo"
        msgfmt "$file" -o "$target_dir/$app_id.mo"
    done
  '';

  meta = {
    description = "GTK client for Music Player Daemon (MPD)";
    homepage = "https://yktoo.com/en/software/ymuse/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ymuse";
  };
})
