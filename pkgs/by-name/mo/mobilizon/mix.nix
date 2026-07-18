{
  lib,
  beamPackages,
  overrides ? (x: y: { }),
}:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages =
    with beamPackages;
    with self;
    {
      absinthe = buildMix rec {
        version = "1.9.1";

        src = fetchHex {
          sha256 = "d93e1aa61d68b974f48d5660104cb911ae045ee3a5d69954d251f91f3dbe2077";
          pkg = "absinthe";
          version = "${version}";
        };

        beamDeps = [
          dataloader
          decimal
          nimble_parsec
          telemetry
        ];

        name = "absinthe";
      };

      absinthe_phoenix = buildMix rec {
        version = "2.0.4";

        src = fetchHex {
          sha256 = "66617ee63b725256ca16264364148b10b19e2ecb177488cd6353584f2e6c1cf3";
          pkg = "absinthe_phoenix";
          version = "${version}";
        };

        beamDeps = [
          absinthe
          absinthe_plug
          decimal
          phoenix
          phoenix_html
          phoenix_pubsub
        ];

        name = "absinthe_phoenix";
      };

      absinthe_plug = buildMix rec {
        version = "1.5.9";

        src = fetchHex {
          sha256 = "dcdc84334b0e9e2cd439bd2653678a822623f212c71088edf0a4a7d03f1fa225";
          pkg = "absinthe_plug";
          version = "${version}";
        };

        beamDeps = [
          absinthe
          plug
        ];

        name = "absinthe_plug";
      };

      argon2_elixir = buildMix rec {
        version = "4.1.3";

        src = fetchHex {
          sha256 = "7c295b8d8e0eaf6f43641698f962526cdf87c6feb7d14bd21e599271b510608c";
          pkg = "argon2_elixir";
          version = "${version}";
        };

        beamDeps = [
          comeonin
          elixir_make
        ];

        name = "argon2_elixir";
      };

      atomex = buildMix rec {
        version = "0.5.1";

        src = fetchHex {
          sha256 = "6248891b5fcab8503982e090eedeeadb757a6311c2ef2e2998b874f7d319ab3f";
          pkg = "atomex";
          version = "${version}";
        };

        beamDeps = [ xml_builder ];
        name = "atomex";
      };

      bandit = buildMix rec {
        version = "1.10.3";

        src = fetchHex {
          sha256 = "99a52d909c48db65ca598e1962797659e3c0f1d06e825a50c3d75b74a5e2db18";
          pkg = "bandit";
          version = "${version}";
        };

        beamDeps = [
          hpax
          plug
          telemetry
          thousand_island
          websock
        ];

        name = "bandit";
      };

      bunt = buildMix rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "dc5f86aa08a5f6fa6b8096f0735c4e76d54ae5c9fa2c143e5a1fc7c1cd9bb6b5";
          pkg = "bunt";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "bunt";
      };

      cachex = buildMix rec {
        version = "3.6.0";

        src = fetchHex {
          sha256 = "ebf24e373883bc8e0c8d894a63bbe102ae13d918f790121f5cfe6e485cc8e2e2";
          pkg = "cachex";
          version = "${version}";
        };

        beamDeps = [
          eternal
          jumper
          sleeplocks
          unsafe
        ];

        name = "cachex";
      };

      castore = buildMix rec {
        version = "1.0.18";

        src = fetchHex {
          sha256 = "f393e4fe6317829b158fb74d86eb681f737d2fe326aa61ccf6293c4104957e34";
          pkg = "castore";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "castore";
      };

      certifi = buildRebar3 rec {
        version = "2.15.0";

        src = fetchHex {
          sha256 = "b147ed22ce71d72eafdad94f055165c1c182f61a2ff49df28bcc71d1d5b94a60";
          pkg = "certifi";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "certifi";
      };

      cldr_utils = buildMix rec {
        version = "2.29.5";

        src = fetchHex {
          sha256 = "962d3a2028b232ee0a5373941dc411028a9442f53444a4d5d2c354f687db1835";
          pkg = "cldr_utils";
          version = "${version}";
        };

        beamDeps = [
          castore
          certifi
          decimal
        ];

        name = "cldr_utils";
      };

      codepagex = buildMix rec {
        version = "0.1.13";

        src = fetchHex {
          sha256 = "c328170767e3ec04682193e7a07a8074c934a995a903d1836777c0ca5edf0d46";
          pkg = "codepagex";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "codepagex";
      };

      combine = buildMix rec {
        version = "0.10.0";

        src = fetchHex {
          sha256 = "1b1dbc1790073076580d0d1d64e42eae2366583e7aecd455d1215b0d16f2451b";
          pkg = "combine";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "combine";
      };

      comeonin = buildMix rec {
        version = "5.5.1";

        src = fetchHex {
          sha256 = "65aac8f19938145377cee73973f192c5645873dcf550a8a6b18187d17c13ccdb";
          pkg = "comeonin";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "comeonin";
      };

      cors_plug = buildMix rec {
        version = "3.0.3";

        src = fetchHex {
          sha256 = "3f2d759e8c272ed3835fab2ef11b46bddab8c1ab9528167bd463b6452edf830d";
          pkg = "cors_plug";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "cors_plug";
      };

      credo = buildMix rec {
        version = "1.7.17";

        src = fetchHex {
          sha256 = "1eb5645c835f0b6c9b5410f94b5a185057bcf6d62a9c2b476da971cde8749645";
          pkg = "credo";
          version = "${version}";
        };

        beamDeps = [
          bunt
          file_system
          jason
        ];

        name = "credo";
      };

      credo_code_climate = buildMix rec {
        version = "0.1.0";

        src = fetchHex {
          sha256 = "75529fe38056f4e229821d604758282838b8397c82e2c12e409fda16b16821ca";
          pkg = "credo_code_climate";
          version = "${version}";
        };

        beamDeps = [
          credo
          jason
        ];

        name = "credo_code_climate";
      };

      dataloader = buildMix rec {
        version = "2.0.2";

        src = fetchHex {
          sha256 = "4c6cabc0b55e96e7de74d14bf37f4a5786f0ab69aa06764a1f39dda40079b098";
          pkg = "dataloader";
          version = "${version}";
        };

        beamDeps = [
          ecto
          telemetry
        ];

        name = "dataloader";
      };

      db_connection = buildMix rec {
        version = "2.9.0";

        src = fetchHex {
          sha256 = "17d502eacaf61829db98facf6f20808ed33da6ccf495354a41e64fe42f9c509c";
          pkg = "db_connection";
          version = "${version}";
        };

        beamDeps = [ telemetry ];
        name = "db_connection";
      };

      decimal = buildMix rec {
        version = "2.3.0";

        src = fetchHex {
          sha256 = "a4d66355cb29cb47c3cf30e71329e58361cfcb37c34235ef3bf1d7bf3773aeac";
          pkg = "decimal";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "decimal";
      };

      dialyxir = buildMix rec {
        version = "1.4.7";

        src = fetchHex {
          sha256 = "b34527202e6eb8cee198efec110996c25c5898f43a4094df157f8d28f27d9efe";
          pkg = "dialyxir";
          version = "${version}";
        };

        beamDeps = [ erlex ];
        name = "dialyxir";
      };

      digital_token = buildMix rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "8ed6f5a8c2fa7b07147b9963db506a1b4c7475d9afca6492136535b064c9e9e6";
          pkg = "digital_token";
          version = "${version}";
        };

        beamDeps = [
          cldr_utils
          jason
        ];

        name = "digital_token";
      };

      doctor = buildMix rec {
        version = "0.22.0";

        src = fetchHex {
          sha256 = "96e22cf8c0df2e9777dc55ebaa5798329b9028889c4023fed3305688d902cd5b";
          pkg = "doctor";
          version = "${version}";
        };

        beamDeps = [ decimal ];
        name = "doctor";
      };

      earmark_parser = buildMix rec {
        version = "1.4.44";

        src = fetchHex {
          sha256 = "4778ac752b4701a5599215f7030989c989ffdc4f6df457c5f36938cc2d2a2750";
          pkg = "earmark_parser";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "earmark_parser";
      };

      eblurhash = buildRebar3 rec {
        version = "1.2.2";

        src = fetchHex {
          sha256 = "8c20ca00904de023a835a9dcb7b7762fed32264c85a80c3cafa85288e405044c";
          pkg = "eblurhash";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "eblurhash";
      };

      ecto = buildMix rec {
        version = "3.13.5";

        src = fetchHex {
          sha256 = "df9efebf70cf94142739ba357499661ef5dbb559ef902b68ea1f3c1fabce36de";
          pkg = "ecto";
          version = "${version}";
        };

        beamDeps = [
          decimal
          jason
          telemetry
        ];

        name = "ecto";
      };

      ecto_autoslug_field = buildMix rec {
        version = "3.1.0";

        src = fetchHex {
          sha256 = "b6ddd614805263e24b5c169532c934440d0289181cce873061fca3a8e92fd9ff";
          pkg = "ecto_autoslug_field";
          version = "${version}";
        };

        beamDeps = [
          ecto
          slugify
        ];

        name = "ecto_autoslug_field";
      };

      ecto_dev_logger = buildMix rec {
        version = "0.15.0";

        src = fetchHex {
          sha256 = "b2c807d7d599a4fcf288139851c09262333b193bdb41f8d65f515853d117e88a";
          pkg = "ecto_dev_logger";
          version = "${version}";
        };

        beamDeps = [
          ecto
          geo
          jason
          postgrex
        ];

        name = "ecto_dev_logger";
      };

      ecto_enum = buildMix rec {
        version = "1.4.0";

        src = fetchHex {
          sha256 = "8fb55c087181c2b15eee406519dc22578fa60dd82c088be376d0010172764ee4";
          pkg = "ecto_enum";
          version = "${version}";
        };

        beamDeps = [
          ecto
          ecto_sql
          postgrex
        ];

        name = "ecto_enum";
      };

      ecto_shortuuid = buildMix rec {
        version = "0.4.0";

        src = fetchHex {
          sha256 = "1edb0e17f689c564039cb780b6a7409076f179ad236ad96413f00c7613db8bb3";
          pkg = "ecto_shortuuid";
          version = "${version}";
        };

        beamDeps = [
          ecto
          shortuuid
        ];

        name = "ecto_shortuuid";
      };

      ecto_sql = buildMix rec {
        version = "3.13.5";

        src = fetchHex {
          sha256 = "aa36751f4e6a2b56ae79efb0e088042e010ff4935fc8684e74c23b1f49e25fdc";
          pkg = "ecto_sql";
          version = "${version}";
        };

        beamDeps = [
          db_connection
          ecto
          postgrex
          telemetry
        ];

        name = "ecto_sql";
      };

      elixir_feed_parser = buildMix rec {
        version = "2.1.0";

        src = fetchHex {
          sha256 = "2d3c62fe7b396ee3b73d7160bc8fadbd78bfe9597c98c7d79b3f1038d9cba28f";
          pkg = "elixir_feed_parser";
          version = "${version}";
        };

        beamDeps = [ timex ];
        name = "elixir_feed_parser";
      };

      elixir_make = buildMix rec {
        version = "0.9.0";

        src = fetchHex {
          sha256 = "db23d4fd8b757462ad02f8aa73431a426fe6671c80b200d9710caf3d1dd0ffdb";
          pkg = "elixir_make";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "elixir_make";
      };

      erlex = buildMix rec {
        version = "0.2.8";

        src = fetchHex {
          sha256 = "9d66ff9fedf69e49dc3fd12831e12a8a37b76f8651dd21cd45fcf5561a8a7590";
          pkg = "erlex";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "erlex";
      };

      erlport = buildRebar3 rec {
        version = "0.11.0";

        src = fetchHex {
          sha256 = "8eb136ccaf3948d329b8d1c3278ad2e17e2a7319801bc4cc2da6db278204eee4";
          pkg = "erlport";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "erlport";
      };

      eternal = buildMix rec {
        version = "1.2.2";

        src = fetchHex {
          sha256 = "2c9fe32b9c3726703ba5e1d43a1d255a4f3f2d8f8f9bc19f094c7cb1a7a9e782";
          pkg = "eternal";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "eternal";
      };

      ex_cldr = buildMix rec {
        version = "2.47.2";

        src = fetchHex {
          sha256 = "4a7cef380a1c2546166b45d6ee5e8e2f707ea695b12ae6dadd250201588b4f16";
          pkg = "ex_cldr";
          version = "${version}";
        };

        beamDeps = [
          cldr_utils
          decimal
          gettext
          jason
          nimble_parsec
        ];

        name = "ex_cldr";
      };

      ex_cldr_calendars = buildMix rec {
        version = "2.4.2";

        src = fetchHex {
          sha256 = "ab69fd04bc1ae18baf9d2e57335d4754c5ac263076ea397eb112621702251fe5";
          pkg = "ex_cldr_calendars";
          version = "${version}";
        };

        beamDeps = [
          ex_cldr_numbers
          ex_doc
          jason
        ];

        name = "ex_cldr_calendars";
      };

      ex_cldr_currencies = buildMix rec {
        version = "2.17.1";

        src = fetchHex {
          sha256 = "e266a0a61f4c7d83608154d49b59e4d7485b2aaa7ba1d0e17b3c55910595de51";
          pkg = "ex_cldr_currencies";
          version = "${version}";
        };

        beamDeps = [
          ex_cldr
          jason
        ];

        name = "ex_cldr_currencies";
      };

      ex_cldr_dates_times = buildMix rec {
        version = "2.25.6";

        src = fetchHex {
          sha256 = "926ff5662b849f86088832ee66b61a96aab0fa5a54d5e14240e08ad3030663e2";
          pkg = "ex_cldr_dates_times";
          version = "${version}";
        };

        beamDeps = [
          ex_cldr_calendars
          jason
        ];

        name = "ex_cldr_dates_times";
      };

      ex_cldr_languages = buildMix rec {
        version = "0.3.3";

        src = fetchHex {
          sha256 = "22fb1fef72b7b4b4872d243b34e7b83734247a78ad87377986bf719089cc447a";
          pkg = "ex_cldr_languages";
          version = "${version}";
        };

        beamDeps = [
          ex_cldr
          jason
        ];

        name = "ex_cldr_languages";
      };

      ex_cldr_numbers = buildMix rec {
        version = "2.38.1";

        src = fetchHex {
          sha256 = "4f95738f1dc4e821485e52226666f7691c9276bf6eba49cba8d23c8a2db05e84";
          pkg = "ex_cldr_numbers";
          version = "${version}";
        };

        beamDeps = [
          decimal
          digital_token
          ex_cldr
          ex_cldr_currencies
          jason
        ];

        name = "ex_cldr_numbers";
      };

      ex_cldr_plugs = buildMix rec {
        version = "1.3.4";

        src = fetchHex {
          sha256 = "30829e097eac403013101dc087e6cabf5e01a1c5e3a6b23ea4562e85521ff52a";
          pkg = "ex_cldr_plugs";
          version = "${version}";
        };

        beamDeps = [
          ex_cldr
          gettext
          jason
          plug
        ];

        name = "ex_cldr_plugs";
      };

      ex_doc = buildMix rec {
        version = "0.40.1";

        src = fetchHex {
          sha256 = "bcef0e2d360d93ac19f01a85d58f91752d930c0a30e2681145feea6bd3516e00";
          pkg = "ex_doc";
          version = "${version}";
        };

        beamDeps = [
          earmark_parser
          makeup_elixir
          makeup_erlang
        ];

        name = "ex_doc";
      };

      ex_hash_ring = buildMix rec {
        version = "6.0.4";

        src = fetchHex {
          sha256 = "89adabf31f7d3dfaa36802ce598ce918e9b5b33bae8909ac1a4d052e1e567d18";
          pkg = "ex_hash_ring";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "ex_hash_ring";
      };

      ex_ical = buildMix rec {
        version = "0.2.0";

        src = fetchHex {
          sha256 = "db76473b2ae0259e6633c6c479a5a4d8603f09497f55c88f9ef4d53d2b75befb";
          pkg = "ex_ical";
          version = "${version}";
        };

        beamDeps = [ timex ];
        name = "ex_ical";
      };

      ex_machina = buildMix rec {
        version = "2.8.0";

        src = fetchHex {
          sha256 = "79fe1a9c64c0c1c1fab6c4fa5d871682cb90de5885320c187d117004627a7729";
          pkg = "ex_machina";
          version = "${version}";
        };

        beamDeps = [
          ecto
          ecto_sql
        ];

        name = "ex_machina";
      };

      ex_optimizer = buildMix rec {
        version = "0.1.1";

        src = fetchHex {
          sha256 = "e6f5c059bcd58b66be2f6f257fdc4f69b74b0fa5c9ddd669486af012e4b52286";
          pkg = "ex_optimizer";
          version = "${version}";
        };

        beamDeps = [ file_info ];
        name = "ex_optimizer";
      };

      ex_unit_notifier = buildMix rec {
        version = "1.3.1";

        src = fetchHex {
          sha256 = "87eb1cea911ed1753e1cc046cbf1c7f86af9058e30672a355f0699b41e5e119d";
          pkg = "ex_unit_notifier";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "ex_unit_notifier";
      };

      excoveralls = buildMix rec {
        version = "0.18.5";

        src = fetchHex {
          sha256 = "523fe8a15603f86d64852aab2abe8ddbd78e68579c8525ae765facc5eae01562";
          pkg = "excoveralls";
          version = "${version}";
        };

        beamDeps = [
          castore
          jason
        ];

        name = "excoveralls";
      };

      exgravatar = buildMix rec {
        version = "2.0.3";

        src = fetchHex {
          sha256 = "aca18ff9bd8991d3be3e5446d3bdefc051be084c1ffc9ab2d43b3e65339300e1";
          pkg = "exgravatar";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "exgravatar";
      };

      expo = buildMix rec {
        version = "1.1.1";

        src = fetchHex {
          sha256 = "5fb308b9cb359ae200b7e23d37c76978673aa1b06e2b3075d814ce12c5811640";
          pkg = "expo";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "expo";
      };

      export = buildMix rec {
        version = "0.1.1";

        src = fetchHex {
          sha256 = "3da7444ff4053f1824352f4bdb13fbd2c28c93c2011786fb686b649fdca1021f";
          pkg = "export";
          version = "${version}";
        };

        beamDeps = [ erlport ];
        name = "export";
      };

      fast_html = buildMix rec {
        version = "2.5.0";

        src = fetchHex {
          sha256 = "69eb46ed98a5d9cca1ccd4a5ac94ce5dd626fc29513fbaa0a16cd8b2da67ae3e";
          pkg = "fast_html";
          version = "${version}";
        };

        beamDeps = [
          elixir_make
          nimble_pool
        ];

        name = "fast_html";
      };

      fast_sanitize = buildMix rec {
        version = "0.2.3";

        src = fetchHex {
          sha256 = "e8ad286d10d0386e15d67d0ee125245ebcfbc7d7290b08712ba9013c8c5e56e2";
          pkg = "fast_sanitize";
          version = "${version}";
        };

        beamDeps = [
          fast_html
          plug
        ];

        name = "fast_sanitize";
      };

      file_info = buildMix rec {
        version = "0.0.4";

        src = fetchHex {
          sha256 = "50e7ad01c2c8b9339010675fe4dc4a113b8d6ca7eddce24d1d74fd0e762781a5";
          pkg = "file_info";
          version = "${version}";
        };

        beamDeps = [ mimetype_parser ];
        name = "file_info";
      };

      file_system = buildMix rec {
        version = "1.1.1";

        src = fetchHex {
          sha256 = "7a15ff97dfe526aeefb090a7a9d3d03aa907e100e262a0f8f7746b78f8f87a5d";
          pkg = "file_system";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "file_system";
      };

      floki = buildMix rec {
        version = "0.38.1";

        src = fetchHex {
          sha256 = "e744bf0db7ee34b2c8b62767f04071107af0516a81144b9a2f73fe0494200e5b";
          pkg = "floki";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "floki";
      };

      gen_smtp = buildRebar3 rec {
        version = "1.3.0";

        src = fetchHex {
          sha256 = "0b73fbf069864ecbce02fe653b16d3f35fd889d0fdd4e14527675565c39d84e6";
          pkg = "gen_smtp";
          version = "${version}";
        };

        beamDeps = [ ranch ];
        name = "gen_smtp";
      };

      geo = buildMix rec {
        version = "4.1.0";

        src = fetchHex {
          sha256 = "19edb2b3398ca9f701b573b1fb11bc90951ebd64f18b06bd1bf35abe509a2934";
          pkg = "geo";
          version = "${version}";
        };

        beamDeps = [ jason ];
        name = "geo";
      };

      geo_postgis = buildMix rec {
        version = "3.7.1";

        src = fetchHex {
          sha256 = "c20d823c600d35b7fe9ddd5be03052bb7136c57d6f1775dbd46871545e405280";
          pkg = "geo_postgis";
          version = "${version}";
        };

        beamDeps = [
          ecto
          geo
          jason
          postgrex
        ];

        name = "geo_postgis";
      };

      geohax = buildMix rec {
        version = "1.0.2";

        src = fetchHex {
          sha256 = "4c782de1e1ee781e2fa07ba6ebfbfb66b91c215b901073defe6196184b8b60a4";
          pkg = "geohax";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "geohax";
      };

      geolix = buildMix rec {
        version = "2.0.0";

        src = fetchHex {
          sha256 = "8742bf588ed0bb7def2c443204d09d355990846c6efdff96ded66aac24c301df";
          pkg = "geolix";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "geolix";
      };

      geolix_adapter_mmdb2 = buildMix rec {
        version = "0.6.0";

        src = fetchHex {
          sha256 = "06ff962feae8a310cffdf86b74bfcda6e2d0dccb439bb1f62df2b657b1c0269b";
          pkg = "geolix_adapter_mmdb2";
          version = "${version}";
        };

        beamDeps = [
          geolix
          mmdb2_decoder
        ];

        name = "geolix_adapter_mmdb2";
      };

      gettext = buildMix rec {
        version = "0.26.2";

        src = fetchHex {
          sha256 = "aa978504bcf76511efdc22d580ba08e2279caab1066b76bb9aa81c4a1e0a32a5";
          pkg = "gettext";
          version = "${version}";
        };

        beamDeps = [ expo ];
        name = "gettext";
      };

      guardian = buildMix rec {
        version = "2.4.0";

        src = fetchHex {
          sha256 = "5c80103a9c538fbc2505bf08421a82e8f815deba9eaedb6e734c66443154c518";
          pkg = "guardian";
          version = "${version}";
        };

        beamDeps = [
          jose
          plug
        ];

        name = "guardian";
      };

      guardian_db = buildMix rec {
        version = "3.0.0";

        src = fetchHex {
          sha256 = "9c2ec4278efa34f9f1cc6ba795e552d41fdc7ffba5319d67eeb533b89392d183";
          pkg = "guardian_db";
          version = "${version}";
        };

        beamDeps = [
          ecto
          ecto_sql
          guardian
          postgrex
        ];

        name = "guardian_db";
      };

      guardian_phoenix = buildMix rec {
        version = "2.0.1";

        src = fetchHex {
          sha256 = "21f439246715192b231f228680465d1ed5fbdf01555a4a3b17165532f5f9a08c";
          pkg = "guardian_phoenix";
          version = "${version}";
        };

        beamDeps = [
          guardian
          phoenix
        ];

        name = "guardian_phoenix";
      };

      hackney = buildRebar3 rec {
        version = "1.25.0";

        src = fetchHex {
          sha256 = "7209bfd75fd1f42467211ff8f59ea74d6f2a9e81cbcee95a56711ee79fd6b1d4";
          pkg = "hackney";
          version = "${version}";
        };

        beamDeps = [
          certifi
          idna
          metrics
          mimerl
          parse_trans
          ssl_verify_fun
          unicode_util_compat
        ];

        name = "hackney";
      };

      hammer = buildMix rec {
        version = "6.2.1";

        src = fetchHex {
          sha256 = "b9476d0c13883d2dc0cc72e786bac6ac28911fba7cc2e04b70ce6a6d9c4b2bdc";
          pkg = "hammer";
          version = "${version}";
        };

        beamDeps = [ poolboy ];
        name = "hammer";
      };

      haversine = buildMix rec {
        version = "0.1.0";

        src = fetchHex {
          sha256 = "54dc48e895bc18a59437a37026c873634e17b648a64cb87bfafb96f64d607060";
          pkg = "haversine";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "haversine";
      };

      hpax = buildMix rec {
        version = "1.0.3";

        src = fetchHex {
          sha256 = "8eab6e1cfa8d5918c2ce4ba43588e894af35dbd8e91e6e55c817bca5847df34a";
          pkg = "hpax";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "hpax";
      };

      html_entities = buildMix rec {
        version = "0.5.2";

        src = fetchHex {
          sha256 = "c53ba390403485615623b9531e97696f076ed415e8d8058b1dbaa28181f4fdcc";
          pkg = "html_entities";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "html_entities";
      };

      http_signatures = buildMix rec {
        version = "0.1.2";

        src = fetchHex {
          sha256 = "f08aa9ac121829dae109d608d83c84b940ef2f183ae50f2dd1e9a8bc619d8be7";
          pkg = "http_signatures";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "http_signatures";
      };

      httpoison = buildMix rec {
        version = "1.8.2";

        src = fetchHex {
          sha256 = "2bb350d26972e30c96e2ca74a1aaf8293d61d0742ff17f01e0279fef11599921";
          pkg = "httpoison";
          version = "${version}";
        };

        beamDeps = [ hackney ];
        name = "httpoison";
      };

      idna = buildRebar3 rec {
        version = "6.1.1";

        src = fetchHex {
          sha256 = "92376eb7894412ed19ac475e4a86f7b413c1b9fbb5bd16dccd57934157944cea";
          pkg = "idna";
          version = "${version}";
        };

        beamDeps = [ unicode_util_compat ];
        name = "idna";
      };

      inet_cidr = buildMix rec {
        version = "1.0.9";

        src = fetchHex {
          sha256 = "172da15ff7cf635b1feaf14f5818be28c811b37cc5fb7c5f7c01058c1c1066cc";
          pkg = "inet_cidr";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "inet_cidr";
      };

      ip_reserved = buildMix rec {
        version = "0.1.1";

        src = fetchHex {
          sha256 = "55fcd2b6e211caef09ea3f54ef37d43030bec486325d12fe865ab5ed8140a4fe";
          pkg = "ip_reserved";
          version = "${version}";
        };

        beamDeps = [ inet_cidr ];
        name = "ip_reserved";
      };

      jason = buildMix rec {
        version = "1.4.4";

        src = fetchHex {
          sha256 = "c5eb0cab91f094599f94d55bc63409236a8ec69a21a67814529e8d5f6cc90b3b";
          pkg = "jason";
          version = "${version}";
        };

        beamDeps = [ decimal ];
        name = "jason";
      };

      jose = buildMix rec {
        version = "1.11.12";

        src = fetchHex {
          sha256 = "31e92b653e9210b696765cdd885437457de1add2a9011d92f8cf63e4641bab7b";
          pkg = "jose";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "jose";
      };

      jumper = buildMix rec {
        version = "1.0.2";

        src = fetchHex {
          sha256 = "9b7782409021e01ab3c08270e26f36eb62976a38c1aa64b2eaf6348422f165e1";
          pkg = "jumper";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "jumper";
      };

      junit_formatter = buildMix rec {
        version = "3.4.0";

        src = fetchHex {
          sha256 = "bb36e2ae83f1ced6ab931c4ce51dd3dbef1ef61bb4932412e173b0cfa259dacd";
          pkg = "junit_formatter";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "junit_formatter";
      };

      linkify = buildMix rec {
        version = "0.5.3";

        src = fetchHex {
          sha256 = "3ef35a1377d47c25506e07c1c005ea9d38d700699d92ee92825f024434258177";
          pkg = "linkify";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "linkify";
      };

      makeup = buildMix rec {
        version = "1.2.1";

        src = fetchHex {
          sha256 = "d36484867b0bae0fea568d10131197a4c2e47056a6fbe84922bf6ba71c8d17ce";
          pkg = "makeup";
          version = "${version}";
        };

        beamDeps = [ nimble_parsec ];
        name = "makeup";
      };

      makeup_elixir = buildMix rec {
        version = "1.0.1";

        src = fetchHex {
          sha256 = "7284900d412a3e5cfd97fdaed4f5ed389b8f2b4cb49efc0eb3bd10e2febf9507";
          pkg = "makeup_elixir";
          version = "${version}";
        };

        beamDeps = [
          makeup
          nimble_parsec
        ];

        name = "makeup_elixir";
      };

      makeup_erlang = buildMix rec {
        version = "1.0.3";

        src = fetchHex {
          sha256 = "953297c02582a33411ac6208f2c6e55f0e870df7f80da724ed613f10e6706afd";
          pkg = "makeup_erlang";
          version = "${version}";
        };

        beamDeps = [ makeup ];
        name = "makeup_erlang";
      };

      meck = buildRebar3 rec {
        version = "0.9.2";

        src = fetchHex {
          sha256 = "81344f561357dc40a8344afa53767c32669153355b626ea9fcbc8da6b3045826";
          pkg = "meck";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "meck";
      };

      metrics = buildRebar3 rec {
        version = "1.0.1";

        src = fetchHex {
          sha256 = "69b09adddc4f74a40716ae54d140f93beb0fb8978d8636eaded0c31b6f099f16";
          pkg = "metrics";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "metrics";
      };

      mime = buildMix rec {
        version = "2.0.7";

        src = fetchHex {
          sha256 = "6171188e399ee16023ffc5b76ce445eb6d9672e2e241d2df6050f3c771e80ccd";
          pkg = "mime";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mime";
      };

      mimerl = buildRebar3 rec {
        version = "1.4.0";

        src = fetchHex {
          sha256 = "13af15f9f68c65884ecca3a3891d50a7b57d82152792f3e19d88650aa126b144";
          pkg = "mimerl";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mimerl";
      };

      mimetype_parser = buildMix rec {
        version = "0.1.3";

        src = fetchHex {
          sha256 = "7d8f80c567807ce78cd93c938e7f4b0a20b1aaaaab914bf286f68457d9f7a852";
          pkg = "mimetype_parser";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mimetype_parser";
      };

      mix_test_watch = buildMix rec {
        version = "1.4.0";

        src = fetchHex {
          sha256 = "2b4693e17c8ead2ef56d4f48a0329891e8c2d0d73752c0f09272a2b17dc38d1b";
          pkg = "mix_test_watch";
          version = "${version}";
        };

        beamDeps = [ file_system ];
        name = "mix_test_watch";
      };

      mmdb2_decoder = buildMix rec {
        version = "3.0.1";

        src = fetchHex {
          sha256 = "316af0f388fac824782d944f54efe78e7c9691bbbdb0afd5cccdd0510adf559d";
          pkg = "mmdb2_decoder";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mmdb2_decoder";
      };

      mock = buildMix rec {
        version = "0.3.9";

        src = fetchHex {
          sha256 = "9e1b244c4ca2551bb17bb8415eed89e40ee1308e0fbaed0a4fdfe3ec8a4adbd3";
          pkg = "mock";
          version = "${version}";
        };

        beamDeps = [ meck ];
        name = "mock";
      };

      mogrify = buildMix rec {
        version = "0.9.3";

        src = fetchHex {
          sha256 = "0189b1e1de27455f2b9ae8cf88239cefd23d38de9276eb5add7159aea51731e6";
          pkg = "mogrify";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mogrify";
      };

      mox = buildMix rec {
        version = "1.2.0";

        src = fetchHex {
          sha256 = "c7b92b3cc69ee24a7eeeaf944cd7be22013c52fcb580c1f33f50845ec821089a";
          pkg = "mox";
          version = "${version}";
        };

        beamDeps = [ nimble_ownership ];
        name = "mox";
      };

      nimble_csv = buildMix rec {
        version = "1.3.0";

        src = fetchHex {
          sha256 = "41ccdc18f7c8f8bb06e84164fc51635321e80d5a3b450761c4997d620925d619";
          pkg = "nimble_csv";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "nimble_csv";
      };

      nimble_options = buildMix rec {
        version = "1.1.1";

        src = fetchHex {
          sha256 = "821b2470ca9442c4b6984882fe9bb0389371b8ddec4d45a9504f00a66f650b44";
          pkg = "nimble_options";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "nimble_options";
      };

      nimble_ownership = buildMix rec {
        version = "1.0.2";

        src = fetchHex {
          sha256 = "098af64e1f6f8609c6672127cfe9e9590a5d3fcdd82bc17a377b8692fd81a879";
          pkg = "nimble_ownership";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "nimble_ownership";
      };

      nimble_parsec = buildMix rec {
        version = "1.4.2";

        src = fetchHex {
          sha256 = "4b21398942dda052b403bbe1da991ccd03a053668d147d53fb8c4e0efe09c973";
          pkg = "nimble_parsec";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "nimble_parsec";
      };

      nimble_pool = buildMix rec {
        version = "1.1.0";

        src = fetchHex {
          sha256 = "af2e4e6b34197db81f7aad230c1118eac993acc0dae6bc83bac0126d4ae0813a";
          pkg = "nimble_pool";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "nimble_pool";
      };

      oauth2 = buildMix rec {
        version = "2.1.0";

        src = fetchHex {
          sha256 = "8ac07f85b3307dd1acfeb0ec852f64161b22f57d0ce0c15e616a1dfc8ebe2b41";
          pkg = "oauth2";
          version = "${version}";
        };

        beamDeps = [ tesla ];
        name = "oauth2";
      };

      oauther = buildMix rec {
        version = "1.3.0";

        src = fetchHex {
          sha256 = "78eb888ea875c72ca27b0864a6f550bc6ee84f2eeca37b093d3d833fbcaec04e";
          pkg = "oauther";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "oauther";
      };

      oban = buildMix rec {
        version = "2.20.3";

        src = fetchHex {
          sha256 = "075ffbf1279a96bec495bc63d647b08929837d70bcc0427249ffe4d1dddaec33";
          pkg = "oban";
          version = "${version}";
        };

        beamDeps = [
          ecto_sql
          jason
          postgrex
          telemetry
        ];

        name = "oban";
      };

      paasaa = buildMix rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "709262e8df8fa3b93e502c04d255a63d8729e609d9eb7fc42b9479f3f98e02b7";
          pkg = "paasaa";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "paasaa";
      };

      parse_trans = buildRebar3 rec {
        version = "3.4.1";

        src = fetchHex {
          sha256 = "620a406ce75dada827b82e453c19cf06776be266f5a67cff34e1ef2cbb60e49a";
          pkg = "parse_trans";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "parse_trans";
      };

      phoenix = buildMix rec {
        version = "1.8.5";

        src = fetchHex {
          sha256 = "83b2bb125127e02e9f475c8e3e92736325b5b01b0b9b05407bcb4083b7a32485";
          pkg = "phoenix";
          version = "${version}";
        };

        beamDeps = [
          bandit
          jason
          phoenix_pubsub
          phoenix_template
          phoenix_view
          plug
          plug_crypto
          telemetry
          websock_adapter
        ];

        name = "phoenix";
      };

      phoenix_ecto = buildMix rec {
        version = "4.7.0";

        src = fetchHex {
          sha256 = "1d75011e4254cb4ddf823e81823a9629559a1be93b4321a6a5f11a5306fbf4cc";
          pkg = "phoenix_ecto";
          version = "${version}";
        };

        beamDeps = [
          ecto
          phoenix_html
          plug
          postgrex
        ];

        name = "phoenix_ecto";
      };

      phoenix_html = buildMix rec {
        version = "4.3.0";

        src = fetchHex {
          sha256 = "3eaa290a78bab0f075f791a46a981bbe769d94bc776869f4f3063a14f30497ad";
          pkg = "phoenix_html";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "phoenix_html";
      };

      phoenix_html_helpers = buildMix rec {
        version = "1.0.1";

        src = fetchHex {
          sha256 = "cffd2385d1fa4f78b04432df69ab8da63dc5cf63e07b713a4dcf36a3740e3090";
          pkg = "phoenix_html_helpers";
          version = "${version}";
        };

        beamDeps = [
          phoenix_html
          plug
        ];

        name = "phoenix_html_helpers";
      };

      phoenix_live_reload = buildMix rec {
        version = "1.6.2";

        src = fetchHex {
          sha256 = "d1f89c18114c50d394721365ffb428cce24f1c13de0467ffa773e2ff4a30d5b9";
          pkg = "phoenix_live_reload";
          version = "${version}";
        };

        beamDeps = [
          file_system
          phoenix
        ];

        name = "phoenix_live_reload";
      };

      phoenix_live_view = buildMix rec {
        version = "1.1.27";

        src = fetchHex {
          sha256 = "415735d0b2c612c9104108b35654e977626a0cb346711e1e4f1ed16e3c827ede";
          pkg = "phoenix_live_view";
          version = "${version}";
        };

        beamDeps = [
          jason
          phoenix
          phoenix_html
          phoenix_template
          phoenix_view
          plug
          telemetry
        ];

        name = "phoenix_live_view";
      };

      phoenix_pubsub = buildMix rec {
        version = "2.2.0";

        src = fetchHex {
          sha256 = "adc313a5bf7136039f63cfd9668fde73bba0765e0614cba80c06ac9460ff3e96";
          pkg = "phoenix_pubsub";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "phoenix_pubsub";
      };

      phoenix_swoosh = buildMix rec {
        version = "1.2.1";

        src = fetchHex {
          sha256 = "4000eeba3f9d7d1a6bf56d2bd56733d5cadf41a7f0d8ffe5bb67e7d667e204a2";
          pkg = "phoenix_swoosh";
          version = "${version}";
        };

        beamDeps = [
          hackney
          phoenix
          phoenix_html
          phoenix_view
          swoosh
        ];

        name = "phoenix_swoosh";
      };

      phoenix_template = buildMix rec {
        version = "1.0.4";

        src = fetchHex {
          sha256 = "2c0c81f0e5c6753faf5cca2f229c9709919aba34fab866d3bc05060c9c444206";
          pkg = "phoenix_template";
          version = "${version}";
        };

        beamDeps = [ phoenix_html ];
        name = "phoenix_template";
      };

      phoenix_view = buildMix rec {
        version = "2.0.4";

        src = fetchHex {
          sha256 = "4e992022ce14f31fe57335db27a28154afcc94e9983266835bb3040243eb620b";
          pkg = "phoenix_view";
          version = "${version}";
        };

        beamDeps = [
          phoenix_html
          phoenix_template
        ];

        name = "phoenix_view";
      };

      plug = buildMix rec {
        version = "1.19.1";

        src = fetchHex {
          sha256 = "560a0017a8f6d5d30146916862aaf9300b7280063651dd7e532b8be168511e62";
          pkg = "plug";
          version = "${version}";
        };

        beamDeps = [
          mime
          plug_crypto
          telemetry
        ];

        name = "plug";
      };

      plug_crypto = buildMix rec {
        version = "2.1.1";

        src = fetchHex {
          sha256 = "6470bce6ffe41c8bd497612ffde1a7e4af67f36a15eea5f921af71cf3e11247c";
          pkg = "plug_crypto";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "plug_crypto";
      };

      poolboy = buildRebar3 rec {
        version = "1.5.2";

        src = fetchHex {
          sha256 = "dad79704ce5440f3d5a3681c8590b9dc25d1a561e8f5a9c995281012860901e3";
          pkg = "poolboy";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "poolboy";
      };

      postgrex = buildMix rec {
        version = "0.22.0";

        src = fetchHex {
          sha256 = "a68c4261e299597909e03e6f8ff5a13876f5caadaddd0d23af0d0a61afcc5d84";
          pkg = "postgrex";
          version = "${version}";
        };

        beamDeps = [
          db_connection
          decimal
          jason
        ];

        name = "postgrex";
      };

      progress_bar = buildMix rec {
        version = "3.0.0";

        src = fetchHex {
          sha256 = "6981c2b25ab24aecc91a2dc46623658e1399c21a2ae24db986b90d678530f2b7";
          pkg = "progress_bar";
          version = "${version}";
        };

        beamDeps = [ decimal ];
        name = "progress_bar";
      };

      ranch = buildRebar3 rec {
        version = "2.2.0";

        src = fetchHex {
          sha256 = "fa0b99a1780c80218a4197a59ea8d3bdae32fbff7e88527d7d8a4787eff4f8e7";
          pkg = "ranch";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "ranch";
      };

      remote_ip = buildMix rec {
        version = "1.2.0";

        src = fetchHex {
          sha256 = "2ff91de19c48149ce19ed230a81d377186e4412552a597d6a5137373e5877cb7";
          pkg = "remote_ip";
          version = "${version}";
        };

        beamDeps = [
          combine
          plug
        ];

        name = "remote_ip";
      };

      replug = buildMix rec {
        version = "0.1.0";

        src = fetchHex {
          sha256 = "f71f7a57e944e854fe4946060c6964098e53958074c69fb844b96e0bd58cfa60";
          pkg = "replug";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "replug";
      };

      sentry = buildMix rec {
        version = "11.0.4";

        src = fetchHex {
          sha256 = "feaafc284dc204c82aadaddc884227aeaa3480decb274d30e184b9d41a700c66";
          pkg = "sentry";
          version = "${version}";
        };

        beamDeps = [
          hackney
          jason
          nimble_options
          nimble_ownership
          phoenix
          phoenix_live_view
          plug
          telemetry
        ];

        name = "sentry";
      };

      shortuuid = buildMix rec {
        version = "4.1.0";

        src = fetchHex {
          sha256 = "7336719118b3cca1ac73e95810199b0b9b7d00f9d71bd2c2d27fed4c4f74388e";
          pkg = "shortuuid";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "shortuuid";
      };

      sitemapper = buildMix rec {
        version = "0.10.0";

        src = fetchHex {
          sha256 = "89ef80f04e4092cb3a8cbcf37520fa31784cc07104c0b47354539e38d2e62443";
          pkg = "sitemapper";
          version = "${version}";
        };

        beamDeps = [ xml_builder ];
        name = "sitemapper";
      };

      sleeplocks = buildRebar3 rec {
        version = "1.1.3";

        src = fetchHex {
          sha256 = "d3b3958552e6eb16f463921e70ae7c767519ef8f5be46d7696cc1ed649421321";
          pkg = "sleeplocks";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "sleeplocks";
      };

      slugger = buildMix rec {
        version = "0.3.0";

        src = fetchHex {
          sha256 = "20d0ded0e712605d1eae6c5b4889581c3460d92623a930ddda91e0e609b5afba";
          pkg = "slugger";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "slugger";
      };

      slugify = buildMix rec {
        version = "1.3.1";

        src = fetchHex {
          sha256 = "cb090bbeb056b312da3125e681d98933a360a70d327820e4b7f91645c4d8be76";
          pkg = "slugify";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "slugify";
      };

      sobelow = buildMix rec {
        version = "0.14.1";

        src = fetchHex {
          sha256 = "8fac9a2bd90fdc4b15d6fca6e1608efb7f7c600fa75800813b794ee9364c87f2";
          pkg = "sobelow";
          version = "${version}";
        };

        beamDeps = [ jason ];
        name = "sobelow";
      };

      ssl_verify_fun = buildRebar3 rec {
        version = "1.1.7";

        src = fetchHex {
          sha256 = "fe4c190e8f37401d30167c8c405eda19469f34577987c76dde613e838bbc67f8";
          pkg = "ssl_verify_fun";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "ssl_verify_fun";
      };

      struct_access = buildMix rec {
        version = "1.1.2";

        src = fetchHex {
          sha256 = "e4c411dcc0226081b95709909551fc92b8feb1a3476108348ea7e3f6c12e586a";
          pkg = "struct_access";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "struct_access";
      };

      sweet_xml = buildMix rec {
        version = "0.7.5";

        src = fetchHex {
          sha256 = "193b28a9b12891cae351d81a0cead165ffe67df1b73fe5866d10629f4faefb12";
          pkg = "sweet_xml";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "sweet_xml";
      };

      swoosh = buildMix rec {
        version = "1.23.1";

        src = fetchHex {
          sha256 = "3193813b462d6dd519e907c680df04988c47bae372b4159e0c4c9f1c42dffea3";
          pkg = "swoosh";
          version = "${version}";
        };

        beamDeps = [
          bandit
          gen_smtp
          hackney
          idna
          jason
          mime
          plug
          telemetry
        ];

        name = "swoosh";
      };

      telemetry = buildRebar3 rec {
        version = "1.4.1";

        src = fetchHex {
          sha256 = "2172e05a27531d3d31dd9782841065c50dd5c3c7699d95266b2edd54c2dafa1c";
          pkg = "telemetry";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "telemetry";
      };

      tesla = buildMix rec {
        version = "1.16.0";

        src = fetchHex {
          sha256 = "eb3bdfc0c6c8a23b4e3d86558e812e3577acff1cb4acb6cfe2da1985a1035b89";
          pkg = "tesla";
          version = "${version}";
        };

        beamDeps = [
          castore
          hackney
          jason
          mime
          mox
          telemetry
        ];

        name = "tesla";
      };

      thousand_island = buildMix rec {
        version = "1.4.3";

        src = fetchHex {
          sha256 = "6e4ce09b0fd761a58594d02814d40f77daff460c48a7354a15ab353bb998ea0b";
          pkg = "thousand_island";
          version = "${version}";
        };

        beamDeps = [ telemetry ];
        name = "thousand_island";
      };

      timex = buildMix rec {
        version = "3.7.13";

        src = fetchHex {
          sha256 = "09588e0522669328e973b8b4fd8741246321b3f0d32735b589f78b136e6d4c54";
          pkg = "timex";
          version = "${version}";
        };

        beamDeps = [
          combine
          gettext
          tzdata
        ];

        name = "timex";
      };

      tls_certificate_check = buildRebar3 rec {
        version = "1.32.0";

        src = fetchHex {
          sha256 = "38e38db768244d808e11ed27f812e7d927ea5f999007b07d0473db44d7f7cc51";
          pkg = "tls_certificate_check";
          version = "${version}";
        };

        beamDeps = [ ssl_verify_fun ];
        name = "tls_certificate_check";
      };

      tz_world = buildMix rec {
        version = "1.4.2";

        src = fetchHex {
          sha256 = "ee260d860d475a1a0fa7cd5d76b114007dbbc902144b61d1ca24e6bc23432a4c";
          pkg = "tz_world";
          version = "${version}";
        };

        beamDeps = [
          castore
          certifi
          geo
          jason
        ];

        name = "tz_world";
      };

      tzdata = buildMix rec {
        version = "1.1.3";

        src = fetchHex {
          sha256 = "d4ca85575a064d29d4e94253ee95912edfb165938743dbf002acdf0dcecb0c28";
          pkg = "tzdata";
          version = "${version}";
        };

        beamDeps = [ hackney ];
        name = "tzdata";
      };

      ueberauth = buildMix rec {
        version = "0.10.8";

        src = fetchHex {
          sha256 = "f2d3172e52821375bccb8460e5fa5cb91cfd60b19b636b6e57e9759b6f8c10c1";
          pkg = "ueberauth";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "ueberauth";
      };

      ueberauth_cas = buildMix rec {
        version = "2.3.1";

        src = fetchHex {
          sha256 = "5068ae2b9e217c2f05aa9a67483a6531e21ba0be9a6f6c8749bb7fd1599be321";
          pkg = "ueberauth_cas";
          version = "${version}";
        };

        beamDeps = [
          httpoison
          sweet_xml
          ueberauth
        ];

        name = "ueberauth_cas";
      };

      ueberauth_discord = buildMix rec {
        version = "0.7.0";

        src = fetchHex {
          sha256 = "d6f98ef91abb4ddceada4b7acba470e0e68c4d2de9735ff2f24172a8e19896b4";
          pkg = "ueberauth_discord";
          version = "${version}";
        };

        beamDeps = [
          oauth2
          ueberauth
        ];

        name = "ueberauth_discord";
      };

      ueberauth_facebook = buildMix rec {
        version = "0.10.0";

        src = fetchHex {
          sha256 = "bf8ce5d66b1c50da8abff77e8086c1b710bdde63f4acaef19a651ba43a9537a8";
          pkg = "ueberauth_facebook";
          version = "${version}";
        };

        beamDeps = [
          oauth2
          ueberauth
        ];

        name = "ueberauth_facebook";
      };

      ueberauth_github = buildMix rec {
        version = "0.8.3";

        src = fetchHex {
          sha256 = "ae0ab2879c32cfa51d7287a48219b262bfdab0b7ec6629f24160564247493cc6";
          pkg = "ueberauth_github";
          version = "${version}";
        };

        beamDeps = [
          oauth2
          ueberauth
        ];

        name = "ueberauth_github";
      };

      ueberauth_gitlab_strategy = buildMix rec {
        version = "0.4.0";

        src = fetchHex {
          sha256 = "e86e2e794bb063c07c05a6b1301b73f2be3ba9308d8f47ecc4d510ef9226091e";
          pkg = "ueberauth_gitlab_strategy";
          version = "${version}";
        };

        beamDeps = [
          oauth2
          ueberauth
        ];

        name = "ueberauth_gitlab_strategy";
      };

      ueberauth_google = buildMix rec {
        version = "0.12.1";

        src = fetchHex {
          sha256 = "7f7deacd679b2b66e3bffb68ecc77aa1b5396a0cbac2941815f253128e458c38";
          pkg = "ueberauth_google";
          version = "${version}";
        };

        beamDeps = [
          oauth2
          ueberauth
        ];

        name = "ueberauth_google";
      };

      ueberauth_keycloak_strategy = buildMix rec {
        version = "0.4.0";

        src = fetchHex {
          sha256 = "c03027937bddcbd9ff499e457f9bb05f79018fa321abf79ebcfed2af0007211b";
          pkg = "ueberauth_keycloak_strategy";
          version = "${version}";
        };

        beamDeps = [
          oauth2
          ueberauth
        ];

        name = "ueberauth_keycloak_strategy";
      };

      ueberauth_twitter = buildMix rec {
        version = "0.4.1";

        src = fetchHex {
          sha256 = "83ca8ea3e1a3f976f1adbebfb323b9ebf53af453fbbf57d0486801a303b16065";
          pkg = "ueberauth_twitter";
          version = "${version}";
        };

        beamDeps = [
          httpoison
          oauther
          ueberauth
        ];

        name = "ueberauth_twitter";
      };

      unicode_util_compat = buildRebar3 rec {
        version = "0.7.1";

        src = fetchHex {
          sha256 = "b3a917854ce3ae233619744ad1e0102e05673136776fb2fa76234f3e03b23642";
          pkg = "unicode_util_compat";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "unicode_util_compat";
      };

      unplug = buildMix rec {
        version = "1.1.0";

        src = fetchHex {
          sha256 = "a3b302125ed60b658a9a7c0dff6941050bfc56dc77a0bca72facdb743159898f";
          pkg = "unplug";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "unplug";
      };

      unsafe = buildMix rec {
        version = "1.0.2";

        src = fetchHex {
          sha256 = "b485231683c3ab01a9cd44cb4a79f152c6f3bb87358439c6f68791b85c2df675";
          pkg = "unsafe";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "unsafe";
      };

      vite_phx = buildMix rec {
        version = "0.3.2";

        src = fetchHex {
          sha256 = "43e95d2d80e0cb62c33fc6db4aa6a6135efe1a70395c85a44bdc855da01587ba";
          pkg = "vite_phx";
          version = "${version}";
        };

        beamDeps = [
          jason
          phoenix
        ];

        name = "vite_phx";
      };

      websock = buildMix rec {
        version = "0.5.3";

        src = fetchHex {
          sha256 = "6105453d7fac22c712ad66fab1d45abdf049868f253cf719b625151460b8b453";
          pkg = "websock";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "websock";
      };

      websock_adapter = buildMix rec {
        version = "0.5.9";

        src = fetchHex {
          sha256 = "5534d5c9adad3c18a0f58a9371220d75a803bf0b9a3d87e6fe072faaeed76a08";
          pkg = "websock_adapter";
          version = "${version}";
        };

        beamDeps = [
          bandit
          plug
          websock
        ];

        name = "websock_adapter";
      };

      xml_builder = buildMix rec {
        version = "2.4.0";

        src = fetchHex {
          sha256 = "833e325bb997f032b5a1b740d2fd6feed3c18ca74627f9f5f30513a9ae1a232d";
          pkg = "xml_builder";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "xml_builder";
      };
    };
in
self
