{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  stdenvNoCC,
  vsce,
  vscode-utils,
}:

let
  vsix = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "vscode-icons-vsix";
    version = "12.15.0";

    src = fetchFromGitHub {
      owner = "vscode-icons";
      repo = "vscode-icons";
      tag = "v${finalAttrs.version}";
      hash = "sha256-HYMXcmK2cW01PsjwMr+SGq94oFWEXvdny6IFnXMBdKA=";
    };

    nativeBuildInputs = [
      nodejs
      npmHooks.npmConfigHook
      vsce
    ];

    env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "true";

    buildPhase = ''
      runHook preBuild
      vsce package
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp ./vscode-icons-$version.vsix $out
      runHook postInstall
    '';

    name = "vscode-icons-${finalAttrs.version}.vsix";

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src;
      hash = "sha256-3Jt9JKbu5QxZynbkgQX/So3PWeJDdxIU5TVM4nfvgcQ=";
      name = "${finalAttrs.pname}-npm-deps";
    };
  });
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit (finalAttrs.src) version;
  pname = "vscode-icons";
  src = vsix;
  vscodeExtName = "vscode-icons";
  vscodeExtPublisher = "vscode-icons-team";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  passthru = {
    updateScript = nix-update-script {
      attrPath = "vscode-extensions.kilocode.kilo-kode.vsix";
    };

    vsix = finalAttrs.src;
  };

  meta = {
    description = "Bring real icons to your Visual Studio Code";
    homepage = "https://github.com/vscode-icons/vscode-icons";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      bastaynav
      xiaoxiangmoe
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=vscode-icons-team.vscode-icons";
  };
})
