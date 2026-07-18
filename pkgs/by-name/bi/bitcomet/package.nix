{
  lib,
  fetchurl,
  appimageTools,
  buildFHSEnv,
  desktop-file-utils,
  dpkg,
  nix-update,
  stdenvNoCC,
  writeShellScript,
  runScript ? "bitcometd",
}:

let
  pname = "bitcomet";
  version = "2.21.2";

  meta = {
    description = "BitTorrent download client";
    homepage = "https://www.bitcomet.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];

    mainProgram = "bitcometd";
  };

  bitcomet = stdenvNoCC.mkDerivation {
    inherit pname version meta;

    src =
      let
        selectSystem =
          attrs:
          attrs.${stdenvNoCC.hostPlatform.system}
            or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
        arch = selectSystem {
          aarch64-linux = "arm64";
          x86_64-linux = "x86_64";
        };
      in
      fetchurl {
        url = "https://download.bitcomet.com/linux/${arch}/BitComet-${version}-${arch}.deb";

        hash = selectSystem {
          aarch64-linux = "sha256-VC/dvAGmhqlmZT5XB41x/fTGvMZjYCuz/tSp9MYFUHo=";
          x86_64-linux = "sha256-qHPr4G921W1Pl7n0Wv98yLRbsAkJBrOcyg9kHHjtBGc=";
        };
      };

    nativeBuildInputs = [
      dpkg
      desktop-file-utils
    ];

    installPhase = ''
      runHook preInstall

      desktop-file-edit usr/share/applications/bitcomet.desktop \
        --remove-key="Version" \
        --remove-key="Comment" \
        --set-key="Exec" --set-value="BitComet" \
        --set-icon="bitcomet"
      cp -r usr $out

      runHook postInstall
    '';
  };
in
buildFHSEnv {
  inherit pname version meta;
  executableName = "bitcometd";
  multiPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;
  runScript = "bitcometd";
  targetPkgs = pkgs: [ bitcomet ] ++ appimageTools.defaultFhsEnvArgs.targetPkgs pkgs;

  passthru = {
    inherit bitcomet;

    updateScript = writeShellScript "update-bitcomet" ''
      latestVersion=$(curl --fail --silent https://www.cometbbs.com/t/linux%E5%86%85%E6%B5%8B%E7%89%88/88604 | grep -oP 'BitComet-\K[0-9]+\.[0-9]+\.[0-9]+(?=-x86_64\.deb)' | head -n1)
      ${lib.getExe nix-update} pkgsCross.gnu64.bitcomet.bitcomet --version $latestVersion
      ${lib.getExe nix-update} pkgsCross.aarch64-multiplatform.bitcomet.bitcomet --version skip
    '';
  };
}
