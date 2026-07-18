{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gnumake,
  gtk3,
  installShellFiles,
  mumble,
  nix-update-script,
  pkg-config,
  rubyPackages,
  tor,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "wahay";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "digitalautonomy";
    repo = "wahay";
    tag = "v${finalAttrs.version}";
    hash = "sha256-59gVGDElIs+OQ/ELwOFjz6YqG18iHqoa2yYF2Ddi0/o=";
  };

  postPatch = ''
    # Avoid Git invocation: Remove assignments starting with ‘$(shell git’
    sed -E -i \
      -e '/^\w+\s*[+:]?=\s*\$\(shell\s+git\>/d' \
      Makefile
  '';

  nativeBuildInputs = [
    gnumake
    pkg-config
    rubyPackages.sass
    installShellFiles
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
  ];

  vendorHash = "sha256-w8lUnvy5dPMHWbzyyTq9Q/kE/4vSuOHffaY9CeasvQ0=";

  buildPhase = ''
    runHook preBuild
    make TAG_VERSION=v${finalAttrs.version} \
         BUILD_TIMESTAMP="$(date -u -d "@$SOURCE_DATE_EPOCH" '+%Y-%m-%d %H:%M:%S')" \
         build
    runHook postBuild
  '';

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  checkPhase = ''
    runHook preCheck
    make test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    installBin bin/wahay
    installManPage packaging/ubuntu/ubuntu/usr/share/man/man1/wahay.1.gz
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${
        lib.escapeShellArg (
          lib.makeBinPath [
            tor
            mumble
          ]
        )
      }
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Decentralized encrypted conference call application";
    homepage = "https://wahay.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dvn0 ];
    mainProgram = "wahay";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
