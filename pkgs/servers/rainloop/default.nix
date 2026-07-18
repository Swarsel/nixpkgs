{
  lib,
  stdenv,
  fetchurl,
  dos2unix,
  unzip,
  writeText,
  dataPath ? "/var/lib/rainloop",
}:
let
  common =
    { edition, sha256 }:
    stdenv.mkDerivation rec {
      pname = "rainloop${lib.optionalString (edition != "") "-${edition}"}";
      version = "1.16.0";

      src = fetchurl {
        url = "https://github.com/RainLoop/rainloop-webmail/releases/download/v${version}/rainloop-${edition}${
          lib.optionalString (edition != "") "-"
        }${version}.zip";

        sha256 = sha256;
      };

      patches = [
        ./fix-cve-2022-29360.patch
      ];

      postPatch = ''
        unix2dos ./rainloop/rainloop/v/1.16.0/app/libraries/MailSo/Base/HtmlUtils.php
      '';

      nativeBuildInputs = [
        unzip
        dos2unix
      ];

      installPhase = ''
        mkdir $out
        cp -r rainloop/* $out
        rm -rf $out/data
        cp ${includeScript} $out/include.php
        mkdir $out/data
        chmod 700 $out/data
      '';

      includeScript = writeText "include.php" ''
        <?php

        /**
         * @return string
         */
        function __get_custom_data_full_path()
        {
          $v = getenv('RAINLOOP_DATA_DIR', TRUE);
          return $v === FALSE ? '${dataPath}' : $v;
        }
      '';

      prePatch = ''
        dos2unix ./rainloop/rainloop/v/1.16.0/app/libraries/MailSo/Base/HtmlUtils.php
      '';

      unpackPhase = ''
        mkdir rainloop
        unzip -q -d rainloop $src
      '';

      meta = {
        description = "Simple, modern & fast web-based email client";
        homepage = "https://www.rainloop.net";
        license = with lib.licenses; if edition == "" then unfree else agpl3Only;
        maintainers = with lib.maintainers; [ das_j ];
        platforms = lib.platforms.all;
        downloadPage = "https://github.com/RainLoop/rainloop-webmail/releases";
      };
    };
in
{
  rainloop-community = common {
    edition = "community";
    sha256 = "sha256-25ScQ2OwSKAuqg8GomqDhpebhzQZjCk57h6MxUNiymc=";
  };

  rainloop-standard = common {
    edition = "";
    sha256 = "sha256-aYCwqFqhJEeakn4R0MUDGcSp+M47JbbCrbYaML8aeSs=";
  };
}
