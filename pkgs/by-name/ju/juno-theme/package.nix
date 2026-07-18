{
  lib,
  stdenv,
  fetchurl,
  gtk-engine-murrine,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "juno";
  version = "0.0.3";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cp -a Juno* $out/share/themes
    rm $out/share/themes/*/{LICENSE,README.md}
    runHook postInstall
  '';

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];
  sourceRoot = ".";

  srcs = [
    (fetchurl {
      sha256 = "sha256-G/H5FZ6VSLHwtMtttRafvPFE2sd30FHbep/0i4dGfl8=";
      url = "https://github.com/gvolpe/Juno/releases/download/${finalAttrs.version}/Juno.tar.xz";
    })
    (fetchurl {
      sha256 = "sha256-VU8uNH6T9FyOWgIfsGCCihnX3uHfOy6dXsANWKRPQ1c=";
      url = "https://github.com/gvolpe/Juno/releases/download/${finalAttrs.version}/Juno-mirage.tar.xz";
    })
    (fetchurl {
      sha256 = "sha256-OeMXR0nE9aUmwAGfOAfbNP2Rgvv1u/2vj3LKb88mD1s=";
      url = "https://github.com/gvolpe/Juno/releases/download/${finalAttrs.version}/Juno-ocean.tar.xz";
    })
    (fetchurl {
      sha256 = "sha256-DP3fKXYxUHpsw0msfPAZB3UtEa6CCOfqsabAmsmWq44=";
      url = "https://github.com/gvolpe/Juno/releases/download/${finalAttrs.version}/Juno-palenight.tar.xz";
    })
  ];

  meta = {
    description = "GTK themes inspired by epic vscode themes";
    homepage = "https://github.com/EliverLara/Juno";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.gvolpe ];
    platforms = lib.platforms.all;
  };
})
