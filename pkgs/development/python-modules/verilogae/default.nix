{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  libxml2,
  llvmPackages,
  ncurses,
  nix-update-script,
  pkg-config,
  pythonAtLeast,
  rustPlatform,
  rustc,
  setuptools-rust,
  zlib,
}:

buildPythonPackage.override { stdenv = llvmPackages.stdenv; } rec {
  pname = "verilogae";
  version = "24.0.0mob-unstable-2025-07-21";

  src = fetchFromGitHub {
    owner = "OpenVAF";
    repo = "OpenVAF-Reloaded";
    rev = "d878f5519b1767b64c6ebeb4d67e29e7cd46e60b";
    hash = "sha256-TDE2Ewokhm2KSKe+sunUbV8KD3kaTSd5dB3CLCWGJ9U=";
  };

  postPatch = ''
    substituteInPlace openvaf/osdi/build.rs \
      --replace-fail "-fPIC" ""
  '';

  nativeBuildInputs = [
    setuptools-rust
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    cargo
    rustc
    pkg-config
    llvmPackages.llvm
  ];

  buildInputs = [
    libxml2.dev
    llvmPackages.libclang
    ncurses
    zlib
  ];

  cargoBuildType = "release";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-5SLrVL3h6+tptHv3GV7r8HUTrYQC9VdF68O2/Uct3xA=";
  };

  # segfault in pythonImportsCheckPhase
  disabled = pythonAtLeast "3.14";
  hardeningDisable = [ "pic" ];
  pyproject = true;
  pythonImportsCheck = [ "verilogae" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Verilog-A tool useful for compact model parameter extraction";
    homepage = "https://man.sr.ht/~dspom/openvaf_doc/verilogae/";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];

    maintainers = with lib.maintainers; [
      jasonodoom
      jleightcap
    ];

    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/OpenVAF/OpenVAF-Reloaded";
  };
}
