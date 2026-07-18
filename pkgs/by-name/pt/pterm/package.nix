{
  lib,
  stdenv,
  fetchurl,
  SDL,
  libsndfile,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pterm";
  version = "6.0.4";

  src = fetchurl {
    url = "https://www.cyber1.org/download/linux/pterm-${finalAttrs.version}.tar.bz2";
    hash = "sha256-0OJvoCOGx/a51Ja7n3fOTeQJEcdyn/GhaJ0NtVCyuC8=";
  };

  patches = [ ./0001-dtnetsubs-remove-null-check.patch ];

  buildInputs = [
    libsndfile
    SDL
    wxwidgets_3_2
  ];

  env.PTERMVERSION = "${finalAttrs.version}";

  preBuild = ''
    substituteInPlace Makefile.common Makefile.wxpterm --replace "/bin/echo" "echo"
    echo "exit 0" > wxversion.py
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 "pterm" "$out/bin/pterm"

    runHook postInstall
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Terminal emulator for the Cyber1 mainframe-based CYBIS system";
    homepage = "https://www.cyber1.org/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ sarcasticadmin ];
    platforms = lib.platforms.unix;
    mainProgram = "pterm";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
