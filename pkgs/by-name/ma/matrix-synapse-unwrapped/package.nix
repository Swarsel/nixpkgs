{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  libiconv,
  nix-update-script,
  nixosTests,
  openssl,
  python3Packages,
  rustPlatform,
  rustc,
}:

python3Packages.buildPythonApplication rec {
  pname = "matrix-synapse";
  version = "1.156.0";

  src = fetchFromGitHub {
    owner = "element-hq";
    repo = "synapse";
    rev = "v${version}";
    hash = "sha256-x3EVmNPqcxtvt6ZaPsDCCcr7Z0LIO257s2gO3HCNmKA=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    openssl
  ]
  ++ (with python3Packages; [
    mock
    parameterized
  ])
  ++ lib.filter (pkg: !pkg.meta.broken) (lib.concatAttrValues optional-dependencies);

  checkPhase = ''
    runHook preCheck

    # remove src module, so tests use the installed module instead
    rm -rf ./synapse

    # high parallelisem makes test suite unstable
    # upstream uses 2 cores but 4 seems to be also stable
    # https://github.com/element-hq/synapse/blob/develop/.github/workflows/latest_deps.yml#L103
    if (( $NIX_BUILD_CORES > 4)); then
      NIX_BUILD_CORES=4
    fi

    PYTHONPATH=".:$PYTHONPATH" ${python3Packages.python.interpreter} -m twisted.trial -j $NIX_BUILD_CORES tests

    runHook postCheck
  '';

  build-system =
    with python3Packages;
    [
      poetry-core
      setuptools-rust
    ]
    ++ [
      rustPlatform.maturinBuildHook
    ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-N/JWRFz9OKcxigjp86AVVZGK63MdZmEzwHhBgBuWZcY=";
  };

  dependencies =
    with python3Packages;
    [
      attrs
      bcrypt
      bleach
      canonicaljson
      cryptography
      ijson
      immutabledict
      jinja2
      jsonschema
      matrix-common
      msgpack
      python-multipart
      netaddr
      packaging
      phonenumbers
      pillow
      prometheus-client
      pyasn1
      pyasn1-modules
      pydantic
      pymacaroons
      pyopenssl
      pyparsing
      pyrsistent
      pyyaml
      service-identity
      signedjson
      sortedcontainers
      treq
      twisted
      typing-extensions
      unpaddedbase64
    ]
    ++ twisted.optional-dependencies.tls;

  optional-dependencies = with python3Packages; {
    cache-memory = [
      pympler
    ];

    jwt = [
      authlib
    ];

    oidc = [
      authlib
    ];

    postgres =
      if isPyPy then
        [
          psycopg2cffi
        ]
      else
        [
          psycopg2
        ];

    redis = [
      hiredis
      txredisapi
    ];

    saml2 = [
      pysaml2
    ];

    sentry = [
      sentry-sdk
    ];

    systemd = [
      systemd-python
    ];

    url-preview = [
      lxml
    ];
  };

  pyproject = true;

  passthru = {
    inherit (python3Packages) python;
    plugins = python3Packages.callPackage ./plugins { };
    tests = { inherit (nixosTests) matrix-synapse; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Matrix reference homeserver";
    homepage = "https://matrix.org";
    changelog = "https://github.com/element-hq/synapse/releases/tag/v${version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ sumnerevans ];
    platforms = lib.platforms.linux;
    teams = [ lib.teams.matrix ];
  };
}
