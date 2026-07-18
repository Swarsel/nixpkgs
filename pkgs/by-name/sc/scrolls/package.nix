{
  lib,
  stdenv,
  fetchurl,
  gcc,
  libGLU,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
}:
stdenv.mkDerivation {
  pname = "scrolls";
  version = "2015-10-13";

  src = fetchurl {
    url = "https://download.scrolls.com/client/linux.tar.gz";
    sha256 = "ead1fd14988aa07041fedfa7f845c756cd5077a5a402d85bfb749cb669ececec";
  };

  installPhase = ''
    mkdir -p "$out/opt/Scrolls"
    cp -r ../Scrolls "$out/opt/Scrolls/"
    cp -r ../Scrolls_Data "$out/opt/Scrolls/"
    chmod +x "$out/opt/Scrolls/Scrolls"

    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$libPath" "$out/opt/Scrolls/Scrolls"

    mkdir "$out/bin"
    ln -s "$out/opt/Scrolls/Scrolls" "$out/bin/Scrolls"
  '';

  libPath = lib.makeLibraryPath [
    gcc
    libGLU
    libx11
    libxext
    libxcursor
    libpulseaudio
  ];

  meta = {
    description = "Strategy collectible card game";
    homepage = "https://scrolls.com/";
    license = lib.licenses.unfree;
    # http://www.reddit.com/r/Scrolls/comments/2j3pxw/linux_client_experimental/
    platforms = [ "x86_64-linux" ];
  };

}
