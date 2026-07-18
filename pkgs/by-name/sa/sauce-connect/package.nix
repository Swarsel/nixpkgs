{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
  unzip,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "sauce-connect";
  version = "5.3.0";

  src =
    passthru.sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    unzip
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 sc $out/bin/sc
    installShellCompletion --bash --name sc.bash completions/sc.bash
    installShellCompletion --fish --name sc.fish completions/sc.fish
    installShellCompletion --zsh --name _sc completions/sc.zsh
    install -Dm644 LICENSE $out/share/licenses/sauce-connect/LICENSE
    install -Dm644 LICENSE.3RD_PARTY $out/share/licenses/sauce-connect/LICENSE.3RD_PARTY
    install -Dm644 sauce-connect.yaml $out/etc/sauce-connect.yaml

    runHook postInstall
  '';

  dontStrip = true;
  sourceRoot = "source";

  unpackPhase = ''
    runHook preUnpack

    mkdir source
    ${lib.optionalString stdenv.hostPlatform.isLinux "tar -zxvf $src -C source"}
    ${lib.optionalString stdenv.hostPlatform.isDarwin "unzip $src -d source"}

    runHook postUnpack
  '';

  passthru = {
    sources = {
      aarch64-darwin = fetchurl {
        hash = "sha256-nSmDenuel+L4HKhDEHMirGwKj0A7plIXAqf+T7Agc3A=";
        url = "https://saucelabs.com/downloads/sauce-connect/${version}/sauce-connect-${version}_darwin.all.zip";
      };

      aarch64-linux = fetchurl {
        hash = "sha256-3fUB0KLFEmSzRlYSZhJ3VP4QJC/S1R2Iyk3+o82sNRg=";
        url = "https://saucelabs.com/downloads/sauce-connect/${version}/sauce-connect-${version}_linux.aarch64.tar.gz";
      };

      x86_64-linux = fetchurl {
        hash = "sha256-7DeGVdRtbgwpDpt7txuYLmf7R6KYeneMOGPH0B1PTIQ=";
        url = "https://saucelabs.com/downloads/sauce-connect/${version}/sauce-connect-${version}_linux.x86_64.tar.gz";
      };
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Secure tunneling app for executing tests securely when testing behind firewalls";
    homepage = "https://docs.saucelabs.com/reference/sauce-connect/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = builtins.attrNames passthru.sources;
  };
}
