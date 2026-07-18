{
  lib,
  autoPatchelfHook,
  fetchzip,
  icu,
  stdenvNoCC,
}:

let
  pname = "everest";
  version = "6314";
  phome = "$out/lib/Celeste";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchzip {
    url = "https://github.com/EverestAPI/Everest/releases/download/stable-1.6314.0/main.zip";
    hash = "sha256-YM6zjANINWQlTNu3EJFKIVl9VhVY4Ednjp+I+6Ap7dI=";
    extension = "zip";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    icu
  ];

  postInstall = ''
    mkdir -p ${phome}
    cp -r * ${phome}
  '';

  postFixup = ''
    autoPatchelf ${phome}/MiniInstaller-linux
  '';

  dontAutoPatchelf = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  dontStrip = true;

  meta = {
    description = "Celeste mod loader (don't install; use celestegame instead)";
    homepage = "https://everestapi.github.io";
    license = with lib.licenses; [ mit ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = [ "x86_64-linux" ];
  };

}
