{
  lib,
  fetchFromGitHub,
  libkrb5,
  openssl,
  postgresql,
  postgresqlBuildExtension,
}:

let
  sources = {
    "14" = {
      version = "1.6.3";
      hash = "sha256-KgLidJHjUK9BTp6ffmGUj1chcwIe6IzlcadRpGCfNdM=";
    };

    "15" = {
      version = "1.7.1";
      hash = "sha256-emwoTowT7WKFX0RQDqJXjIblrzqaUIUkzqSqBCHVKQ8=";
    };

    "16" = {
      version = "16.1";
      hash = "sha256-fzoAcXEKmA+xD4HtcHZgcduh1XmSgL8ZS4R72og7RGQ=";
    };

    "17" = {
      version = "17.1";
      hash = "sha256-9St/ESPiFq2NiPKqbwHLwkIyATKUkOGxFcUrWgT+Iqo=";
    };

    "18" = {
      version = "18.0";
      hash = "sha256-+1YKJxMFkok7MsYeA9GRkc2FLxuBGRLpC+JzdK/xqoM=";
    };
  };

  source =
    sources.${lib.versions.major postgresql.version} or {
      version = "";
      hash = throw "Source for pgaudit is not available for ${postgresql.version}";
    };
in
postgresqlBuildExtension {
  inherit (source) version;
  pname = "pgaudit";

  src = fetchFromGitHub {
    inherit (source) hash;
    owner = "pgaudit";
    repo = "pgaudit";
    tag = source.version;
  };

  buildInputs = [
    libkrb5
    openssl
  ];

  makeFlags = [ "USE_PGXS=1" ];
  enableUpdateScript = false;

  meta = {
    description = "Open Source PostgreSQL Audit Logging";
    homepage = "https://github.com/pgaudit/pgaudit";
    changelog = "https://github.com/pgaudit/pgaudit/releases/tag/${source.version}";
    license = lib.licenses.postgresql;
    maintainers = with lib.maintainers; [ idontgetoutmuch ];
    platforms = postgresql.meta.platforms;
    broken = !builtins.elem (lib.versions.major postgresql.version) (builtins.attrNames sources);
  };
}
