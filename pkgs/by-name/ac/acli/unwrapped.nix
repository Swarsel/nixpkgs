{
  lib,
  fetchurl,
  common-updater-scripts,
  curl,
  gnugrep,
  installShellFiles,
  meta,
  src,
  stdenvNoCC,
  updateScript,
  version,
  versionCheckHook,
  writeShellApplication,
  pname ? "acli-unwrapped",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit
    pname
    src
    version
    meta
    ;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    install -Dm755 acli $out/bin/acli
  ''
  + lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd acli \
      --bash <($out/bin/acli completion bash) \
      --fish <($out/bin/acli completion fish) \
      --zsh <($out/bin/acli completion zsh)

    mkdir -p $out/share/powershell
    $out/bin/acli completion powershell > $out/share/powershell/acli.Completion.ps1
  ''
  + ''
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontBuild = true;
  versionCheckProgramArg = "-v";

  passthru = {
    inherit updateScript;
  };

})
