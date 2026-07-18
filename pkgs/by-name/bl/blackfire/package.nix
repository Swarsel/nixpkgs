{
  lib,
  stdenv,
  fetchurl,
  common-updater-scripts,
  curl,
  dpkg,
  jq,
  writeShellScript,
}:

stdenv.mkDerivation rec {
  pname = "blackfire";
  version = "2026.6.1";

  src =
    passthru.sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported platform for blackfire: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    dpkg
  ];

  installPhase = ''
    runHook preInstall

    if ${lib.boolToString stdenv.hostPlatform.isLinux}
    then
      dpkg-deb -x $src $out
      mv $out/usr/* $out
      rmdir $out/usr

      # Fix ExecStart path and replace deprecated directory creation method,
      # use dynamic user.
      substituteInPlace "$out/lib/systemd/system/blackfire-agent.service" \
        --replace-fail '/usr/' "$out/" \
        --replace-fail 'ExecStartPre=/bin/mkdir -p /var/run/blackfire' 'RuntimeDirectory=blackfire' \
        --replace-fail 'ExecStartPre=/bin/chown blackfire: /var/run/blackfire' "" \
        --replace-fail 'User=blackfire' 'DynamicUser=yes' \
        --replace-fail 'PermissionsStartOnly=true' ""

      # Modernize socket path.
      substituteInPlace "$out/etc/blackfire/agent" \
        --replace-fail '/var/run' '/run'
    else
      mkdir $out

      tar -zxvf $src

      mv etc $out
      mv usr/* $out
    fi

    runHook postInstall
  '';

  dontUnpack = true;

  passthru = {
    sources = {
      "aarch64-darwin" = fetchurl {
        hash = "sha256-Ofs9raAtx/duS8dXWfvjKGzhJr3j9+gkH8lP/VLfnkE=";
        url = "https://packages.blackfire.io/blackfire/${version}/blackfire-darwin_arm64.pkg.tar.gz";
      };

      "aarch64-linux" = fetchurl {
        hash = "sha256-B+rhmnM2sVICVLDcYq2OEp402Wz6kywCRqeS95Vdzlw=";
        url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire/blackfire_${version}_arm64.deb";
      };

      "i686-linux" = fetchurl {
        hash = "sha256-bQWhiSw9/gGyGoLEyz6BHaRPNLxuqouiobBMfB5ytYk=";
        url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire/blackfire_${version}_i386.deb";
      };

      "x86_64-linux" = fetchurl {
        hash = "sha256-doeqXoS0B7AyzyhkLB9wUC6iuD0c2KIhAIEPeYaDC5E=";
        url = "https://packages.blackfire.io/debian/pool/any/main/b/blackfire/blackfire_${version}_amd64.deb";
      };
    };

    updateScript = writeShellScript "update-blackfire" ''
      set -o errexit
      export PATH="${
        lib.makeBinPath [
          curl
          jq
          common-updater-scripts
        ]
      }"
      NEW_VERSION=$(curl -s https://blackfire.io/api/v1/releases | jq .cli --raw-output)

      if [[ "${version}" = "$NEW_VERSION" ]]; then
          echo "The new version same as the old version."
          exit 0
      fi

      for platform in ${lib.escapeShellArgs meta.platforms}; do
        update-source-version "blackfire" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "Profiler agent and client";
    homepage = "https://blackfire.io/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ spk ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "i686-linux"
      "aarch64-darwin"
    ];
  };
}
