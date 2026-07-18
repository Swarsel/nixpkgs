{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  bluez,
  libx11,
  libxtst,
  makeWrapper,
  versionCheckHook,
}:
stdenv.mkDerivation (
  finalAttrs:
  let
    sources = {
      "aarch64-linux" = {
        hash = "sha256-GmYekCGb64GdFdABEJl9CgqycnsBX95W9/b0xZJntEs=";
        url = "https://www.unifiedremote.com/static/builds/server/linux-arm64/${builtins.elemAt (builtins.splitVersion finalAttrs.version) 3}/urserver-${finalAttrs.version}.tar.gz";
      };

      "x86_64-linux" = {
        hash = "sha256-4wA2VPb5QN30TWa72pUVTYfvsxlGTO8Vngh7wDHXhDE=";
        url = "https://www.unifiedremote.com/static/builds/server/linux-x64/${builtins.elemAt (builtins.splitVersion finalAttrs.version) 3}/urserver-${finalAttrs.version}.tar.gz";
      };
    };
  in

  {
    pname = "urserver";
    version = "3.14.0.2574";

    src =
      let
        platformSource =
          sources."${stdenv.hostPlatform.system}"
            or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      in
      fetchurl {
        inherit (platformSource) url hash;
      };

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = [ (lib.getLib stdenv.cc.cc) ];

    installPhase = ''
      install -m755 -D urserver $out/bin/urserver
      wrapProgram $out/bin/urserver --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libx11
          libxtst
          bluez
        ]
      }"
      cp -r remotes $out/bin/remotes
      cp -r manager $out/bin/manager
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [ versionCheckHook ];

    meta = {
      description = "One-and-only remote for your computer";
      homepage = "https://www.unifiedremote.com/";
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
      maintainers = with lib.maintainers; [ sfrijters ];
      platforms = lib.attrNames sources;
      mainProgram = "urserver";
    };
  }
)
