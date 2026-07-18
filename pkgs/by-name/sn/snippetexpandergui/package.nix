{
  lib,
  buildGoModule,
  gtk3,
  installShellFiles,
  libx11,
  scdoc,
  # webkitgtk_4_0,
  snippetexpanderd,
  snippetexpanderx,
  wails,
  wrapGAppsHook3,
}:

buildGoModule rec {
  inherit (snippetexpanderd) src version;
  pname = "snippetexpandergui";

  nativeBuildInputs = [
    wails
    scdoc
    installShellFiles
    wrapGAppsHook3
  ];

  buildInputs = [
    libx11
    gtk3
    # webkitgtk_4_0
    snippetexpanderd
    snippetexpanderx
  ];

  vendorHash = "sha256-2nLO/b6XQC88VXE+SewhgKpkRtIHsva+fDudgKpvZiY=";

  postInstall = ''
    mv build/linux/share $out/share
    make man
    installManPage snippetexpandergui.1
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      # Ensure snippetexpanderd and snippetexpanderx are available to start/stop.
      --prefix PATH : ${
        lib.makeBinPath [
          snippetexpanderd
          snippetexpanderx
        ]
      }
    )
  '';

  ldflags = [
    "-s"
    "-w"
    "-X 'main.version=${src.rev}'"
  ];

  modRoot = "cmd/snippetexpandergui";
  proxyVendor = true;

  tags = [
    "desktop"
    "production"
  ];

  meta = {
    description = "Your little expandable text snippet helper GUI";
    homepage = "https://snippetexpander.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "snippetexpandergui";
    # webkitgtk_4_0 was removed
    broken = true;
  };
}
