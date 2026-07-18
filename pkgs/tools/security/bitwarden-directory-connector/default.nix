{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  buildPackages,
  electron,
  libsecret,
  nodejs_22,
  pkg-config,
  python3,
}:

let
  common =
    {
      installPhase,
      name,
      npmBuildScript,
    }:
    buildNpmPackage rec {
      inherit npmBuildScript installPhase;
      pname = name;
      version = "2026.4.0";

      src = fetchFromGitHub {
        owner = "bitwarden";
        repo = "directory-connector";
        rev = "v${version}";
        hash = "sha256-FcT+rZkSqlDjSXjmNTHWoNXzW8WPo8LTED8Do5sDvwE=";
      };

      postPatch = ''
        ${lib.getExe buildPackages.jq} 'del(.scripts.preinstall)' package.json > package.json.tmp
        mv -f package.json{.tmp,}

        substituteInPlace electron-builder.json \
          --replace-fail '"afterSign": "scripts/notarize.js",' "" \
          --replace-fail "AppImage" "dir"
      '';

      nativeBuildInputs = [
        (python3.withPackages (ps: with ps; [ setuptools ]))
        pkg-config
      ];

      buildInputs = [
        libsecret
      ];

      npmDepsHash = "sha256-kFuSCcIWAEJ0KNVqEabjqqSZ8CVBbPyxkAxhrbRBqVc=";
      env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      makeCacheWritable = true;
      nodejs = nodejs_22;

      meta = {
        description = "LDAP connector for Bitwarden";
        homepage = "https://github.com/bitwarden/directory-connector";
        license = lib.licenses.gpl3Only;

        maintainers = with lib.maintainers; [
          Silver-Golden
          SuperSandro2000
        ];

        platforms = lib.platforms.linux;
        mainProgram = name;
      };
    };
in
{
  bitwarden-directory-connector = common {
    installPhase = ''
      runHook preInstall

      npm exec electron-builder -- \
        --dir \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version} \
        -c.npmRebuild=false

      mkdir -p $out/share/bitwarden-directory-connector $out/bin
      cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/bitwarden-directory-connector

      makeWrapper ${lib.getExe electron} $out/bin/bitwarden-directory-connector \
        --add-flags $out/share/bitwarden-directory-connector/resources/app.asar \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
        --set-default ELECTRON_IS_DEV 0 \
        --inherit-argv0

      runHook postInstall
    '';

    name = "bitwarden-directory-connector";
    npmBuildScript = "build:dist";
  };

  bitwarden-directory-connector-cli = common {
    installPhase = ''
      runHook preInstall

      mkdir -p $out/libexec/bitwarden-directory-connector
      cp -R build-cli node_modules $out/libexec/bitwarden-directory-connector

      # needs to be wrapped with nodejs so that it can be executed
      chmod +x $out/libexec/bitwarden-directory-connector/build-cli/bwdc.js
      mkdir -p $out/bin
      ln -s $out/libexec/bitwarden-directory-connector/build-cli/bwdc.js $out/bin/bitwarden-directory-connector-cli

      runHook postInstall
    '';

    name = "bitwarden-directory-connector-cli";
    npmBuildScript = "build:cli:prod";
  };
}
