{
  lib,
  stdenv,
  fetchurl,
  anki,
  appimageTools,
  buildFHSEnv,
  cacert,
  undmg,
  writeShellScript,
  zstd,
  commandLineArgs ? [ ],
}:

let
  pname = "anki-bin";
  # Update hashes for both Linux and Darwin!
  version = "26.05";

  sources = {
    darwin-aarch64 = fetchurl {
      hash = "sha256-c5NZf0uWNB7XQDYBDtgrtCU+A5Cuck0rJ1xFG8hY0Sc=";
      url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-mac-apple.dmg";
    };

    # For some reason anki distributes completely separate dmg-files for the aarch64 version and the x86_64 version
    darwin-x86_64 = fetchurl {
      hash = "sha256-L/TXKh0cmTop7/ROA9YC4dyBz9iAFRhpXuNRbR3wwYk=";
      url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-mac-intel.dmg";
    };

    linux-aarch64 = fetchurl {
      hash = "sha256-z/w7+TKLW+xi/iJMXGOp50Yjwnv7FD5O0lNsu31dfqo=";
      url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-linux-aarch64.tar.zst";
    };

    linux-x86_64 = fetchurl {
      hash = "sha256-YiPXBVY/catAzgcqXZajkZxUbV3eHkxJ3CeXXnAGcnQ=";
      url = "https://github.com/ankitects/anki/releases/download/${version}/anki-${version}-linux-x86_64.tar.zst";
    };
  };

  unpacked = stdenv.mkDerivation {
    inherit pname version;
    src = if stdenv.hostPlatform.isAarch64 then sources.linux-aarch64 else sources.linux-x86_64;
    nativeBuildInputs = [ zstd ];

    installPhase = ''
      runHook preInstall

      xdg-mime () {
        echo Stubbed!
      }
      export -f xdg-mime

      PREFIX=$out bash install.sh

      runHook postInstall
    '';
  };

  meta = {
    inherit (anki.meta)
      license
      homepage
      description
      mainProgram
      longDescription
      ;

    maintainers = with lib.maintainers; [
      mahmoudk1000
      cything
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };

  passthru = {
    inherit sources;
  };

  fhsEnvAnki = buildFHSEnv (
    appimageTools.defaultFhsEnvArgs
    // {
      inherit pname version;
      inherit meta passthru;

      extraInstallCommands = ''
        ln -s ${pname} $out/bin/anki

        mkdir -p $out/share
        cp -R ${unpacked}/share/applications \
          ${unpacked}/share/man \
          ${unpacked}/share/pixmaps \
          $out/share/
      '';

      profile = ''
        # anki vendors QT and mixing QT versions usually causes crashes
        unset QT_PLUGIN_PATH
        # anki uses the system ssl cert, without it plugins do not download/update
        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
      '';

      runScript = writeShellScript "anki-wrapper.sh" ''
        exec ${unpacked}/bin/anki ${lib.strings.escapeShellArgs commandLineArgs} "$@"
      '';

      # Dependencies of anki
      targetPkgs =
        pkgs:
        (with pkgs; [
          libxkbfile
          libxshmfence
          libxcb-cursor
          krb5
          zstd
        ]);
    }
  );
in

if stdenv.hostPlatform.isLinux then
  fhsEnvAnki
else
  stdenv.mkDerivation {
    inherit pname version passthru;
    inherit meta;
    src = if stdenv.hostPlatform.isAarch64 then sources.darwin-aarch64 else sources.darwin-x86_64;
    nativeBuildInputs = [ undmg ];

    installPhase = ''
      mkdir -p $out/Applications/
      cp -a Anki.app $out/Applications/
    '';

    sourceRoot = ".";
  }
