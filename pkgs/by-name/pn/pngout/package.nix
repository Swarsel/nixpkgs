{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  platforms = {
    aarch64-darwin = {
      folder = ".";
    };

    aarch64-linux = {
      folder = "aarch64";
      ld-linux = "ld-linux-aarch64.so.1";
    };

    armv7l-linux = {
      folder = "armv7";
      ld-linux = "ld-linux-armhf.so.3";
    };

    i686-linux = {
      folder = "i686";
      ld-linux = "ld-linux.so.2";
    };

    x86_64-linux = {
      folder = "amd64";
      ld-linux = "ld-linux-x86-64.so.2";
    };
  };
  platform =
    platforms."${stdenv.hostPlatform.system}"
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  download =
    if stdenv.hostPlatform.isDarwin then
      {
        hash = "sha256-Lj63k0UgYECuOg0NDs/prQHZL+UAK4oWdqZWMqVoQOE=";
        suffix = "20230322-mac.zip";
      }
    else
      {
        hash = "sha256-rDi7pvDeKQM96GZTjDr6ZDQTGbaVu+OI77xf2egw6Sg=";
        suffix = "20200115-linux.tar.gz";
      };
in
stdenv.mkDerivation {
  pname = "pngout";
  version = "20230322";

  src = fetchurl {
    inherit (download) hash;
    url = "https://www.jonof.id.au/files/kenutils/pngout-${download.suffix}";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ unzip ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${platform.folder}/pngout $out/bin
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/${platform.ld-linux} $out/bin/pngout
  '';

  # pngout is code-signed on Darwin, so don’t alter the binary to avoid breaking the signature.
  dontFixup = stdenv.hostPlatform.isDarwin;

  meta = {
    description = "Tool that aggressively optimizes the sizes of PNG images";
    homepage = "http://advsys.net/ken/utils.htm";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.attrNames platforms;
    mainProgram = "pngout";
  };
}
