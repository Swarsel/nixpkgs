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
      accept = buildRebar3 rec {
        version = "0.3.5";

        src = fetchHex {
          sha256 = "11b18c220bcc2eab63b5470c038ef10eb6783bcb1fcdb11aa4137defa5ac1bb8";
          pkg = "accept";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "accept";
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

      bandit = buildMix rec {
        version = "1.10.4";

        src = fetchHex {
          sha256 = "a5faf501042ac1f31d736d9d4a813b3db4ef812e634583b6a457b0928798a51d";
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

      base62 = buildMix rec {
        version = "1.2.2";

        src = fetchHex {
          sha256 = "d41336bda8eaa5be197f1e4592400513ee60518e5b9f4dcf38f4b4dae6f377bb";
          pkg = "base62";
          version = "${version}";
        };

        beamDeps = [ custom_base ];
        name = "base62";
      };

      bbcode_pleroma = buildMix rec {
        version = "0.2.0";

        src = fetchHex {
          sha256 = "19851074419a5fedb4ef49e1f01b30df504bb5dbb6d6adfc135238063bebd1c3";
          pkg = "bbcode_pleroma";
          version = "${version}";
        };

        beamDeps = [ nimble_parsec ];
        name = "bbcode_pleroma";
      };

      bcrypt_elixir = buildMix rec {
        version = "2.3.1";

        src = fetchHex {
          sha256 = "42182d5f46764def15bf9af83739e3bf4ad22661b1c34fc3e88558efced07279";
          pkg = "bcrypt_elixir";
          version = "${version}";
        };

        beamDeps = [
          comeonin
          elixir_make
        ];

        name = "bcrypt_elixir";
      };

      benchee = buildMix rec {
        version = "1.4.0";

        src = fetchHex {
          sha256 = "299cd10dd8ce51c9ea3ddb74bb150f93d25e968f93e4c1fa31698a8e4fa5d715";
          pkg = "benchee";
          version = "${version}";
        };

        beamDeps = [
          deep_merge
          statistex
        ];

        name = "benchee";
      };

      blurhash = buildMix rec {
        version = "0.1.0";

        src = fetchHex {
          sha256 = "19911a5dcbb0acb9710169a72f702bce6cb048822b12de566ccd82b2cc42b907";
          pkg = "rinpatch_blurhash";
          version = "${version}";
        };

        beamDeps = [ mogrify ];
        name = "blurhash";
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

      calendar = buildMix rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "990e9581920c82912a5ee50e62ff5ef96da6b15949a2ee4734f935fdef0f0a6f";
          pkg = "calendar";
          version = "${version}";
        };

        beamDeps = [ tzdata ];
        name = "calendar";
      };

      castore = buildMix rec {
        version = "1.0.15";

        src = fetchHex {
          sha256 = "96ce4c69d7d5d7a0761420ef743e2f4096253931a3ba69e5ff8ef1844fe446d3";
          pkg = "castore";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "castore";
      };

      cc_precompiler = buildMix rec {
        version = "0.1.11";

        src = fetchHex {
          sha256 = "3427232caf0835f94680e5bcf082408a70b48ad68a5f5c0b02a3bea9f3a075b9";
          pkg = "cc_precompiler";
          version = "${version}";
        };

        beamDeps = [ elixir_make ];
        name = "cc_precompiler";
      };

      certifi = buildRebar3 rec {
        version = "2.12.0";

        src = fetchHex {
          sha256 = "ee68d85df22e554040cdb4be100f33873ac6051387baf6a8f6ce82272340ff1c";
          pkg = "certifi";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "certifi";
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

      concurrent_limiter = buildMix rec {
        version = "0.1.1";

        src = fetchHex {
          sha256 = "53968ff238c0fbb4d7ed76ddb1af0be6f3b2f77909f6796e249e737c505a16eb";
          pkg = "concurrent_limiter";
          version = "${version}";
        };

        beamDeps = [ telemetry ];
        name = "concurrent_limiter";
      };

      connection = buildMix rec {
        version = "1.1.0";

        src = fetchHex {
          sha256 = "722c1eb0a418fbe91ba7bd59a47e28008a189d47e37e0e7bb85585a016b2869c";
          pkg = "connection";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "connection";
      };

      cors_plug = buildMix rec {
        version = "2.0.3";

        src = fetchHex {
          sha256 = "ee4ae1418e6ce117fc42c2ba3e6cbdca4e95ecd2fe59a05ec6884ca16d469aea";
          pkg = "cors_plug";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "cors_plug";
      };

      covertool = buildRebar3 rec {
        version = "2.0.7";

        src = fetchHex {
          sha256 = "46158ed6e1a0df7c0a912e314c7b8e053bd74daa5fc6b790614922a155b5720c";
          pkg = "covertool";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "covertool";
      };

      cowboy = buildErlangMk rec {
        version = "2.13.0";

        src = fetchHex {
          sha256 = "e724d3a70995025d654c1992c7b11dbfea95205c047d86ff9bf1cda92ddc5614";
          pkg = "cowboy";
          version = "${version}";
        };

        beamDeps = [
          cowlib
          ranch
        ];

        name = "cowboy";
      };

      cowboy_telemetry = buildRebar3 rec {
        version = "0.4.0";

        src = fetchHex {
          sha256 = "7d98bac1ee4565d31b62d59f8823dfd8356a169e7fcbb83831b8a5397404c9de";
          pkg = "cowboy_telemetry";
          version = "${version}";
        };

        beamDeps = [
          cowboy
          telemetry
        ];

        name = "cowboy_telemetry";
      };

      cowlib = buildRebar3 rec {
        version = "2.15.0";

        src = fetchHex {
          sha256 = "4f00c879a64b4fe7c8fcb42a4281925e9ffdb928820b03c3ad325a617e857532";
          pkg = "cowlib";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "cowlib";
      };

      credo = buildMix rec {
        version = "1.7.12";

        src = fetchHex {
          sha256 = "8493d45c656c5427d9c729235b99d498bd133421f3e0a683e5c1b561471291e5";
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

      crontab = buildMix rec {
        version = "1.1.8";

        src = fetchHex {
          sha256 = "1gkb7ps38j789acj8dw2q7jnhhw43idyvh36fb3i52yjkhli7ra8";
          pkg = "crontab";
          version = "${version}";
        };

        beamDeps = [ ecto ];
        name = "crontab";
      };

      custom_base = buildMix rec {
        version = "0.2.1";

        src = fetchHex {
          sha256 = "8df019facc5ec9603e94f7270f1ac73ddf339f56ade76a721eaa57c1493ba463";
          pkg = "custom_base";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "custom_base";
      };

      db_connection = buildMix rec {
        version = "2.8.0";

        src = fetchHex {
          sha256 = "008399dae5eee1bf5caa6e86d204dcb44242c82b1ed5e22c881f2c34da201b15";
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

      deep_merge = buildMix rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "ce708e5f094b9cd4e8f2be4f00d2f4250c4095be93f8cd6d018c753894885430";
          pkg = "deep_merge";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "deep_merge";
      };

      dialyxir = buildMix rec {
        version = "1.4.6";

        src = fetchHex {
          sha256 = "8cf5615c5cd4c2da6c501faae642839c8405b49f8aa057ad4ae401cb808ef64d";
          pkg = "dialyxir";
          version = "${version}";
        };

        beamDeps = [ erlex ];
        name = "dialyxir";
      };

      earmark = buildMix rec {
        version = "1.4.46";

        src = fetchHex {
          sha256 = "798d86db3d79964e759ddc0c077d5eb254968ed426399fbf5a62de2b5ff8910a";
          pkg = "earmark";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "earmark";
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

      ecto = buildMix rec {
        version = "3.13.2";

        src = fetchHex {
          sha256 = "669d9291370513ff56e7b7e7081b7af3283d02e046cf3d403053c557894a0b3e";
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

      ecto_psql_extras = buildMix rec {
        version = "0.8.8";

        src = fetchHex {
          sha256 = "04c63d92b141723ad6fed2e60a4b461ca00b3594d16df47bbc48f1f4534f2c49";
          pkg = "ecto_psql_extras";
          version = "${version}";
        };

        beamDeps = [
          ecto_sql
          postgrex
          table_rex
        ];

        name = "ecto_psql_extras";
      };

      ecto_sql = buildMix rec {
        version = "3.13.2";

        src = fetchHex {
          sha256 = "539274ab0ecf1a0078a6a72ef3465629e4d6018a3028095dc90f60a19c371717";
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

      eimp = buildRebar3 rec {
        version = "1.0.14";

        src = fetchHex {
          sha256 = "501133f3112079b92d9e22da8b88bf4f0e13d4d67ae9c15c42c30bd25ceb83b6";
          pkg = "eimp";
          version = "${version}";
        };

        beamDeps = [ p1_utils ];
        name = "eimp";
      };

      elixir_make = buildMix rec {
        version = "0.7.8";

        src = fetchHex {
          sha256 = "7a71945b913d37ea89b06966e1342c85cfe549b15e6d6d081e8081c493062c07";
          pkg = "elixir_make";
          version = "${version}";
        };

        beamDeps = [
          castore
          certifi
        ];

        name = "elixir_make";
      };

      erlex = buildMix rec {
        version = "0.2.7";

        src = fetchHex {
          sha256 = "3ed95f79d1a844c3f6bf0cea61e0d5612a42ce56da9c03f01df538685365efb0";
          pkg = "erlex";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "erlex";
      };

      esbuild = buildMix rec {
        version = "0.5.0";

        src = fetchHex {
          sha256 = "f183a0b332d963c4cfaf585477695ea59eef9a6f2204fdd0efa00e099694ffe5";
          pkg = "esbuild";
          version = "${version}";
        };

        beamDeps = [ castore ];
        name = "esbuild";
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

      ex_aws = buildMix rec {
        version = "2.1.9";

        src = fetchHex {
          sha256 = "3e6c776703c9076001fbe1f7c049535f042cb2afa0d2cbd3b47cbc4e92ac0d10";
          pkg = "ex_aws";
          version = "${version}";
        };

        beamDeps = [
          hackney
          jason
          sweet_xml
        ];

        name = "ex_aws";
      };

      ex_aws_s3 = buildMix rec {
        version = "2.5.8";

        src = fetchHex {
          sha256 = "84e512ca2e0ae6a6c497036dff06d4493ffb422cfe476acc811d7c337c16691c";
          pkg = "ex_aws_s3";
          version = "${version}";
        };

        beamDeps = [
          ex_aws
          sweet_xml
        ];

        name = "ex_aws_s3";
      };

      ex_const = buildMix rec {
        version = "0.3.0";

        src = fetchHex {
          sha256 = "76546322abb9e40ee4a2f454cf1c8a5b25c3672fa79bed1ea52c31e0d2428ca9";
          pkg = "ex_const";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "ex_const";
      };

      ex_doc = buildMix rec {
        version = "0.38.2";

        src = fetchHex {
          sha256 = "732f2d972e42c116a70802f9898c51b54916e542cc50968ac6980512ec90f42b";
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

      ex_syslogger = buildMix rec {
        version = "1.5.2";

        src = fetchHex {
          sha256 = "ab9fab4136dbc62651ec6f16fa4842f10cf02ab4433fa3d0976c01be99398399";
          pkg = "ex_syslogger";
          version = "${version}";
        };

        beamDeps = [
          poison
          syslog
        ];

        name = "ex_syslogger";
      };

      exile = buildMix rec {
        version = "0.10.0";

        src = fetchHex {
          sha256 = "c62ee8fee565b5ac4a898d0dcd58d2b04fb5eec1655af1ddcc9eb582c6732c33";
          pkg = "exile";
          version = "${version}";
        };

        beamDeps = [ elixir_make ];
        name = "exile";
      };

      expo = buildMix rec {
        version = "0.5.1";

        src = fetchHex {
          sha256 = "68a4233b0658a3d12ee00d27d37d856b1ba48607e7ce20fd376958d0ba6ce92b";
          pkg = "expo";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "expo";
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

      file_system = buildMix rec {
        version = "0.2.10";

        src = fetchHex {
          sha256 = "41195edbfb562a593726eda3b3e8b103a309b733ad25f3d642ba49696bf715dc";
          pkg = "file_system";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "file_system";
      };

      finch = buildMix rec {
        version = "0.20.0";

        src = fetchHex {
          sha256 = "2658131a74d051aabfcba936093c903b8e89da9a1b63e430bee62045fa9b2ee2";
          pkg = "finch";
          version = "${version}";
        };

        beamDeps = [
          mime
          mint
          nimble_options
          nimble_pool
          telemetry
        ];

        name = "finch";
      };

      flake_id = buildMix rec {
        version = "0.1.0";

        src = fetchHex {
          sha256 = "31fc8090fde1acd267c07c36ea7365b8604055f897d3a53dd967658c691bd827";
          pkg = "flake_id";
          version = "${version}";
        };

        beamDeps = [
          base62
          ecto
        ];

        name = "flake_id";
      };

      floki = buildMix rec {
        version = "0.38.0";

        src = fetchHex {
          sha256 = "a5943ee91e93fb2d635b612caf5508e36d37548e84928463ef9dd986f0d1abd9";
          pkg = "floki";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "floki";
      };

      gen_smtp = buildRebar3 rec {
        version = "0.15.0";

        src = fetchHex {
          sha256 = "29bd14a88030980849c7ed2447b8db6d6c9278a28b11a44cafe41b791205440f";
          pkg = "gen_smtp";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "gen_smtp";
      };

      gettext = buildMix rec {
        version = "0.24.0";

        src = fetchHex {
          sha256 = "bdf75cdfcbe9e4622dd18e034b227d77dd17f0f133853a1c73b97b3d6c770e8b";
          pkg = "gettext";
          version = "${version}";
        };

        beamDeps = [ expo ];
        name = "gettext";
      };

      gun = buildRebar3 rec {
        version = "2.2.0";

        src = fetchHex {
          sha256 = "76022700c64287feb4df93a1795cff6741b83fb37415c40c34c38d2a4645261a";
          pkg = "gun";
          version = "${version}";
        };

        beamDeps = [ cowlib ];
        name = "gun";
      };

      hackney = buildRebar3 rec {
        version = "1.20.1";

        src = fetchHex {
          sha256 = "fe9094e5f1a2a2c0a7d10918fee36bfec0ec2a979994cff8cfe8058cd9af38e3";
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
        version = "1.0.8";

        src = fetchHex {
          sha256 = "d5b26da66603bb56c933c65214c72152f0de9a6ea53618b56d63302a68f6a90e";
          pkg = "inet_cidr";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "inet_cidr";
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

      joken = buildMix rec {
        version = "2.6.2";

        src = fetchHex {
          sha256 = "5134b5b0a6e37494e46dbf9e4dad53808e5e787904b7c73972651b51cce3d72b";
          pkg = "joken";
          version = "${version}";
        };

        beamDeps = [ jose ];
        name = "joken";
      };

      jose = buildMix rec {
        version = "1.11.10";

        src = fetchHex {
          sha256 = "0d6cd36ff8ba174db29148fc112b5842186b68a90ce9fc2b3ec3afe76593e614";
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

      logger_backends = buildMix rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "1faceb3e7ec3ef66a8f5746c5afd020e63996df6fd4eb8cdb789e5665ae6c9ce";
          pkg = "logger_backends";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "logger_backends";
      };

      mail = buildMix rec {
        version = "0.3.1";

        src = fetchHex {
          sha256 = "1db701e89865c1d5fa296b2b57b1cd587587cca8d8a1a22892b35ef5a8e352a6";
          pkg = "mail";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mail";
      };

      majic = buildMix rec {
        version = "1.1.1";

        src = fetchHex {
          sha256 = "7fbb0372f0447b3f777056177d6ab3f009742e68474f850521ff56b84bd85b96";
          pkg = "majic";
          version = "${version}";
        };

        beamDeps = [
          elixir_make
          mime
          nimble_pool
          plug
        ];

        name = "majic";
      };

      makeup = buildMix rec {
        version = "1.0.5";

        src = fetchHex {
          sha256 = "cfa158c02d3f5c0c665d0af11512fed3fba0144cf1aadee0f2ce17747fba2ca9";
          pkg = "makeup";
          version = "${version}";
        };

        beamDeps = [ nimble_parsec ];
        name = "makeup";
      };

      makeup_elixir = buildMix rec {
        version = "0.14.1";

        src = fetchHex {
          sha256 = "f2438b1a80eaec9ede832b5c41cd4f373b38fd7aa33e3b22d9db79e640cbde11";
          pkg = "makeup_elixir";
          version = "${version}";
        };

        beamDeps = [ makeup ];
        name = "makeup_elixir";
      };

      makeup_erlang = buildMix rec {
        version = "1.0.2";

        src = fetchHex {
          sha256 = "af33ff7ef368d5893e4a267933e7744e46ce3cf1f61e2dccf53a111ed3aa3727";
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
        version = "1.6.0";

        src = fetchHex {
          sha256 = "31a1a8613f8321143dde1dafc36006a17d28d02bdfecb9e95a880fa7aabd19a7";
          pkg = "mime";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mime";
      };

      mimerl = buildRebar3 rec {
        version = "1.5.0";

        src = fetchHex {
          sha256 = "db648ce065bae14ea84ca8b5dd123f42f49417cef693541110bf6f9e9be9ecc4";
          pkg = "mimerl";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mimerl";
      };

      mint = buildMix rec {
        version = "1.7.1";

        src = fetchHex {
          sha256 = "fceba0a4d0f24301ddee3024ae116df1c3f4bb7a563a731f45fdfeb9d39a231b";
          pkg = "mint";
          version = "${version}";
        };

        beamDeps = [
          castore
          hpax
        ];

        name = "mint";
      };

      mochiweb = buildRebar3 rec {
        version = "2.18.0";

        src = fetchHex {
          sha256 = "16j8cfn3hq0g474xc5xl8nk2v46hwvwpfwi9rkzavnsbaqg2ngmr";
          pkg = "mochiweb";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "mochiweb";
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

      mua = buildMix rec {
        version = "0.2.4";

        src = fetchHex {
          sha256 = "e7e4dacd5ad65f13e3542772e74a159c00bd2d5579e729e9bb72d2c73a266fb7";
          pkg = "mua";
          version = "${version}";
        };

        beamDeps = [ castore ];
        name = "mua";
      };

      multipart = buildMix rec {
        version = "0.4.0";

        src = fetchHex {
          sha256 = "3c5604bc2fb17b3137e5d2abdf5dacc2647e60c5cc6634b102cf1aef75a06f0a";
          pkg = "multipart";
          version = "${version}";
        };

        beamDeps = [ mime ];
        name = "multipart";
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
        version = "1.0.1";

        src = fetchHex {
          sha256 = "3825e461025464f519f3f3e4a1f9b68c47dc151369611629ad08b636b73bb22d";
          pkg = "nimble_ownership";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "nimble_ownership";
      };

      nimble_parsec = buildMix rec {
        version = "0.6.0";

        src = fetchHex {
          sha256 = "27eac315a94909d4dc68bc07a4a83e06c8379237c5ea528a9acff4ca1c873c52";
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

      oban = buildMix rec {
        version = "2.19.4";

        src = fetchHex {
          sha256 = "5fcc6219e6464525b808d97add17896e724131f498444a292071bf8991c99f97";
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

      oban_live_dashboard = buildMix rec {
        version = "0.1.1";

        src = fetchHex {
          sha256 = "16dc4ce9c9a95aa2e655e35ed4e675652994a8def61731a18af85e230e1caa63";
          pkg = "oban_live_dashboard";
          version = "${version}";
        };

        beamDeps = [
          oban
          phoenix_live_dashboard
        ];

        name = "oban_live_dashboard";
      };

      oban_met = buildMix rec {
        version = "1.0.5";

        src = fetchHex {
          sha256 = "64664d50805bbfd3903aeada1f3c39634652a87844797ee400b0bcc95a28f5ea";
          pkg = "oban_met";
          version = "${version}";
        };

        beamDeps = [ oban ];
        name = "oban_met";
      };

      oban_web = buildMix rec {
        version = "2.11.6";

        src = fetchHex {
          sha256 = "576d94b705688c313694c2c114ca21aa0f8f2ad1b9ca45c052c5ba316d3e8d10";
          pkg = "oban_web";
          version = "${version}";
        };

        beamDeps = [
          jason
          oban
          oban_met
          phoenix
          phoenix_html
          phoenix_live_view
          phoenix_pubsub
        ];

        name = "oban_web";
      };

      octo_fetch = buildMix rec {
        version = "0.4.0";

        src = fetchHex {
          sha256 = "cf8be6f40cd519d7000bb4e84adcf661c32e59369ca2827c4e20042eda7a7fc6";
          pkg = "octo_fetch";
          version = "${version}";
        };

        beamDeps = [
          castore
          ssl_verify_fun
        ];

        name = "octo_fetch";
      };

      open_api_spex = buildMix rec {
        version = "3.22.0";

        src = fetchHex {
          sha256 = "dd751ddbdd709bb4a5313e9a24530da6e66594773c7242a0c2592cbd9f589063";
          pkg = "open_api_spex";
          version = "${version}";
        };

        beamDeps = [
          decimal
          jason
          plug
          poison
        ];

        name = "open_api_spex";
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

      pbkdf2_elixir = buildMix rec {
        version = "1.2.1";

        src = fetchHex {
          sha256 = "d3b40a4a4630f0b442f19eca891fcfeeee4c40871936fed2f68e1c4faa30481f";
          pkg = "pbkdf2_elixir";
          version = "${version}";
        };

        beamDeps = [ comeonin ];
        name = "pbkdf2_elixir";
      };

      phoenix_ecto = buildMix rec {
        version = "4.6.5";

        src = fetchHex {
          sha256 = "26ec3208eef407f31b748cadd044045c6fd485fbff168e35963d2f9dfff28d4b";
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
        version = "3.3.4";

        src = fetchHex {
          sha256 = "0249d3abec3714aff3415e7ee3d9786cb325be3151e6c4b3021502c585bf53fb";
          pkg = "phoenix_html";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "phoenix_html";
      };

      phoenix_live_dashboard = buildMix rec {
        version = "0.8.7";

        src = fetchHex {
          sha256 = "3a8625cab39ec261d48a13b7468dc619c0ede099601b084e343968309bd4d7d7";
          pkg = "phoenix_live_dashboard";
          version = "${version}";
        };

        beamDeps = [
          ecto
          ecto_psql_extras
          mime
          phoenix_live_view
          telemetry_metrics
        ];

        name = "phoenix_live_dashboard";
      };

      phoenix_live_reload = buildMix rec {
        version = "1.3.3";

        src = fetchHex {
          sha256 = "766796676e5f558dbae5d1bdb066849673e956005e3730dfd5affd7a6da4abac";
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
        version = "1.1.19";

        src = fetchHex {
          sha256 = "sha256-1a01fWshVipbQx8K0J3+dtuc5WSMaUnxqsM0yMRFXTI=";
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

        builInputs = [
        ];

        name = "phoenix_live_view";

      };

      phoenix_pubsub = buildMix rec {
        version = "2.1.3";

        src = fetchHex {
          sha256 = "bba06bc1dcfd8cb086759f0edc94a8ba2bc8896d5331a1e2c2902bf8e36ee502";
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
          finch
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

      plug_cowboy = buildMix rec {
        version = "2.7.4";

        src = fetchHex {
          sha256 = "9b85632bd7012615bae0a5d70084deb1b25d2bcbb32cab82d1e9a1e023168aa3";
          pkg = "plug_cowboy";
          version = "${version}";
        };

        beamDeps = [
          cowboy
          cowboy_telemetry
          plug
        ];

        name = "plug_cowboy";
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

      plug_static_index_html = buildMix rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "79fd4fcf34d110605c26560cbae8f23c603ec4158c08298bd4360fdea90bb5cf";
          pkg = "plug_static_index_html";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "plug_static_index_html";
      };

      poison = buildMix rec {
        version = "3.1.0";

        src = fetchHex {
          sha256 = "fec8660eb7733ee4117b85f55799fd3833eb769a6df71ccf8903e8dc5447cfce";
          pkg = "poison";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "poison";
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
        version = "0.21.1";

        src = fetchHex {
          sha256 = "27d8d21c103c3cc68851b533ff99eef353e6a0ff98dc444ea751de43eb48bdac";
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

      pot = buildRebar3 rec {
        version = "1.0.2";

        src = fetchHex {
          sha256 = "78fe127f5a4f5f919d6ea5a2a671827bd53eb9d37e5b4128c0ad3df99856c2e0";
          pkg = "pot";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "pot";
      };

      prom_ex = buildMix rec {
        version = "1.9.0";

        src = fetchHex {
          sha256 = "01f3d4f69ec93068219e686cc65e58a29c42bea5429a8ff4e2121f19db178ee6";
          pkg = "prom_ex";
          version = "${version}";
        };

        beamDeps = [
          ecto
          finch
          jason
          oban
          octo_fetch
          phoenix
          phoenix_live_view
          plug
          plug_cowboy
          telemetry
          telemetry_metrics
          telemetry_metrics_prometheus_core
          telemetry_poller
        ];

        name = "prom_ex";
      };

      prometheus = buildMix rec {
        version = "4.10.0";

        src = fetchHex {
          sha256 = "2a99bb6dce85e238c7236fde6b0064f9834dc420ddbd962aac4ea2a3c3d59384";
          pkg = "prometheus";
          version = "${version}";
        };

        beamDeps = [ quantile_estimator ];
        name = "prometheus";
      };

      prometheus_ecto = buildMix rec {
        version = "1.4.3";

        src = fetchHex {
          sha256 = "8d66289f77f913b37eda81fd287340c17e61a447549deb28efc254532b2bed82";
          pkg = "prometheus_ecto";
          version = "${version}";
        };

        beamDeps = [
          ecto
          prometheus_ex
        ];

        name = "prometheus_ecto";
      };

      prometheus_plugs = buildMix rec {
        version = "1.1.5";

        src = fetchHex {
          sha256 = "0273a6483ccb936d79ca19b0ab629aef0dba958697c94782bb728b920dfc6a79";
          pkg = "prometheus_plugs";
          version = "${version}";
        };

        beamDeps = [
          accept
          plug
          prometheus_ex
        ];

        name = "prometheus_plugs";
      };

      quantile_estimator = buildRebar3 rec {
        version = "0.2.1";

        src = fetchHex {
          sha256 = "282a8a323ca2a845c9e6f787d166348f776c1d4a41ede63046d72d422e3da946";
          pkg = "quantile_estimator";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "quantile_estimator";
      };

      quic = buildRebar3 rec {
        version = "0.10.2";

        src = fetchHex {
          sha256 = "7c196a66973c877a59768a5687f0a0610ff11817254d0a4e45cc4e3a16b1d00b";
          pkg = "quic";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "quic";
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

      recon = buildMix rec {
        version = "2.5.6";

        src = fetchHex {
          sha256 = "96c6799792d735cc0f0fd0f86267e9d351e63339cbe03df9d162010cefc26bb0";
          pkg = "recon";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "recon";
      };

      rustler = buildMix rec {
        version = "0.30.0";

        src = fetchHex {
          sha256 = "9ef1abb6a7dda35c47cfc649e6a5a61663af6cf842a55814a554a84607dee389";
          pkg = "rustler";
          version = "${version}";
        };

        beamDeps = [
          jason
          toml
        ];

        name = "rustler";
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

      statistex = buildMix rec {
        version = "1.1.0";

        src = fetchHex {
          sha256 = "f5950ea26ad43246ba2cce54324ac394a4e7408fdcf98b8e230f503a0cba9cf5";
          pkg = "statistex";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "statistex";
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
        version = "1.16.12";

        src = fetchHex {
          sha256 = "0e262df1ae510d59eeaaa3db42189a2aa1b3746f73771eb2616fc3f7ee63cc20";
          pkg = "swoosh";
          version = "${version}";
        };

        beamDeps = [
          bandit
          cowboy
          ex_aws
          finch
          gen_smtp
          hackney
          jason
          mail
          mime
          mua
          multipart
          plug
          plug_cowboy
          telemetry
        ];

        name = "swoosh";
      };

      syslog = buildRebar3 rec {
        version = "1.1.0";

        src = fetchHex {
          sha256 = "4c6a41373c7e20587be33ef841d3de6f3beba08519809329ecc4d27b15b659e1";
          pkg = "syslog";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "syslog";
      };

      table_rex = buildMix rec {
        version = "4.1.0";

        src = fetchHex {
          sha256 = "95932701df195d43bc2d1c6531178fc8338aa8f38c80f098504d529c43bc2601";
          pkg = "table_rex";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "table_rex";
      };

      telemetry = buildRebar3 rec {
        version = "1.0.0";

        src = fetchHex {
          sha256 = "73bc09fa59b4a0284efb4624335583c528e07ec9ae76aca96ea0673850aec57a";
          pkg = "telemetry";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "telemetry";
      };

      telemetry_metrics = buildMix rec {
        version = "0.6.2";

        src = fetchHex {
          sha256 = "9b43db0dc33863930b9ef9d27137e78974756f5f198cae18409970ed6fa5b561";
          pkg = "telemetry_metrics";
          version = "${version}";
        };

        beamDeps = [ telemetry ];
        name = "telemetry_metrics";
      };

      telemetry_metrics_prometheus_core = buildMix rec {
        version = "1.2.1";

        src = fetchHex {
          sha256 = "5e2c599da4983c4f88a33e9571f1458bf98b0cf6ba930f1dc3a6e8cf45d5afb6";
          pkg = "telemetry_metrics_prometheus_core";
          version = "${version}";
        };

        beamDeps = [
          telemetry
          telemetry_metrics
        ];

        name = "telemetry_metrics_prometheus_core";
      };

      telemetry_poller = buildRebar3 rec {
        version = "1.3.0";

        src = fetchHex {
          sha256 = "51f18bed7128544a50f75897db9974436ea9bfba560420b646af27a9a9b35211";
          pkg = "telemetry_poller";
          version = "${version}";
        };

        beamDeps = [ telemetry ];
        name = "telemetry_poller";
      };

      tesla = buildMix rec {
        version = "1.15.3";

        src = fetchHex {
          sha256 = "98bb3d4558abc67b92fb7be4cd31bb57ca8d80792de26870d362974b58caeda7";
          pkg = "tesla";
          version = "${version}";
        };

        beamDeps = [
          castore
          finch
          gun
          hackney
          jason
          mime
          mint
          mox
          poison
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
        version = "3.7.7";

        src = fetchHex {
          sha256 = "0ec4b09f25fe311321f9fc04144a7e3affe48eb29481d7a5583849b6c4dfa0a7";
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

      toml = buildMix rec {
        version = "0.7.0";

        src = fetchHex {
          sha256 = "0690246a2478c1defd100b0c9b89b4ea280a22be9a7b313a8a058a2408a2fa70";
          pkg = "toml";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "toml";
      };

      trailing_format_plug = buildMix rec {
        version = "0.0.7";

        src = fetchHex {
          sha256 = "bd4fde4c15f3e993a999e019d64347489b91b7a9096af68b2bdadd192afa693f";
          pkg = "trailing_format_plug";
          version = "${version}";
        };

        beamDeps = [ plug ];
        name = "trailing_format_plug";
      };

      tzdata = buildMix rec {
        version = "1.0.5";

        src = fetchHex {
          sha256 = "55519aa2a99e5d2095c1e61cc74c9be69688f8ab75c27da724eb8279ff402a5a";
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

      vix = buildMix rec {
        version = "0.36.0";

        src = fetchHex {
          sha256 = "92f912b4e90c453f92942742105bcdb367ad53406759da251bd2e587e33f4134";
          pkg = "vix";
          version = "${version}";
        };

        beamDeps = [
          cc_precompiler
          elixir_make
        ];

        name = "vix";
      };

      web_push_encryption = buildMix rec {
        version = "0.3.1";

        src = fetchHex {
          sha256 = "4f82b2e57622fb9337559058e8797cb0df7e7c9790793bdc4e40bc895f70e2a2";
          pkg = "web_push_encryption";
          version = "${version}";
        };

        beamDeps = [
          httpoison
          jose
        ];

        name = "web_push_encryption";
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
        version = "0.5.8";

        src = fetchHex {
          sha256 = "315b9a1865552212b5f35140ad194e67ce31af45bcee443d4ecb96b5fd3f3782";
          pkg = "websock_adapter";
          version = "${version}";
        };

        beamDeps = [
          bandit
          plug
          plug_cowboy
          websock
        ];

        name = "websock_adapter";
      };

      websockex = buildMix rec {
        version = "0.4.3";

        src = fetchHex {
          sha256 = "95f2e7072b85a3a4cc385602d42115b73ce0b74a9121d0d6dbbf557645ac53e4";
          pkg = "websockex";
          version = "${version}";
        };

        beamDeps = [ ];
        name = "websockex";
      };
    };
in
self
