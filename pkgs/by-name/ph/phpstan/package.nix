{
  lib,
  stdenv,
  fetchFromGitHub,
  makeBinaryWrapper,
  php,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "phpstan";
  version = "2.2.5";

  src = fetchFromGitHub {
    owner = "phpstan";
    repo = "phpstan";
    tag = finalAttrs.version;
    hash = "sha256-9x7bB1Zk1sKRYXzaWzibRps6m3ifssXVPac10ks2HAw=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  postInstall = ''
    install -D ./phpstan.phar $out/libexec/phpstan/phpstan.phar
    makeWrapper ${lib.getExe php} $out/bin/phpstan \
      --add-flags "$out/libexec/phpstan/phpstan.phar" \
      --prefix PATH : ${
        lib.makeBinPath [
          php
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "PHP Static Analysis Tool";

    longDescription = ''
      PHPStan focuses on finding errors in your code without actually
      running it. It catches whole classes of bugs even before you write
      tests for the code. It moves PHP closer to compiled languages in the
      sense that the correctness of each line of the code can be checked
      before you run the actual line.
    '';

    homepage = "https://github.com/phpstan/phpstan";
    changelog = "https://github.com/phpstan/phpstan/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      patka
      piotrkwiecinski
    ];

    mainProgram = "phpstan";
  };
})
