{
  lib,
  stdenv,
  fetchFromSourcehut,
  gtk3,
  libdbusmenu-gtk3,
  nix-update-script,
  pkg-config,
  vala,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snixembed";
  version = "0.3.3";

  src = fetchFromSourcehut {
    owner = "~steef";
    repo = "snixembed";
    rev = finalAttrs.version;
    hash = "sha256-co32Xlklg6KVyi+xEoDJ6TeN28V+wCSx73phwnl/05E=";
  };

  nativeBuildInputs = [
    pkg-config
    vala
  ];

  buildInputs = [
    gtk3
    libdbusmenu-gtk3
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Proxy StatusNotifierItems as XEmbedded systemtray-spec icons";
    homepage = "https://git.sr.ht/~steef/snixembed";
    changelog = "https://git.sr.ht/~steef/snixembed/refs/${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    platforms = lib.platforms.unix;
    mainProgram = "snixembed";
  };
})
