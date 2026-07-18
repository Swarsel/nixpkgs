{
  lib,
  stdenv,
  fetchurl,
  curl,
  dotnet-runtime,
  icu,
  libmediainfo,
  makeWrapper,
  nixosTests,
  openssl,
  sqlite,
  zlib,
}:

let
  os = if stdenv.hostPlatform.isDarwin then "osx" else "linux";
  arch =
    {
      aarch64-linux = "arm64";
      x86_64-linux = "x64";
    }
    ."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  hash =
    {
      arm64-linux_hash = "sha256-7NpH32tkEOYVyfwIBq9LCKAo0IQ1IehYfKi+qiBzf8o=";
      x64-linux_hash = "sha256-hCqxH6xPLhA+V7reqsHi1EY2sU3HJ6ESMJiiWXrcUUE=";
      x64-osx_hash = "sha256-ypzOWXxtzvOTgTmU7pQ1cS+FcyNCOo5R2Z4l5Mk+4wA=";
    }
    ."${arch}-${os}_hash";
in
stdenv.mkDerivation rec {
  pname = "readarr";
  version = "0.4.18.2805";

  src = fetchurl {
    url = "https://github.com/Readarr/Readarr/releases/download/v${version}/Readarr.develop.${version}.${os}-core-${arch}.tar.gz";
    sha256 = hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}/.
    makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/Readarr \
      --add-flags "$out/share/${pname}-${version}/Readarr.dll" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          curl
          sqlite
          libmediainfo
          icu
          openssl
          zlib
        ]
      }

    runHook postInstall
  '';

  passthru = {
    tests.smoke-test = nixosTests.readarr;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Usenet/BitTorrent ebook downloader";
    homepage = "https://readarr.com";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      jocelynthode
      devusb
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "Readarr";
  };
}
