{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  file,
  jansson,
  openssl,
  pkg-config,
  protobufc,
  enableCuckoo ? true,
  enableDex ? true,
  enableDotNet ? true,
  enableMacho ? true,
  enableMagic ? true,
  enableStatic ? false,
  withCrypto ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yara";
  version = "4.5.6";

  src = fetchFromGitHub {
    owner = "VirusTotal";
    repo = "yara";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vzYH56BC0Stb2I4U5VzxA0xG46xZkWmbTIC6BtzeNQ8=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    protobufc
  ]
  ++ lib.optionals withCrypto [ openssl ]
  ++ lib.optionals enableMagic [ file ]
  ++ lib.optionals enableCuckoo [ jansson ];

  configureFlags = [
    (lib.withFeature withCrypto "crypto")
    (lib.enableFeature enableCuckoo "cuckoo")
    (lib.enableFeature enableDex "dex")
    (lib.enableFeature enableDotNet "dotnet")
    (lib.enableFeature enableMacho "macho")
    (lib.enableFeature enableMagic "magic")
    (lib.enableFeature enableStatic "static")
  ];

  preConfigure = "./bootstrap.sh";
  doCheck = enableStatic;

  # bin/yara contain forbidden references to /build/.
  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" $out/bin/yara
  '';

  meta = {
    description = "Tool to perform pattern matching for malware-related tasks";
    homepage = "http://Virustotal.github.io/yara/";
    changelog = "https://github.com/VirusTotal/yara/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.all;
    mainProgram = "yara";
  };
})
