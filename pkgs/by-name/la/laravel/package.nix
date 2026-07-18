{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  php,
}:
php.buildComposerProject2 (finalAttrs: {
  pname = "laravel";
  version = "5.25.3";

  src = fetchFromGitHub {
    owner = "laravel";
    repo = "installer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WpBpKCXvfcMXb7Zxvz7fdxVMaaseH0kxr+Fh/vYVb+Y=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-zm2Xh15l/i7jDL3OasIqLUAWOLM71sQvA4LuszDP4EY=";

  # Adding npm (nodejs) and php composer to path
  postInstall = ''
    wrapProgram $out/bin/laravel \
      --suffix PATH : ${
        lib.makeBinPath [
          php.packages.composer
          nodejs
        ]
      }
  '';

  composerLock = ./composer.lock;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Laravel application installer";
    homepage = "https://laravel.com/docs#creating-a-laravel-project";
    changelog = "https://github.com/laravel/installer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ heisfer ];
    mainProgram = "laravel";
  };
})
