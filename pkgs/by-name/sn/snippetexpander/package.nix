{
  lib,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  scdoc,
  snippetexpanderd,
  snippetexpanderx,
}:

buildGoModule (finalAttrs: {
  inherit (snippetexpanderd) src version;
  pname = "snippetexpander";

  nativeBuildInputs = [
    makeWrapper
    scdoc
    installShellFiles
  ];

  buildInputs = [
    snippetexpanderd
    snippetexpanderx
  ];

  vendorHash = "sha256-2nLO/b6XQC88VXE+SewhgKpkRtIHsva+fDudgKpvZiY=";

  postInstall = ''
    make man
    installManPage snippetexpander.1
  '';

  postFixup = ''
    # Ensure snippetexpanderd and snippetexpanderx are available to start/stop.
    wrapProgram $out/bin/snippetexpander \
      --prefix PATH : ${
        lib.makeBinPath [
          snippetexpanderd
          snippetexpanderx
        ]
      }
  '';

  ldflags = [
    "-s"
    "-w"
    "-X 'main.version=${finalAttrs.src.rev}'"
  ];

  modRoot = "cmd/snippetexpander";
  proxyVendor = true;

  meta = {
    description = "Your little expandable text snippet helper CLI";
    homepage = "https://snippetexpander.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "snippetexpander";
  };
})
