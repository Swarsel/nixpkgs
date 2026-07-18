{
  fetchurl,
  hash,
  pname,
  stdenvNoCC,
  undmg,
  version,
  metaCommon ? { },
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchurl {
    inherit hash;
    url = "https://download.mikrotik.com/routeros/winbox/${finalAttrs.version}/WinBox.dmg";
    name = "WinBox-${finalAttrs.version}.dmg";
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,Applications}
    cp -R "WinBox.app" "$out/Applications/WinBox.app"
    ln -s "$out/Applications/WinBox.app/Contents/MacOS/WinBox" "$out/bin/WinBox"

    runHook postInstall
  '';

  sourceRoot = ".";

  meta = metaCommon // {
    platforms = [ "aarch64-darwin" ];
  };
})
