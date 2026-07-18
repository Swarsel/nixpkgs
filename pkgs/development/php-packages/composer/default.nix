{
  lib,
  fetchFromGitHub,
  _7zz,
  callPackage,
  curl,
  gitMinimal,
  makeBinaryWrapper,
  php,
  unzip,
  versionCheckHook,
  xz,
}:
php.buildComposerProject2 (finalAttrs: {
  pname = "composer";
  version = "2.10.2";

  src = fetchFromGitHub {
    owner = "composer";
    repo = "composer";
    tag = finalAttrs.version;
    hash = "sha256-LKC4ogBHArE1wceY5hClVC2H9J8Hx98hlaV8GZEdt8c=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  vendorHash = "sha256-0reKbGJEFJTQ2XnfsGij7nWICURLEHWJxjsYzanHpgs=";

  postInstall = ''
    wrapProgram $out/bin/composer \
      --prefix PATH : ${
        lib.makeBinPath [
          _7zz
          curl
          gitMinimal
          unzip
          xz
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  # Bootstrapping Composer (source) with Composer (PHAR distribution).
  # Override the default `composer` attribute to prevent infinite recursion.
  composer = callPackage ../../../build-support/php/pkgs/composer-phar.nix {
    inherit (finalAttrs) version;
    inherit (finalAttrs.passthru) pharHash;
  };

  # Hash used by ../../../build-support/php/pkgs/composer-phar.nix to
  # use together with the version from this package to keep the
  # bootstrap phar file up-to-date together with the end user composer
  # package.
  passthru.pharHash = "sha256-XucSX4owo00kbO/cC8hbing7KPKuyWiZQRhRI1DSgCc=";

  meta = {
    description = "Dependency Manager for PHP";
    homepage = "https://getcomposer.org/";
    changelog = "https://github.com/composer/composer/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "composer";
    teams = [ lib.teams.php ];
  };
})
