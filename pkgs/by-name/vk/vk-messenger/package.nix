{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  gtk3,
  libnotify,
  libxdamage,
  libxkbfile,
  libxscrnsaver,
  libxtst,
  nss,
  rpmextract,
  udev,
  undmg,
  wrapGAppsHook3,
}:

let
  pname = "vk-messenger";
  version = "5.3.2";

  src =
    {
      i686-linux = fetchurl {
        sha256 = "L0nE0zW4LP8udcE8uPy+cH9lLuQsUSq7cF13Gv7w2rI=";
        url = "https://desktop.userapi.com/rpm/master/vk-${version}.i686.rpm";
      };

      x86_64-linux = fetchurl {
        sha256 = "spDw9cfDSlIuCwOqREsqXC19tx62TiAz9fjIS9lYjSQ=";
        url = "https://desktop.userapi.com/rpm/master/vk-${version}.x86_64.rpm";
      };
    }
    .${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

  meta = {
    description = "Simple and Convenient Messaging App for VK";
    homepage = "https://vk.com/messenger";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };

  linux = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [
      rpmextract
      autoPatchelfHook
      wrapGAppsHook3
    ];

    buildInputs = [
      libxdamage
      libxtst
      libxscrnsaver
      libxkbfile
      gtk3
      nss
      alsa-lib
    ];

    buildPhase = ''
      substituteInPlace usr/share/applications/vk.desktop \
        --replace /usr/share/pixmaps/vk.png vk
    '';

    installPhase = ''
      mkdir $out
      cd usr
      cp -r --parents bin $out
      cp -r --parents share/vk $out
      cp -r --parents share/applications $out
      cp -r --parents share/pixmaps $out
    '';

    runtimeDependencies = [
      (lib.getLib udev)
      libnotify
    ];

    unpackPhase = ''
      rpmextract $src
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ undmg ];

    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
    '';

    sourceRoot = ".";
  };
in
if stdenv.hostPlatform.isDarwin then darwin else linux
