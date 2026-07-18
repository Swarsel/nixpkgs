{
  lib,
  stdenv,
  fetchurl,
  curl,
  dotnet-runtime,
  icu,
  libmediainfo,
  makeWrapper,
  mono,
  nixosTests,
  openssl,
  sqlite,
  zlib,
}:

let
  os = if stdenv.hostPlatform.isDarwin then "osx" else "linux";
  system = stdenv.hostPlatform.system;
  arch =
    {
      aarch64-darwin = "arm64";
      aarch64-linux = "arm64";
      x86_64-linux = "x64";
    }
    ."${system}" or (throw "Unsupported system: ${system}");
  hash =
    {
      arm64-linux-hash = "sha256-hFZ27VAIBDW8c7oP+Nl0rj6T2CRbee8Qxf4CzZJmCL8=";
      arm64-osx-hash = "sha256-oFqnQnbBGAD4x97FANbY091nJrzHRMewalASwgOul8s=";
      x64-linux-hash = "sha256-ZRgCJf2GGV1B+QgmYh4OfX7nMfRBdN6pIg5pU6Q/KCQ=";
      x64-osx-hash = "sha256-H5qLdiL4hEkg5g50zzrv1HdZMc6ji69O5GUrpHWkrdo=";
    }
    ."${arch}-${os}-hash";
in
stdenv.mkDerivation rec {
  pname = "whisparr";
  version = "2.0.0.2151";

  src = fetchurl {
    inherit hash;
    url = "https://whisparr.servarr.com/v1/update/nightly/updatefile?runtime=netcore&version=${version}&arch=${arch}&os=${os}";
    name = "${pname}-${arch}-${os}-${version}.tar.gz";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    rm -rf "Whisparr.Update"

    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}/

    makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/Whisparr \
      --add-flags "$out/share/${pname}-${version}/Whisparr.dll" \
      --prefix LD_LIBRARY_PATH : ${runtimeLibs}

    runHook postInstall
  '';

  runtimeLibs = lib.makeLibraryPath [
    curl
    icu
    libmediainfo
    mono
    openssl
    sqlite
    zlib
  ];

  passthru = {
    tests.smoke-test = nixosTests.whisparr;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Adult movie collection manager for Usenet and BitTorrent users";
    homepage = "https://wiki.servarr.com/en/whisparr";
    changelog = "https://whisparr.servarr.com/v1/update/nightly/changes";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "Whisparr";
  };
}
