{
  lib,
  bash,
  coreutils,
  gnused,
  goss,
  resholve,
  which,
}:

resholve.mkDerivation (finalAttrs: {
  pname = "dgoss";
  version = goss.version;
  src = goss.src;

  installPhase = ''
    sed -i '2i GOSS_PATH=\$\{GOSS_PATH:-${goss}/bin/goss\}' extras/dgoss/dgoss
    install -D extras/dgoss/dgoss $out/bin/dgoss
  '';

  dontBuild = true;
  dontConfigure = true;

  solutions = {
    default = {
      inputs = [
        coreutils
        gnused
        which
      ];

      interpreter = "${bash}/bin/bash";

      keep = {
        "$CONTAINER_RUNTIME" = true;
      };

      scripts = [ "bin/dgoss" ];
    };
  };

  meta = {
    description = "Convenience wrapper around goss that aims to bring the simplicity of goss to docker containers";
    homepage = "https://github.com/goss-org/goss/blob/v${finalAttrs.version}/extras/dgoss/README.md";
    changelog = "https://github.com/goss-org/goss/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      hyzual
      anthonyroussel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "dgoss";
  };
})
