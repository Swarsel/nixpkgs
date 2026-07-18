{
  lib,
  stdenv,
  fetchurl,
  jre,
}:

stdenv.mkDerivation rec {
  inherit jre;
  pname = "subsonic";
  version = "6.1.6";

  src = fetchurl {
    url = "mirror://sourceforge/subsonic/subsonic-${version}-standalone.tar.gz";
    sha256 = "180qdk8mnc147az8v9rmc1kgf8b13mmq88l195gjdwiqpflqzdyz";
  };

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r ${pname}-${version}/* $out
    runHook postInstall
  '';

  # Create temporary directory to extract tarball into to satisfy Nix's need
  # for a directory to be created in the unpack phase.
  unpackPhase = ''
    runHook preUnpack
    mkdir ${pname}-${version}
    tar -C ${pname}-${version} -xzf $src
    runHook postUnpack
  '';

  meta = {
    description = "Personal media streamer";
    homepage = "http://subsonic.org";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ telotortium ];
    platforms = lib.platforms.unix;
  };
}
