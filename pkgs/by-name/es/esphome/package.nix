{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  esptool,
  git,
  installShellFiles,
  nixosTests,
  platformio,
  python3Packages,
  versionCheckHook,
}:

let
  python = python3Packages.python.override {
    packageOverrides = self: super: {
      esphome-dashboard = self.callPackage ./dashboard.nix { };
      paho-mqtt = self.paho-mqtt_1;
    };

    self = python;
  };
in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "esphome";
  version = "2026.6.2";

  src = fetchFromGitHub {
    owner = "esphome";
    repo = "esphome";
    tag = finalAttrs.version;
    hash = "sha256-h7aMPSXmIUutCGMoZlE3Z1wX2xNxdmZsHfBllcFHBHc=";
  };

  patches = [
    # Use the esptool executable directly in the ESP32 post build script, that
    # gets executed by platformio. This is required, because platformio uses its
    # own python environment through `python -m esptool` and then fails to find
    # the esptool library.
    ./esp32-post-build-esptool-reference.patch
    # Call the platformio binary directly instead of `python -m
    # esphome.platformio_runner`, which tries to import platformio as a Python
    # module.
    ./platformio-binary-reference.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==82.0.1" "setuptools" \
      --replace-fail "wheel>=0.43,<0.48" "wheel"
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  # Remove esptool and platformio from requirements
  env.ESPHOME_USE_SUBPROCESS = "";

  nativeCheckInputs =
    with python.pkgs;
    [
      hypothesis
      mock
      pytest-asyncio
      pytest-cov-stub
      pytest-mock
      pytestCheckHook
    ]
    ++ [
      git
      versionCheckHook
    ];

  preCheck = ''
    export PATH=$PATH:$out/bin
  '';

  postInstall =
    let
      argcomplete = lib.getExe' python.pkgs.argcomplete "register-python-argcomplete";
    in
    ''
      installShellCompletion --cmd esphome \
        --bash <(${argcomplete} --shell bash esphome) \
        --zsh <(${argcomplete} --shell zsh esphome) \
        --fish <(${argcomplete} --shell fish esphome)
    '';

  doInstallCheck = true;
  # Needed for tests
  __darwinAllowLocalNetworking = true;

  build-system = with python.pkgs; [
    setuptools
  ];

  dependencies = with python.pkgs; [
    aioesphomeapi
    argcomplete
    bleak
    cairosvg
    click
    colorama
    cryptography
    esphome-dashboard
    esphome-glyphsets
    freetype-py
    icmplib
    jinja2
    paho-mqtt
    pillow
    platformio
    puremagic
    py7zr
    pyparsing
    pyserial
    pyyaml
    requests
    resvg-py
    ruamel-yaml
    smpclient
    tornado
    tzdata
    tzlocal
    voluptuous
    zeroconf
  ];

  disabledTestPaths = [
    # platformio builds; requires networking for dependency resolution
    "tests/integration"

    # tries to dynamically patch platformio module
    "tests/unit_tests/test_writer.py"
    "tests/unit_tests/test_espidf_component.py"
  ];

  disabledTests = [
    # tries to import platformio, which is wrapped in an fhsenv
    "test_clean_build"
    "test_clean_build_empty_cache_dir"
    "test_clean_all"
    "test_clean_all_partial_exists"
    # tries to use esptool, which is wrapped in an fhsenv
    "test_upload_using_esptool_passes_crystal_callback"
    "test_upload_using_esptool_path_conversion"
    "test_upload_using_esptool_skips_missing_extra_flash_images"
    "test_upload_using_esptool_with_file_path"
    # AssertionError: Expected 'run_external_command' to have been called once. Called 0 times.
    "test_run_platformio_cli_sets_environment_variables"
    # Expects a full git clone
    "test_clang_tidy_mode_full_scan"
    "test_clang_tidy_mode_targeted_scan"
    # Patched to run platformio without the esphome wrapper
    "test_run_platformio_cli_strips_win_long_path_prefix"
    "test_run_platformio_cli_does_not_set_pythonexepath_without_strip"
    "test_patch_file_downloader_recovers_against_real_server"
  ];

  makeWrapperArgs = [
    # platformio is used in esphome/platformio_api.py
    # esptool is used in esphome/__main__.py
    # git is used in esphome/git.py
    "--prefix PATH : ${
      lib.makeBinPath [
        platformio
        esptool
        git
      ]
    }"
    # The dashboard requires esphome to be importable
    # dependencies are added to show better error messages
    "--prefix PYTHONPATH : $out/${python.sitePackages}:${python.pkgs.makePythonPath finalAttrs.passthru.dependencies}"
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc ]}"
    "--set ESPHOME_USE_SUBPROCESS ''"
    # https://github.com/NixOS/nixpkgs/issues/362193
    "--set PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION 'python'"
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  pythonRemoveDeps = [
    "esptool"
    "platformio"
  ];

  passthru = {
    dashboard = python.pkgs.esphome-dashboard;
    tests = { inherit (nixosTests) esphome; };
    updateScript = callPackage ./update.nix { };
  };

  meta = {
    description = "Make creating custom firmwares for ESP32/ESP8266 super easy";
    homepage = "https://esphome.io/";
    changelog = "https://github.com/esphome/esphome/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      mit # The C++/runtime codebase of the ESPHome project (file extensions .c, .cpp, .h, .hpp, .tcc, .ino)
      gpl3Only # The python codebase and all other parts of this codebase
    ];

    maintainers = with lib.maintainers; [
      hexa
      picnoir
      thanegill
      karlbeecken
    ];

    mainProgram = "esphome";
  };
})
