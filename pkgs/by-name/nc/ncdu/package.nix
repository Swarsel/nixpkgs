{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  ncurses,
  pkg-config,
  versionCheckHook,
  zig_0_15,
  zstd,
  pie ? stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ncdu";
  version = "2.9.2";

  src = fetchurl {
    url = "https://dev.yorhel.nl/download/ncdu-${finalAttrs.version}.tar.gz";
    hash = "sha256-6RE1KBy2ZWnyykwLrCdyRpkeflJSTAyoy6PeXI6Bzsk=";
  };

  nativeBuildInputs = [
    zig_0_15
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    ncurses
    zstd
  ];

  postInstall = ''
    installManPage ncdu.1
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  zigBuildFlags = lib.optional pie "-Dpie=true";
  passthru.updateScript = ./update.sh;

  meta = {
    inherit (zig_0_15.meta) platforms;
    description = "Disk usage analyzer with an ncurses interface";
    homepage = "https://dev.yorhel.nl/ncdu";
    changelog = "https://dev.yorhel.nl/ncdu/changes2";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pSub
      rodrgz
      defelo
      ryan4yin
    ];

    mainProgram = "ncdu";
  };
})
