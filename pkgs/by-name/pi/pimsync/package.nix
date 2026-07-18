{
  lib,
  cacert,
  fetchFromSourcehut,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  pkg-config,
  rustPlatform,
  sqlite,
  versionCheckHook,
  xandikos,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pimsync";
  version = "0.5.10";

  src = fetchFromSourcehut {
    owner = "~whynothugo";
    repo = "pimsync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YqLOkv0I+1HOlWNA8HoKB6/3ccYbV8u/0BJ/+4xvde4=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    installShellFiles
  ];

  buildInputs = [
    sqlite
  ];

  cargoHash = "sha256-9sEYeKZDMsbEUQc5V8xJzcKIzF6ugGsk3d5bTOCtYnw=";
  env.PIMSYNC_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    xandikos
    cacert
  ];

  postInstall = ''
    installManPage pimsync.1 pimsync.conf.5 pimsync-migration.7
    installShellCompletion --zsh contrib/_pimsync
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Synchronise calendars and contacts";
    homepage = "https://git.sr.ht/~whynothugo/pimsync";

    changelog = "https://pimsync.whynothugo.nl/changelog.html#v${
      lib.replaceString "." "-" finalAttrs.version
    }";

    license = lib.licenses.eupl12;

    maintainers = [
      lib.maintainers.qxrein
      lib.maintainers.antonmosich
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pimsync";
  };
})
