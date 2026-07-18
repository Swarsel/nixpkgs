{
  lib,
  fetchurl,
  makeBinaryWrapper,
  php,
  stdenvNoCC,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "magento-cloud";
  version = "1.47.0";

  src = fetchurl {
    url = "https://accounts.magento.cloud/sites/default/files/magento-cloud-v${finalAttrs.version}.phar";
    hash = "sha256-/CzHWQa/O1gW4x+b0acR0Cj8AE8Olhpgn7YcaDrLk9E=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -D ${finalAttrs.src} $out/libexec/magento-cloud/magento-cloud.phar
    makeWrapper ${lib.getExe php} $out/bin/magento-cloud \
      --add-flags "$out/libexec/magento-cloud/magento-cloud.phar"

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  dontBuild = true;
  dontConfigure = true;
  dontUnpack = true;
  versionCheckKeepEnvironment = [ "HOME" ];

  passthru = {
    updateScript = ./update.sh;
  };

  meta = {
    description = "Adobe Commerce Cloud CLI";

    longDescription = ''
      Adobe Commerce Cloud CLI enables developers and system administrators the ability to manage Cloud projects and environments, perform routines and run automation tasks locally.
    '';

    homepage = "https://experienceleague.adobe.com/en/docs/commerce-cloud-service/user-guide/dev-tools/cloud-cli/cloud-cli-overview";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ piotrkwiecinski ];
    mainProgram = "magento-cloud";
  };
})
