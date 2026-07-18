{
  lib,
  stdenv,
  fetchurl,
  _7zz,
  appimageTools,
  undmg,
}:
let
  pname = "paperlib";
  version = "3.1.10";
  src =
    fetchurl
      {
        aarch64-darwin = {
          hash = "sha256-KNMPUeCNtODHzMJhCwI4SJPRfa87RmAe6CRRazgRZCQ=";
          url = "https://github.com/Future-Scholars/paperlib/releases/download/release-electron-${version}/Paperlib_${version}_arm.dmg";
        };

        x86_64-linux = {
          hash = "sha256-uBYhiUL4YWwnLLPvXMoXjlQqlqFep/OpwwnmPx7s5dY=";
          url = "https://github.com/Future-Scholars/paperlib/releases/download/release-electron-${version}/Paperlib_${version}.AppImage";
        };
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  passthru = {
    inherit pname version src;
  };

  meta = {
    description = "Open-source academic paper management tool";
    homepage = "https://github.com/Future-Scholars/paperlib";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ ByteSudoer ];

    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "paperlib";
  };
in
if stdenv.hostPlatform.isDarwin then
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      passthru
      ;

    nativeBuildInputs = if stdenv.hostPlatform.isAarch64 then [ _7zz ] else [ undmg ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      mv Paperlib.app $out/Applications/

      runHook postInstall
    '';

    sourceRoot = ".";
  }
else
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      meta
      passthru
      ;

    extraPkgs = pkgs: [ pkgs.libsecret ];
  }
