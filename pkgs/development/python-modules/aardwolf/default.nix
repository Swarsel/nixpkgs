{
  lib,
  stdenv,
  fetchFromGitHub,
  arc4,
  asn1crypto,
  asn1tools,
  asyauth,
  asysocks,
  buildPythonPackage,
  cargo,
  colorama,
  iconv,
  pillow,
  pyperclip,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  tqdm,
  unicrypto,
}:

buildPythonPackage rec {
  pname = "aardwolf";
  version = "0.2.13";

  src = fetchFromGitHub {
    owner = "skelsec";
    repo = "aardwolf";
    tag = version;
    hash = "sha256-8QXPvfVeT3qadxTvt/LQX3XM5tGj6SpfOhP/9xcZHW4=";
  };

  patches = [ ./update-pyo3.patch ];

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  # Module doesn't have tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      patches
      ;

    hash = "sha256-n28jzS2+zbXsdR7rT0PBvcqNacuFMJKUug0mBYc4eFE=";
    patchFlags = [ "-p4" ]; # strip i/aardwolf/utils/rlers/ prefix
    sourceRoot = "${src.name}/aardwolf/utils/rlers";
  };

  cargoRoot = "aardwolf/utils/rlers";

  dependencies = [
    arc4
    asn1crypto
    asn1tools
    asyauth
    asysocks
    colorama
    pillow
    pyperclip
    tqdm
    unicrypto
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [ iconv ];

  pyproject = true;
  pythonImportsCheck = [ "aardwolf" ];

  meta = {
    description = "Asynchronous RDP protocol implementation";
    homepage = "https://github.com/skelsec/aardwolf";
    changelog = "https://github.com/skelsec/aardwolf/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ardpscan";
  };
}
