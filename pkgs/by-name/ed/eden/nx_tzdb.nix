{
  lib,
  stdenv,
  cmake,
  fetchFromGitea,
  ninja,
  tzdata,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tzdb_to_nx";
  version = "230326";

  src = fetchFromGitea {
    owner = "eden-emu";
    repo = "tzdb_to_nx";
    tag = finalAttrs.version;
    hash = "sha256-koz7C63oHVfrhrf9lfdUqw6idJWi21XRKQnb5PdoEb4=";
    domain = "git.eden-emu.dev";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    (lib.cmakeFeature "TZDB2NX_ZONEINFO_DIR" "${tzdata}/share/zoneinfo")
    (lib.cmakeFeature "TZDB2NX_VERSION" tzdata.version)
  ];

  installPhase = ''
    runHook preInstall

    cp -r src/tzdb/nx $out

    runHook postInstall
  '';

  ninjaFlags = [ "x80e" ];

  meta = {
    description = "RFC 8536 time zone data converted to the Nintendo Switch format";
    homepage = "https://git.crueter.xyz/misc/tzdb_to_nx";

    license = with lib.licenses; [
      # Converter
      mit

      # Data
      publicDomain
    ];

    maintainers = with lib.maintainers; [ marcin-serwin ];
    platforms = lib.platforms.all;
  };
})
