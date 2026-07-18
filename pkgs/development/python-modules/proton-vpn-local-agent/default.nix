{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  pypaInstallHook,
  python,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "proton-vpn-local-agent";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "ProtonVPN";
    repo = "local-agent-rs";
    rev = version;
    hash = "sha256-y2FEfICwWa/GgaKkq8CR+lVDYIsk0HsuKuGUsUQZAFo=";
  };

  postPatch = ''
    substituteInPlace scripts/build_wheel.py \
      --replace-fail 'ARCH = "x86_64"' \
                     'ARCH = "${stdenv.hostPlatform.uname.processor}"' \
      --replace-fail 'LIB_PATH = get_lib_path("x86_64-unknown-linux-gnu")' \
                     'LIB_PATH = get_lib_path("${stdenv.hostPlatform.config}")'
  '';

  nativeBuildInputs = [
    cargo
    pypaInstallHook
    rustPlatform.cargoSetupHook
    rustPlatform.cargoBuildHook
  ];

  postBuild = ''
    ${python.interpreter} scripts/build_wheel.py
    mkdir -p ./dist
    cp ./target/*.whl ./dist
  '';

  nativeCheckInputs = [
    rustPlatform.cargoCheckHook
  ];

  cargoBuildType = "release";
  cargoCheckType = "release";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      sourceRoot
      ;

    hash = "sha256-y8I806dbC7n3eMFyrzGJokfVDwEGFdC7NgzSA0G8hkQ=";
  };

  pyproject = false;
  pythonImportsCheck = [ "proton.vpn.local_agent" ];
  sourceRoot = "${src.name}/python-proton-vpn-local-agent";
  withDistOutput = false;

  meta = {
    description = "Proton VPN local agent written in Rust with Python bindings";
    homepage = "https://github.com/ProtonVPN/local-agent-rs";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      anthonyroussel
      rapiteanu
    ];

    platforms = lib.platforms.linux;
  };
}
