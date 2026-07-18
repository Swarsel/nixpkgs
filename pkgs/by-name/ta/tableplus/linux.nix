{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  gtk3,
  gtksourceview3,
  krb5,
  libgee,
  libsecret,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tableplus";
  version = "0.1.296";

  src = fetchurl {
    url = "https://web.archive.org/web/20251230232124/https://deb.tableplus.com/debian/22/pool/main/t/tableplus/tableplus_${finalAttrs.version}_amd64.deb";
    hash = "sha256-BJ+S2cBRZtehDU5DOzNEVGzhMoF4jvsNSwntoa5bnlc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtksourceview3
    krb5
    libgee
    libsecret
    libxkbcommon
    libx11
    libxcursor
    libxext
    libxi
    libxrandr
    libxrender
    libxcb
  ];

  installPhase = ''
    runHook preInstall

    substituteInPlace opt/tableplus/tableplus.desktop \
      --replace-fail "Exec=/usr/local/bin/tableplus" "Exec=tableplus" \
      --replace-fail "Icon=/opt/tableplus/resource/image/logo.png" "Icon=tableplus"
    install -Dt $out/bin opt/tableplus/tableplus
    install -Dt $out/share/applications/ opt/tableplus/tableplus.desktop
    install -Dt $out/share/icons/hicolor/256x256/apps/ opt/tableplus/resource/image/tableplus.png

    runHook postInstall
  '';

  unpackPhase = ''
    dpkg-deb -x $src .
  '';

  meta = {
    description = "Database management made easy";
    homepage = "https://tableplus.com";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ rhydianjenkins ];
    platforms = lib.platforms.linux;
    mainProgram = "tableplus";
  };
})
