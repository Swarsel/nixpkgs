{
  stdenv,
  addonDir,
  toKodiAddon,
}:
{
  namespace,
  name ? "${attrs.pname}-${attrs.version}",
  sourceDir ? "",
  ...
}@attrs:
toKodiAddon (
  stdenv.mkDerivation (
    {
      installPhase = ''
        runHook preInstall

        cd ./$sourceDir
        d=$out${addonDir}/${namespace}
        mkdir -p $d
        sauce="."
        [ -d ${namespace} ] && sauce=${namespace}
        cp -R "$sauce/"* $d

        runHook postInstall
      '';

      dontStrip = true;
      extraRuntimeDependencies = [ ];
      name = "kodi-" + name;
    }
    // attrs
  )
)
