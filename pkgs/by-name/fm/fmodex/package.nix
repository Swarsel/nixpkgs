{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  libpulseaudio,
  undmg,
}:

let
  bits = lib.optionalString (stdenv.hostPlatform.system == "x86_64-linux") "64";
  libPath = lib.makeLibraryPath [
    stdenv.cc.cc
    alsa-lib
    libpulseaudio
  ];

in
stdenv.mkDerivation rec {
  pname = "fmod";
  version = "4.44.64";

  src = fetchurl (
    if stdenv.hostPlatform.isLinux then
      {
        url = "https://zdoom.org/files/fmod/fmodapi${shortVersion}linux.tar.gz";
        sha256 = "047hk92xapwwqj281f4zwl0ih821rrliya70gfj82sdfjh9lz8i1";
      }
    else
      {
        url = "https://zdoom.org/files/fmod/fmodapi${shortVersion}mac-installer.dmg";
        sha256 = "1m1y4cpcwpkl8x31d3s68xzp107f343ma09w2437i2adn5y7m8ii";
      }
  );

  nativeBuildInputs = [ undmg ];

  installPhase =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      install -Dm755 api/lib/libfmodex${bits}-${version}.so $out/lib/libfmodex-${version}.so
      ln -s libfmodex-${version}.so $out/lib/libfmodex.so
      patchelf --set-rpath ${libPath} $out/lib/libfmodex.so
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      install -D api/lib/libfmodex.dylib $out/lib/libfmodex.dylib
      install -D api/lib/libfmodexL.dylib $out/lib/libfmodexL.dylib
    ''
    + ''
      cp -r api/inc $out/include
    '';

  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;
  shortVersion = builtins.replaceStrings [ "." ] [ "" ] version;

  meta = {
    description = "Programming library and toolkit for the creation and playback of interactive audio";
    homepage = "http://www.fmod.org/";
    license = lib.licenses.unfreeRedistributable;
    maintainers = [ lib.maintainers.lassulus ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
