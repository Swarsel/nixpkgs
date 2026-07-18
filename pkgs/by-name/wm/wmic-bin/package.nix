{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  libxcrypt-legacy,
  popt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wmic-bin";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "R-Vision";
    repo = "wmi-client";
    rev = finalAttrs.version;
    sha256 = "1w1mdbiwz37wzry1q38h8dyjaa6iggmsb9wcyhhlawwm1vj50w48";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    popt
    libxcrypt-legacy
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/wmic_ubuntu_x64 $out/bin/wmic
    install -Dm644 -t $out/share/doc/wmic LICENSE README.md

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/wmic --help >/dev/null

    runHook postInstallCheck
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "WMI client for Linux (binary)";
    homepage = "https://www.openvas.org";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "wmic";
  };
})
