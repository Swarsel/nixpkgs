{
  lib,
  fetchFromGitHub,
  nixosTests,
  python3,
  unstableGitUpdater,
}:
let
  python = python3.override {
    packageOverrides = final: prev: { };
  };
in
python.pkgs.toPythonModule (
  python.pkgs.buildPythonApplication rec {
    pname = "searxng";
    version = "0-unstable-2026-07-08";

    src = fetchFromGitHub {
      owner = "searxng";
      repo = "searxng";
      rev = "1412926f5c80ffabc90719450578eb98fda9e161";
      hash = "sha256-w3nXXI2qVFqIsnaYgzsyjDdvQ0nQmQdVMClw2fG2Zmg=";
    };

    nativeBuildInputs = with python.pkgs; [ pythonRelaxDepsHook ];

    preBuild =
      let
        versionString = lib.concatStringsSep "." (
          map (lib.removePrefix "0") (builtins.tail (lib.splitString "-" (lib.removePrefix "0-" version)))
        );
        commitAbbrev = builtins.substring 0 8 src.rev;
      in
      ''
        export SEARX_DEBUG="true";

        cat > searx/version_frozen.py <<EOF
        VERSION_STRING="${versionString}+${commitAbbrev}"
        VERSION_TAG="${versionString}+${commitAbbrev}"
        DOCKER_TAG="${versionString}-${commitAbbrev}"
        GIT_URL="https://github.com/searxng/searxng"
        GIT_BRANCH="master"
        EOF
      '';

    # tests try to connect to network
    doCheck = false;

    postInstall = ''
      # Create a symlink for easier access to static data
      mkdir -p $out/share
      ln -s ../${python.sitePackages}/searx/static $out/share/

      # copy config schema for the limiter
      cp searx/limiter.toml $out/${python.sitePackages}/searx/limiter.toml
    '';

    build-system = with python.pkgs; [ setuptools ];

    dependencies =
      with python.pkgs;
      [
        babel
        certifi
        cloudscraper
        flask
        flask-babel
        httpx
        httpx-socks
        isodate
        jinja2
        lxml
        markdown-it-py
        msgspec
        pygments
        python-dateutil
        pyyaml
        sniffio
        typer
        typing-extensions
        valkey
        whitenoise
      ]
      ++ httpx.optional-dependencies.http2
      ++ httpx.optional-dependencies.socks
      ++ httpx-socks.optional-dependencies.asyncio;

    pyproject = true;
    pythonRelaxDeps = true;

    passthru = {
      tests = {
        searxng = nixosTests.searx;
      };

      updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };
    };

    meta = {
      description = "Fork of Searx, a privacy-respecting, hackable metasearch engine";
      homepage = "https://github.com/searxng/searxng";
      license = lib.licenses.agpl3Plus;

      maintainers = with lib.maintainers; [
        SuperSandro2000
        _999eagle
      ];

      mainProgram = "searxng-run";
    };
  }
)
