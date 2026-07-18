{
  lib,
  stdenv,
  fetchFromGitHub,
  bcrypt,
  buildPythonPackage,
  callPackage,
  certifi,
  cffi,
  fetchpatch,
  isPyPy,
  libiconv,
  openssl,
  pkg-config,
  pretend,
  pytest-xdist,
  pytestCheckHook,
  rustPlatform,
  setuptools,
  cryptography-vectors ? (callPackage ./vectors.nix { }),
}:

buildPythonPackage rec {
  pname = "cryptography";
  version = "49.0.0";

  src = fetchFromGitHub {
    owner = "pyca";
    repo = "cryptography";
    tag = version;
    hash = "sha256-yHUIGauFZYnjcoROvocT1UqQ0B8ZuVTaJ0ZAfri6T1E=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-06Z+sk2JTJ50CCnPf2vXyPL5BZeI98oc43LpccenzNg=";
      # Add test marks where malloc failure is expected on systems with overcommit enabled
      name = "malloc-overcommit-mark.patch";
      url = "https://github.com/pyca/cryptography/commit/2efeba9cc67809b67e659bea8eaea680df2135e8.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--benchmark-disable" ""
  '';

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  nativeCheckInputs = [
    certifi
    cryptography-vectors
    pretend
    pytestCheckHook
    pytest-xdist
  ]
  ++ optional-dependencies.ssh;

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    pkg-config
    setuptools
  ]
  ++ lib.optionals (!isPyPy) [ cffi ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-yMCBu/RGRcEQST8tEWCNgVvlQsp2KamOqt60qvOYdt8=";
  };

  dependencies = lib.optionals (!isPyPy) [ cffi ];

  disabledTestPaths = [
    # save compute time by not running benchmarks
    "tests/bench"
  ];

  optional-dependencies.ssh = [ bcrypt ];
  pyproject = true;
  pytestFlags = [ "--disable-pytest-warnings" ];

  passthru = {
    vectors = cryptography-vectors;
  };

  meta = {
    description = "Package which provides cryptographic recipes and primitives";

    longDescription = ''
      Cryptography includes both high level recipes and low level interfaces to
      common cryptographic algorithms such as symmetric ciphers, message
      digests, and key derivation functions.
    '';

    homepage = "https://github.com/pyca/cryptography";
    changelog = "https://cryptography.io/en/latest/changelog/#v" + lib.replaceString "." "-" version;

    license = with lib.licenses; [
      asl20
      bsd3
      psfl
    ];

    maintainers = with lib.maintainers; [ mdaniels5757 ];
  };
}
