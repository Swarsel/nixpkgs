{
  lib,
  autoPatchelfHook,
  fetchzip,
  glib,
  libxcb,
  nspr,
  nss,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "msedgedriver";
  version = "150.0.4078.65";

  src = fetchzip {
    url = "https://msedgedriver.microsoft.com/${finalAttrs.version}/edgedriver_linux64.zip";
    hash = "sha256-TwGjt8Hw4rvwW2OwkIcqRzKLXu1dRL7/9n+Zq3VmKag=";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    glib
    libxcb
    nspr
    nss
  ];

  installPhase =
    if stdenvNoCC.hostPlatform.isDarwin then
      ''
        runHook preInstall

        mkdir -p $out/{Applications/msedgedriver,bin}
        cp -R . $out/Applications/msedgedriver

        runHook postInstall
      ''
    else
      ''
        runHook preInstall

        install -m777 -D "msedgedriver" $out/bin/msedgedriver

        runHook postInstall
      '';

  meta = {
    description = "WebDriver implementation that controls an Edge browser running on the local machine";
    homepage = "https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ cholli ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "msedgedriver";
  };
})
