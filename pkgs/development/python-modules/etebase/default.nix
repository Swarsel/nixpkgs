{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  fetchpatch,
  msgpack,
  nixosTests,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  rustfmt,
  setuptools-rust,
}:

buildPythonPackage rec {
  pname = "etebase";
  version = "0.31.7";

  src = fetchFromGitHub {
    owner = "etesync";
    repo = "etebase-py";
    rev = "v${version}";
    hash = "sha256-ZNUUp/0fGJxL/Rt8sAZ864rg8uCcNybIYSk4POt0vqg=";
  };

  # https://github.com/etesync/etebase-py/pull/54
  patches = [
    # fix python 3.12 build
    (fetchpatch {
      hash = "sha256-0BDUTztiC4MiwwNEDFtfc5ruc69Qk+svepQZRixNJgA=";
      url = "https://github.com/etesync/etebase-py/commit/898eb3aca1d4eb30d4aeae15e35d0bc45dd7b3c8.patch";
    })
    # replace flapigen git dependency in Cargo.lock
    (fetchpatch {
      hash = "sha256-8EH8Sc3UnmuCrSwDf3+as218HiG2Ed3r+FCMrUi5YrI=";
      url = "https://github.com/etesync/etebase-py/commit/7e9e4244a144dd46383d8be950d3df79e28eb069.patch";
    })
  ];

  postPatch = ''
    # Use system OpenSSL, which gets security updates.
    substituteInPlace Cargo.toml \
      --replace ', features = ["vendored"]' ""
  '';

  nativeBuildInputs = [
    pkg-config
    rustfmt
    setuptools-rust
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [ openssl ];
  propagatedBuildInputs = [ msgpack ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    inherit patches;
    hash = "sha256-tFOZJFrNge3N+ux2Hp4Mlm9K/AXYxuuBzEQdQYGGDjg=";
  };

  pyproject = true;
  pythonImportsCheck = [ "etebase" ];

  passthru.tests = {
    inherit (nixosTests) etebase-server;
  };

  meta = {
    description = "Python client library for Etebase";
    homepage = "https://www.etebase.com/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
