{
  lib,
  gemini-cli,
  vsce,
  vscode-utils,
}:
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit (gemini-cli) version;
  pname = "gemini-cli-vscode-ide-companion";

  src = gemini-cli.overrideAttrs (oldAttrs: {
    installPhase = ''
      runHook preInstall

      patchShebangs .

      npm --workspace=gemini-cli-vscode-ide-companion run prepackage

      # the bundled vsce is broken, using our packaged version
      pushd packages/vscode-ide-companion
      ${vsce}/bin/vsce package --no-dependencies --out $out
      popd

      runHook postInstall
    '';

    name = "${finalAttrs.pname}-${finalAttrs.version}.vsix";
    pname = "gemini-cli-vscode-ide-companion-vsix";
  });

  vscodeExtName = "gemini-cli-vscode-ide-companion";
  vscodeExtPublisher = "Google";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  meta = {
    description = "Enable Gemini CLI with direct access to your IDE workspace";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=Google.gemini-cli-vscode-ide-companion";
  };
})
