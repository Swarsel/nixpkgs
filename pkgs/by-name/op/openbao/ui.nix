{
  fetchPnpmDeps,
  # https://github.com/openbao/openbao/issues/731
  nodejs-slim_22,
  openbao,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
}:
let
  nodejs-slim = nodejs-slim_22;
  pnpm = pnpm_10.override { inherit nodejs-slim; };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (openbao) version src;
  pname = openbao.pname + "-ui";

  nativeBuildInputs = [
    pnpmConfigHook
    pnpmBuildHook
    pnpm
    nodejs-slim
  ];

  postConfigure = ''
    substituteInPlace .ember-cli \
      --replace-fail "../http/web_ui" "$out"
  '';

  dontInstall = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-9Q5celZSwMgSS8qcj8sDH/JLv48lgDMOylANvXSnhsU=";
  };

  sourceRoot = "${finalAttrs.src.name}/ui";

  meta = (builtins.removeAttrs openbao.meta [ "mainProgram" ]) // {
    description = openbao.meta.description + " - web UI";
  };
})
