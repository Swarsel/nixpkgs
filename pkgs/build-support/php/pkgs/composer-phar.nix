{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  curl,
  git,
  installShellFiles,
  makeBinaryWrapper,
  pharHash,
  php,
  stdenvNoCC,
  unzip,
  version,
  xz,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "composer-phar";

  src = fetchurl {
    url = "https://github.com/composer/composer/releases/download/${finalAttrs.version}/composer.phar";
    hash = pharHash;
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D $src $out/libexec/composer/composer.phar
    makeWrapper ${lib.getExe php} $out/bin/composer \
      --add-flags "$out/libexec/composer/composer.phar" \
      --prefix PATH : ${
        lib.makeBinPath [
          _7zz
          curl
          git
          unzip
          xz
        ]
      }

    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd composer \
      --bash <($out/bin/composer completion bash)
  '';

  dontUnpack = true;

  meta = {
    description = "Dependency Manager for PHP, shipped from the PHAR file";
    homepage = "https://getcomposer.org/";
    changelog = "https://github.com/composer/composer/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.patka ];
    platforms = lib.platforms.all;
    mainProgram = "composer";
    teams = [ lib.teams.php ];
  };
})
