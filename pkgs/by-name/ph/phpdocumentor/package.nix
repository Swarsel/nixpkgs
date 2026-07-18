{
  lib,
  fetchFromGitHub,
  makeBinaryWrapper,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "phpdocumentor";
  version = "3.10.0";

  src = fetchFromGitHub {
    owner = "phpDocumentor";
    repo = "phpDocumentor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sieLh5CG0ev4wMco+VG9A+2GxxalN7/FLGz+IDEgH4g=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  vendorHash = "sha256-hz0Fw1gR2mPGdmVi4i7yjmAJiQTfkxDUC3D2ylNpdbU=";

  postInstall = ''
    wrapProgram "$out/bin/phpdoc" \
      --set-default APP_CACHE_DIR /tmp \
      --set-default APP_LOG_DIR /tmp/log
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "PHP documentation generator";
    homepage = "https://phpdoc.org";
    changelog = "https://github.com/phpDocumentor/phpDocumentor/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.patka ];
    mainProgram = "phpdoc";
  };
})
