{
  lib,
  buildGo126Module,
  fetchFromCodeberg,
  installShellFiles,
  jq,
  makeBinaryWrapper,
  nix-update-script,
  scdoc,
}:

buildGo126Module (finalAttrs: {
  pname = "ijq";
  version = "1.3.0";

  src = fetchFromCodeberg {
    owner = "gpanders";
    repo = "ijq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-U4UKhWI/xd7+rLa350oIFlCqbiMSZe3ztPFR0uierOo=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
    scdoc
  ];

  vendorHash = "sha256-aU/0CIbI49OwgY6ioT50uPxld/rHAve3+KoILgPpWSQ=";

  postBuild = ''
    scdoc < ijq.1.scd > ijq.1
    installManPage ijq.1
  '';

  postInstall = ''
    wrapProgram "$out/bin/ijq" \
      --prefix PATH : "${lib.makeBinPath [ jq ]}"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Interactive wrapper for jq";
    homepage = "https://codeberg.org/gpanders/ijq";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      justinas
      mattpolzin
      SuperSandro2000
    ];

    mainProgram = "ijq";
  };
})
