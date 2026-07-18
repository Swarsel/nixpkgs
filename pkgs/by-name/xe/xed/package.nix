{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  llvmPackages,
  nix-update-script,
  python3Packages,
}:

let
  # mbuild is a custom build system used only to build xed
  mbuild = python3Packages.buildPythonPackage rec {
    pname = "mbuild";
    version = "2024.11.04";

    src = fetchFromGitHub {
      owner = "intelxed";
      repo = "mbuild";
      tag = "v${version}";
      hash = "sha256-iQVykBG3tEPxI1HmqBkvO1q+K8vi64qBfVC63/rcTOk=";
    };

    build-system = with python3Packages; [ setuptools ];
    pyproject = true;

    meta = {
      description = "Python-based build system used for building XED";
      homepage = "https://github.com/intelxed/mbuild";
      license = lib.licenses.asl20;
    };
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "xed";
  version = "2025.12.14";

  src = fetchFromGitHub {
    owner = "intelxed";
    repo = "xed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-af0PYWMFLCrDyX7lkyhH1t5obYm9VTIyMtV2BwHhIBo=";
  };

  postPatch = ''
    patchShebangs mfile.py
  '';

  nativeBuildInputs = [
    mbuild
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.bintools ];

  buildPhase = ''
    runHook preBuild

    # this will build, test and install
    ./mfile.py test --prefix $out

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    ./mfile.py examples

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    installBin obj/wkit/examples/obj/xed

    runHook postInstall
  '';

  passthru = {
    inherit mbuild;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "mbuild"
      ];
    };
  };

  meta = {
    description = "Intel X86 Encoder Decoder (Intel XED)";
    homepage = "https://intelxed.github.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arturcygan ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isAarch64;
  };
})
