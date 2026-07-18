{
  lib,
  fetchzip,
  powershell,
  runtimeShell,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "powershell-editor-services";
  version = "4.7.0";

  src = fetchzip {
    url = "https://github.com/PowerShell/PowerShellEditorServices/releases/download/v${version}/PowerShellEditorServices.zip";
    hash = "sha256-dODDDR42VONL3nf5Pg08yfPWHMswCCsgiUMNGSlUz9o=";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/lib/powershell-editor-services/ $out/bin
    mv * $out/lib/powershell-editor-services/
    cat > $out/bin/powershell-editor-services <<EOF
    #! ${runtimeShell} -e
    exec ${lib.getExe' powershell "pwsh"} -noprofile -nologo -c "& '$out/lib/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1' \$@"
    EOF
    chmod +x $out/bin/powershell-editor-services
  '';

  meta = {
    description = "Common platform for PowerShell development support in any editor or application";
    homepage = "https://github.com/PowerShell/PowerShellEditorServices";
    changelog = "https://github.com/PowerShell/PowerShellEditorServices/releases/tag/v${version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ sharpchen ];
    platforms = lib.platforms.unix;
    mainProgram = "powershell-editor-services";
  };
}
