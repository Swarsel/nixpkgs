{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ttf-envy-code-r";
  version = "PR7";

  src = fetchzip {
    url = "https://download.damieng.com/fonts/original/EnvyCodeR-${version}.zip";
    hash = "sha256-pJqC/sbNjxEwbVf2CVoXMBI5zvT3DqzRlKSqFT8I2sM=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype
    install -Dm644 *.txt -t $out/share/doc/${pname}

    runHook postInstall
  '';

  meta = {
    description = "Free scalable coding font by DamienG";
    homepage = "https://damieng.com/blog/tag/envy-code-r";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
