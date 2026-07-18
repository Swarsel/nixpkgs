{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  ffmpeg,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  versionCheckHook,
  withEmbeddedLyric ? false,
}:
buildGoModule (finalAttrs: {
  pname = "waybar-lyric";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "Nadim147c";
    repo = "waybar-lyric";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5tMRAq37CZQYemXfJwmj9cj1gR5i9Zii9fqTPDCw45A=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  propagatedBuildInputs = lib.optional withEmbeddedLyric ffmpeg;
  vendorHash = "sha256-zVyUxpAqsWY3/dXlBhPX/o41UP5Afn38JauQsWUqLMk=";

  postInstall =
    lib.optionalString withEmbeddedLyric ''
      wrapProgram $out/bin/waybar-lyric \
        --prefix PATH : ${lib.makeBinPath finalAttrs.propagatedBuildInputs}
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd waybar-lyric \
        --bash <($out/bin/waybar-lyric _carapace bash) \
        --fish <($out/bin/waybar-lyric _carapace fish) \
        --zsh <($out/bin/waybar-lyric _carapace zsh)
    '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  preInstallCheck = ''
    # ERROR Failed to find cache directory
    export XDG_CACHE_HOME=$(mktemp -d)
  '';

  versionCheckKeepEnvironment = [ "XDG_CACHE_HOME" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Waybar module for displaying song lyrics";
    homepage = "https://github.com/Nadim147c/waybar-lyric";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      Nadim147c
      vanadium5000
    ];

    platforms = lib.platforms.linux;
    mainProgram = "waybar-lyric";
  };
})
