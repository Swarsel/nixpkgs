{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  installShellFiles,
  makeWrapper,
  scdoc,
  wl-clipboard,
  wtype,
  xclip,
  xdotool,
}:

buildGoModule (finalAttrs: {
  pname = "snippetexpanderd";
  version = "1.0.3";

  src = fetchFromSourcehut {
    owner = "~ianmjones";
    repo = "snippetexpander";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NIMuACrq8RodtjeBbBY42VJ8xqj7fZvdQ2w/5QsjjJI=";
  };

  nativeBuildInputs = [
    makeWrapper
    scdoc
    installShellFiles
  ];

  buildInputs = [
    xclip
    wl-clipboard
    xdotool
    wtype
  ];

  vendorHash = "sha256-2nLO/b6XQC88VXE+SewhgKpkRtIHsva+fDudgKpvZiY=";

  postInstall = ''
    make man
    installManPage snippetexpanderd.1 snippetexpander-placeholders.5
  '';

  postFixup = ''
    # Ensure xclip/wcopy and xdotool/wtype are available for copy and paste duties.
    wrapProgram $out/bin/snippetexpanderd \
      --prefix PATH : ${
        lib.makeBinPath [
          xclip
          wl-clipboard
          xdotool
          wtype
        ]
      }
  '';

  ldflags = [
    "-s"
    "-w"
    "-X 'main.version=${finalAttrs.src.rev}'"
  ];

  modRoot = "cmd/snippetexpanderd";
  proxyVendor = true;

  meta = {
    description = "Your little expandable text snippet helper daemon";
    homepage = "https://snippetexpander.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "snippetexpanderd";
  };
})
