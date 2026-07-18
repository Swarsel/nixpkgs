{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  nix-update-script,
  nixosTests,
  python3,
  plugins ? _ps: [ ],
}:
let
  py = python3.override {
    packageOverrides = _final: prev: { django = prev.django_5; };
    self = py;
  };

  extraBuildInputs = plugins py.pkgs;
in
py.pkgs.buildPythonApplication rec {
  pname = "netbox";
  version = "4.5.9";

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = "netbox";
    tag = "v${version}";
    hash = "sha256-S8/2ZLYhYKBEpz3EGTyQPAPexX4se3MnmaH5aStVEj0=";
  };

  patches = [
    ./custom-static-root.patch
    # TODO: check if change is applied upstream before upgrading to NetBox v4.6
    (fetchpatch2 {
      hash = "sha256-6/wdd8wDVT4eqDKMNx8tmoPTDvw8OE7atf9nzg3LZzk=";
      name = "upgrade-django-tables2-v3.0.patch";
      url = "https://github.com/netbox-community/netbox/commit/d57346d9f0eef8126eafcd5033ea43864faeaf0d.patch";
    })
  ];

  nativeBuildInputs = with py.pkgs; [
    mkdocs-material
    mkdocs-material-extensions
    mkdocstrings
    mkdocstrings-python
  ];

  postBuild = ''
    PYTHONPATH=$PYTHONPATH:netbox/
    ${py.interpreter} -m mkdocs build
  '';

  installPhase = ''
    mkdir -p $out/opt/netbox
    cp -r . $out/opt/netbox
    chmod +x $out/opt/netbox/netbox/manage.py
    makeWrapper $out/opt/netbox/netbox/manage.py $out/bin/netbox \
      --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  dependencies =
    (
      with py.pkgs;
      [
        colorama
        django
        django-cors-headers
        django-debug-toolbar
        django-filter
        django-graphiql-debug-toolbar
        django-htmx
        django-mptt
        django-pglocks
        django-prometheus
        django-redis
        django-rq
        django-storages
        django-tables2
        django-taggit
        django-timezone-field
        djangorestframework
        drf-spectacular
        drf-spectacular-sidecar
        feedparser
        jinja2
        markdown
        netaddr
        nh3
        pillow
        psycopg
        pyyaml
        requests
        social-auth-core
        social-auth-app-django
        sorl-thumbnail
        strawberry-graphql
        strawberry-django
        svgwrite
        tablib

        # Optional dependencies, kept here for backward compatibility

        # for the S3 data source backend
        boto3
        # for Git data source backend
        dulwich
        # for error reporting
        sentry-sdk
      ]
      ++ psycopg.optional-dependencies.c
      ++ psycopg.optional-dependencies.pool
      ++ social-auth-core.optional-dependencies.openidconnect
    )
    ++ extraBuildInputs;

  pyproject = false;

  passthru = {
    inherit (py.pkgs) gunicorn;

    plugins = lib.recurseIntoAttrs (
      lib.makeExtensible (
        self:
        lib.packagesFromDirectoryRecursive {
          inherit (py.pkgs) callPackage;
          directory = ./plugins;
        }
      )
    );

    python = py;
    # PYTHONPATH of all dependencies used by the package
    pythonPath = py.pkgs.makePythonPath dependencies;

    tests = {
      inherit (nixosTests) netbox-upgrade;
      netbox = nixosTests.netbox_4_5;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "IP address management (IPAM) and data center infrastructure management (DCIM) tool";
    homepage = "https://github.com/netbox-community/netbox";
    changelog = "https://github.com/netbox-community/netbox/blob/${src.tag}/docs/release-notes/version-${lib.versions.majorMinor version}.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      minijackson
      transcaffeine
    ];

    mainProgram = "netbox";
  };
}
