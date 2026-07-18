{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  libiconv,
  nettle,
  pcsclite,
  pkg-config,
  pytestCheckHook,
  rustPlatform,
  tzdata,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "johnnycanencrypt";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "kushaldas";
    repo = "johnnycanencrypt";
    tag = "v${version}";
    hash = "sha256-qpta6D5aslUwuJ0+voYrHFIDetlsUB6PkScrtl/plVs=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ (with rustPlatform; [
    bindgenHook
    cargoSetupHook
    maturinBuildHook
  ]);

  buildInputs = [
    nettle
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pcsclite ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  nativeCheckInputs = [
    pytestCheckHook
    vcrpy
  ];

  preCheck = ''
    # import from $out
    rm -r johnnycanencrypt
  '';

  build-system = with rustPlatform; [
    bindgenHook
    cargoSetupHook
    maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-EzHbV/IBbGjoKFIbXSo2dlf+DU7ZXV16bVR93Sq0lis=";
  };

  dependencies = [
    httpx
    tzdata
  ];

  pyproject = true;
  pythonImportsCheck = [ "johnnycanencrypt" ];

  meta = {
    description = "Python module for OpenPGP written in Rust";
    homepage = "https://github.com/kushaldas/johnnycanencrypt";
    changelog = "https://github.com/kushaldas/johnnycanencrypt/blob/v${version}/changelog.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ _0x4A6F ];
  };
}
