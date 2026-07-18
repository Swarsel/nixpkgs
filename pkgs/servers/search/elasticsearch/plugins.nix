{
  lib,
  stdenv,
  fetchurl,
  config,
  elasticsearch,
  unzip,
}:

let
  esVersion = elasticsearch.version;

  esPlugin =
    a@{
      pluginName,
      installPhase ? ''
        mkdir -p $out/config
        mkdir -p $out/plugins
        ln -s ${elasticsearch}/lib ${elasticsearch}/modules $out
        ES_HOME=$out ${elasticsearch}/bin/elasticsearch-plugin install --batch -v file://$src
        rm $out/lib $out/modules
      '',
      ...
    }:
    stdenv.mkDerivation (
      a
      // {
        inherit installPhase;
        pname = "elasticsearch-${pluginName}";
        nativeBuildInputs = [ unzip ];
        dontUnpack = true;
        # Work around the "unpacker appears to have produced no directories"
        # case that happens when the archive doesn't have a subdirectory.
        sourceRoot = ".";

        meta = a.meta // {
          maintainers = a.meta.maintainers or [ ];
          platforms = elasticsearch.meta.platforms;
        };
      }
    );
in
{

  analysis-icu = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${version}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-HGHhcWj+6IWZ9kQCGJD7HmmvwqYV1zjN0tCsEpN4IAA="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    name = "elasticsearch-analysis-icu-${version}";
    pluginName = "analysis-icu";

    meta = {
      description = "ICU Analysis plugin integrates the Lucene ICU module into elasticsearch";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/analysis-icu";
      license = lib.licenses.asl20;
    };
  };

  analysis-kuromoji = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${version}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-j0WXuGmE3bRNBnDx/uWxfWrIUrdatDt52ASj8m3mrVg="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    pluginName = "analysis-kuromoji";

    meta = {
      description = "Japanese (kuromoji) Analysis plugin integrates Lucene kuromoji analysis module into Elasticsearch";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/analysis-kuromoji";
      license = lib.licenses.asl20;
    };
  };

  analysis-phonetic = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${version}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-X8b8z9LznJQ24aF9GugRuDz1c9buqT7QGS3jhuDbYBM="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    pluginName = "analysis-phonetic";

    meta = {
      description = "Phonetic Analysis plugin integrates phonetic token filter analysis with elasticsearch";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/analysis-phonetic";
      license = lib.licenses.asl20;
    };
  };

  analysis-smartcn = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${version}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-0hHHkywdpjKqzZ9vFqQ9B2aLCky17AYzFcSiaz/zGSw="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    pluginName = "analysis-smartcn";

    meta = {
      description = "Smart Chinese Analysis plugin integrates Lucene Smart Chinese analysis module into Elasticsearch";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/analysis-smartcn";
      license = lib.licenses.asl20;
    };
  };

  discovery-ec2 = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${version}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-44p0Pn0mYKR5hWtC8jdaUbh9mbUGiHN9PK98ZT1jQFY="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    pluginName = "discovery-ec2";

    meta = {
      description = "EC2 discovery plugin uses the AWS API for unicast discovery";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/discovery-ec2";
      license = lib.licenses.asl20;
    };
  };

  ingest-attachment = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${version}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-i+fGO7Ic2Wm/COfPGeRhiJ99Os+rLRYgs/pSepQr68g="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    pluginName = "ingest-attachment";

    meta = {
      description = "Ingest processor that uses Apache Tika to extract contents";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/ingest-attachment";
      license = lib.licenses.asl20;
    };
  };

  repository-gcs = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${esVersion}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-CWyQuzf2fP9BSIUWL/jxkxrXwdvHyujEINDNhY3FKNI="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    pluginName = "repository-gcs";

    meta = {
      description = "GCS repository plugin adds support for using Google Cloud Storage as a repository for Snapshot/Restore";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/repository-gcs";
      license = lib.licenses.asl20;
    };
  };

  repository-s3 = esPlugin rec {
    version = esVersion;

    src = fetchurl {
      url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/${pluginName}/${pluginName}-${esVersion}.zip";

      hash =
        if version == "7.17.27" then
          "sha256-o2T0Dd2RqVh99wDPJMEvpnEpFFjz0lQrN9yAVJfiSGY="
        else
          throw "unsupported version ${version} for plugin ${pluginName}";
    };

    pluginName = "repository-s3";

    meta = {
      description = "S3 repository plugin adds support for using AWS S3 as a repository for Snapshot/Restore";
      homepage = "https://github.com/elastic/elasticsearch/tree/master/plugins/repository-s3";
      license = lib.licenses.asl20;
    };
  };

  search-guard =
    let
      majorVersion = lib.head (builtins.splitVersion esVersion);
    in
    esPlugin rec {
      version =
        # https://docs.search-guard.com/latest/search-guard-versions
        if esVersion == "7.17.27" then
          "${esVersion}-53.10.0"
        else
          throw "unsupported version ${esVersion} for plugin ${pluginName}";

      src =
        if esVersion == "7.17.27" then
          fetchurl {
            url = "https://maven.search-guard.com/search-guard-suite-release/com/floragunn/search-guard-suite-plugin/${version}/search-guard-suite-plugin-${version}.zip";
            hash = "sha256-M1yJ8OD+mDq2uEiK6pvsMxUQMrg6o5A4xEPX8nDt1Rs=";
          }
        else
          throw "unsupported version ${version} for plugin ${pluginName}";

      pluginName = "search-guard";

      meta = {
        description = "Elasticsearch plugin that offers encryption, authentication, and authorisation";
        homepage = "https://search-guard.com";
        license = lib.licenses.asl20;
      };
    };
}
// lib.optionalAttrs config.allowAliases {
  analysis-lemmagen = throw "elasticsearchPlugins.analysis-lemmagen has been removed due to being broken for more than a year; see RFC 180"; # Added 2026-02-05
}
