{
  lib,
  fetchFromGitHub,
  bash,
  buildGoModule,
  buildNpmPackage,
  cacert,
  callPackages,
  chromedriver,
  clangStdenv,
  cmake,
  go,
  makeSetupHook,
  makeWrapper,
  nodejs_24,
  openapi-generator-cli,
  perl,
  python314,
  rustPlatform,
  stdenvNoCC,
  typescript,
  writeShellScript,
}:

let
  nodejs = nodejs_24;

  version = "2026.5.3";

  cargoPackageFlags = [
    "--package"
    "authentik"
  ];

  src = fetchFromGitHub {
    owner = "goauthentik";
    repo = "authentik";
    tag = "version/${version}";
    hash = "sha256-nmAX8nwZpdDcFAPvC9hAEp0x43RnFtGLUTAm7NcvNZo=";
  };

  meta = {
    description = "Authentication glue you need";
    homepage = "https://goauthentik.io/";
    changelog = "https://github.com/goauthentik/authentik/releases/tag/version%2F${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jvanbruegge
      risson
    ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };

  client-go = stdenvNoCC.mkDerivation {
    inherit version src meta;
    pname = "authentik-client-go";

    nativeBuildInputs = [
      openapi-generator-cli
      go
    ];

    buildPhase = ''
      runHook preBuild

      openapi-generator-cli generate \
        -i ${src}/schema.yml -o $out \
        -g go \
        -c ./config.yaml

      gofmt -w $out

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cd $out
      rm -rf test
      rm -f go.mod go.sum
      rm -f .travis.yml git_push.sh

      runHook postInstall
    '';

    sourceRoot = "${src.name}/packages/client-go";
  };

  client-ts = stdenvNoCC.mkDerivation {
    inherit version src meta;
    pname = "authentik-client-ts";

    postPatch = ''
      substituteInPlace ./packages/client-ts/config.yaml \
        --replace-fail '/local' "$(pwd)/packages/client-ts"
    '';

    nativeBuildInputs = [
      nodejs
      openapi-generator-cli
      typescript
    ];

    buildPhase = ''
      runHook preBuild

      openapi-generator-cli generate \
        -i ./schema.yml -o $out \
        -g typescript-fetch \
        -c ./packages/client-ts/config.yaml \
        --additional-properties=npmVersion=${version} \
        --git-repo-id authentik --git-user-id goauthentik

      cd $out
      npm run build

      runHook postBuild
    '';
  };

  website-deps = buildNpmPackage {
    inherit src version meta;
    inherit nodejs;
    pname = "authentik-website-deps";
    npmDepsHash = "sha256-SkIZF+wQPgoZOGJc0YR8Ot07KCsAdA1985SLQaoibfA=";

    # dependencies of workspace projects are installed into separate node_modules folders with
    # symlinks between them, so we have to copy all of them
    installPhase = ''
      mkdir $out
      echo "Copying node_modules folders:"
      find -type d -name node_modules -prune -print -exec mkdir -p $out/{} \; -exec cp -rT {} $out/{} \;
    '';

    dontCheckForBrokenSymlinks = true;
    dontNpmBuild = true;
    dontPatchShebangs = true;
    makeCacheWritable = true;
    npmDepsFetcherVersion = 2;
    npmInstallFlags = [ "--legacy-peer-deps" ];
    npmRebuildFlags = [ "--ignore-scripts" ];
    sourceRoot = "${src.name}/website";
  };

  website = stdenvNoCC.mkDerivation {
    inherit src version meta;
    pname = "authentik-website";
    nativeBuildInputs = [ nodejs ];

    buildPhase = ''
      runHook preBuild

      buildRoot=$PWD
      pushd ${website-deps}
      find -type d -name node_modules -prune -print -exec cp -rT {} $buildRoot/{} \;
      popd

      chmod -R +w node_modules

      pushd node_modules/.bin
      patchShebangs $(readlink docusaurus) $(readlink run-s)
      popd
      npm run build:api

      runHook postBuild
    '';

    installPhase = ''
      mkdir $out
      cp -r api/build $out/help
    '';

    sourceRoot = "${src.name}/website";
  };

  # prefetch-npm-deps does not save all dependencies even though the lockfile is fine
  webui-deps = stdenvNoCC.mkDerivation {
    inherit src version meta;
    pname = "authentik-webui-deps";

    nativeBuildInputs = [
      nodejs
      cacert
    ];

    buildPhase = ''
      chmod -R +w . ../packages/client-ts
      npm ci --cache ./cache --ignore-scripts

      rm -r ./cache node_modules/.package-lock.json
    '';

    # dependencies of workspace projects are installed into separate node_modules folders with
    # symlinks between them, so we have to copy all of them
    installPhase = ''
      mkdir $out
      echo "Copying node_modules folders:"
      find -type d -name node_modules -prune -print -exec mkdir -p $out/{} \; -exec cp -rT {} $out/{} \;
    '';

    dontCheckForBrokenSymlinks = true;
    dontPatchShebangs = true;

    outputHash =
      {
        "aarch64-linux" = "sha256-41xZEfLul92vJATZqyVnd7Pp++NzLL/u8NeJJPHpXrw=";
        "x86_64-linux" = "sha256-p6xjAinU2Isl/uYgoJuacqHN7jBnbWam40J6AQudbtQ=";
      }
      .${stdenvNoCC.hostPlatform.system} or (throw "authentik-webui-deps: unsupported host platform");

    outputHashMode = "recursive";
    sourceRoot = "${src.name}/web";
  };

  webui = stdenvNoCC.mkDerivation {
    inherit src version meta;
    pname = "authentik-webui";

    postPatch = ''
      substituteInPlace packages/core/version/node.js \
        --replace-fail 'import PackageJSON from "../../../../package.json" with { type: "json" };' "" \
        --replace-fail '(PackageJSON.version);' '"${version}";'
    '';

    nativeBuildInputs = [
      nodejs
    ];

    buildPhase = ''
      runHook preBuild

      buildRoot=$PWD
      pushd ${webui-deps}
      find -type d -name node_modules -prune -print -exec cp -rT {} $buildRoot/{} \;
      popd

      chmod -R +w node_modules/@goauthentik
      rm -R node_modules/@goauthentik/api
      ln -sn ${client-ts} node_modules/@goauthentik/api

      pushd node_modules/.bin
      patchShebangs $(readlink rollup)
      patchShebangs $(readlink wireit)
      patchShebangs $(readlink lit-localize)
      popd

      npm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir $out
      cp -r dist $out/dist
      cp -r authentik $out/authentik
      runHook postInstall
    '';

    CHROMEDRIVER_FILEPATH = lib.getExe chromedriver;
    NODE_ENV = "production";
    NODE_OPTIONS = "--openssl-legacy-provider";

    npmInstallFlags = [
      "--include=dev"
      "--ignore-scripts"
    ];

    sourceRoot = "${src.name}/web";
  };

  python = python314.override {
    packageOverrides = final: prev: {
      ak-guardian = final.buildPythonPackage {
        inherit version src meta;
        pname = "ak-guardian";

        propagatedBuildInputs = with final; [
          django
          typing-extensions
        ];

        build-system = with final; [ hatchling ];
        pyproject = true;
        sourceRoot = "${src.name}/packages/ak-guardian";
      };

      authentik-django = final.buildPythonPackage {
        inherit version src meta;
        pname = "authentik-django";

        postPatch = ''
          substituteInPlace authentik/root/settings.py \
            --replace-fail 'Path(__file__).absolute().parent.parent.parent' "Path(\"$out\")"
          substituteInPlace authentik/lib/default.yml \
            --replace-fail '/blueprints' "$out/blueprints"
          substituteInPlace authentik/stages/email/utils.py \
            --replace-fail 'web/' '${webui}/'
          # allways allow file upload if the data directoy exists
          substituteInPlace authentik/admin/files/backends/file.py \
            --replace-fail "and (self._base_dir.is_mount() or (self._base_dir / self.usage.value).is_mount())" ""
        '';

        postInstall = ''
          mkdir -p $out/web $out/website
          cp -r lifecycle manage.py $out/${prev.python.sitePackages}/
          cp -r blueprints $out/
          cp -r ${webui}/dist ${webui}/authentik $out/web/
          cp -r ${website} $out/website/help
          ln -s $out/${prev.python.sitePackages}/authentik $out/authentik
          ln -s $out/${prev.python.sitePackages}/lifecycle $out/lifecycle
        '';

        build-system = [
          final.hatchling
        ];

        dependencies =
          with final;
          [
            ak-guardian
            argon2-cffi
            cachetools
            channels
            cryptography
            dacite
            deepmerge
            defusedxml
            django
            django-channels-postgres
            django-countries
            django-cte
            django-dramatiq-postgres
            django-filter
            django-model-utils
            django-pglock
            django-pgtrigger
            django-postgres-cache
            django-postgres-extra
            django-prometheus
            django-storages
            django-tenants
            djangoql
            djangorestframework
            docker
            drf-orjson-renderer
            drf-spectacular
            duo-client
            fido2
            geoip2
            geopy
            google-api-python-client
            gunicorn
            gssapi
            jsonpatch
            jwcrypto
            kubernetes
            ldap3
            lxml
            msgraph-sdk
            opencontainers
            packaging
            paramiko
            psycopg
            pydantic
            pydantic-scim
            pyjwt
            pyrad
            python-kadmin-rs
            pyyaml
            requests-oauthlib
            scim2-filter-parser
            sentry-sdk
            service-identity
            setproctitle
            structlog
            swagger-spec-validator
            twilio
            ua-parser
            unidecode
            urllib3
            uvicorn
            watchdog
            webauthn
            wsproto
            xmlsec
            zxcvbn
          ]
          ++ django-storages.optional-dependencies.s3
          ++ psycopg.optional-dependencies.c
          ++ psycopg.optional-dependencies.pool
          ++ uvicorn.optional-dependencies.standard;

        pyproject = true;
        pythonRelaxDeps = true;
        pythonRemoveDeps = [ "dumb-init" ];
      };

      # https://github.com/goauthentik/authentik/pull/16324
      django = final.django_5;

      django-channels-postgres = final.buildPythonPackage {
        inherit version src meta;
        pname = "django-channels-postgres";
        build-system = with final; [ hatchling ];

        dependencies =
          with final;
          [
            channels
            django
            django-pgtrigger
            msgpack
            psycopg
            structlog
          ]
          ++ psycopg.optional-dependencies.pool;

        pyproject = true;

        pythonRelaxDeps = [
          "structlog"
        ];

        sourceRoot = "${src.name}/packages/django-channels-postgres";
      };

      django-dramatiq-postgres = final.buildPythonPackage {
        inherit version src meta;
        pname = "django-dramatiq-postgres";
        build-system = with final; [ hatchling ];

        dependencies =
          with final;
          [
            cron-converter
            django
            django-pglock
            django-pgtrigger
            dramatiq
            structlog
            tenacity
          ]
          ++ dramatiq.optional-dependencies.watch;

        pyproject = true;

        pythonRelaxDeps = [
          "structlog"
        ];

        sourceRoot = "${src.name}/packages/django-dramatiq-postgres";
      };

      django-postgres-cache = final.buildPythonPackage {
        inherit version src meta;
        pname = "django-postgres-cache";

        propagatedBuildInputs = with final; [
          django
          django-postgres-extra
        ];

        build-system = with final; [ hatchling ];
        pyproject = true;
        sourceRoot = "${src.name}/packages/django-postgres-cache";
      };
    };

    self = python;
  };

  inherit (python.pkgs) authentik-django;

  worker = (rustPlatform.buildRustPackage.override { stdenv = clangStdenv; }) {
    inherit version src meta;
    pname = "authentik-worker";

    nativeBuildInputs = [
      cmake
      go
      perl
    ];

    buildInputs = [ python ];
    cargoHash = "sha256-KExlNyT9G3R5rnt99beT2pYrWxezMLhGw+Q9T1X2kj4=";

    env = {
      PYO3_PYTHON = lib.getExe python;
      RUSTFLAGS = "--cfg tokio_unstable";
    };

    # Upstream currently has no Rust tests in this package.
    doCheck = false;
    cargoBuildFlags = cargoPackageFlags;
  };

  # Provide a setup-hook to configure the Go source tree with up-to-date API bindings.
  # This is done to avoid the `vendorHash` depending on anything in the `client-go` build (e.g.
  # openapi-generator-cli version updates changing the produced content) and invalidating the hash.
  apiGoVendorHook =
    makeSetupHook
      {
        name = "authentik-api-go-vendor-hook";
      }
      (
        writeShellScript "authentik-api-go-vendor-hook" ''
          authentikApiGoVendorHook() {
            chmod -R +w packages/client-go
            rm -rf packages/client-go
            cp -r ${client-go} packages/client-go
            chmod -R +w packages/client-go

            echo "Finished authentikApiGoVendorHook"
          }

          # don't run for FOD, e.g. the `goModules` build
          if [ -z ''${outputHash-} ]; then
            postConfigureHooks+=(authentikApiGoVendorHook)
          fi
        ''
      );

  proxy = buildGoModule {
    inherit version src meta;
    pname = "authentik-proxy";

    postPatch = ''
      substituteInPlace internal/gounicorn/gounicorn.go \
        --replace-fail './lifecycle' "${authentik-django}/lifecycle"
      substituteInPlace web/static.go \
        --replace-fail './web' "${authentik-django}/web"
      substituteInPlace internal/web/static.go \
        --replace-fail './web' "${authentik-django}/web"
    '';

    nativeBuildInputs = [ apiGoVendorHook ];
    vendorHash = "sha256-EVDOZ4USaJoIBDB8mM4ZSBfsSc1d/NOm1Qv/hUJ+8f4=";
    env.CGO_ENABLED = 0;

    postInstall = ''
      mv $out/bin/server $out/bin/authentik-server
      ln -s authentik-server $out/bin/authentik
    '';

    # calculate the vendorHash without other dependencies, so it is only based on the `go.sum` file
    overrideModAttrs.postPatch = "";
    subPackages = [ "cmd/server" ];
  };

in
stdenvNoCC.mkDerivation {
  inherit src version;
  pname = "authentik";

  postPatch = ''
    rm Makefile
    patchShebangs lifecycle/ak
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r lifecycle/ak $out/bin/

    wrapProgram $out/bin/ak \
      --prefix PATH : ${
        lib.makeBinPath [
          worker
          proxy
          (python.withPackages (ps: [ ps.authentik-django ]))
        ]
      } \
      --set TMPDIR /dev/shm \
      --set PYTHONDONTWRITEBYTECODE 1 \
      --set PYTHONUNBUFFERED 1
    runHook postInstall
  '';

  passthru = {
    inherit proxy worker apiGoVendorHook;

    outposts = callPackages ./outposts.nix {
      inherit (proxy) vendorHash;
      inherit apiGoVendorHook;
    };
  };

  meta = meta // {
    mainProgram = "ak";
  };
}
