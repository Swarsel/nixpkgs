{
  lib,
  stdenv,
  fetchurl,
  cmake,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "angelscript";
  version = "2.38.0";

  src = fetchurl {
    url = "https://www.angelcode.com/angelscript/sdk/files/angelscript_${finalAttrs.version}.zip";
    sha256 = "sha256-sztdvNoQMX72fWKDU9gyRphM5vysEC1Nwq7RIeulLm8=";
  };

  nativeBuildInputs = [
    unzip
    cmake
  ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" ];

  preConfigure = ''
    export ROOT=$PWD
    cd angelscript/projects/cmake
  '';

  postInstall = ''
    mkdir -p "$out/share/docs/angelscript"
    cp -r $ROOT/docs/* "$out/share/docs/angelscript"
  '';

  meta = {
    description = "Light-weight scripting library";
    homepage = "https://www.angelcode.com/angelscript/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.all;
    downloadPage = "https://www.angelcode.com/angelscript/downloads.html";
  };
})
