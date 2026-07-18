{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  python3Packages,
}:

let
  python = python3Packages.python.override {
    packageOverrides = self: super: {
      wyoming = super.wyoming.overridePythonAttrs (oldAttrs: rec {
        version = "1.5.4";

        src = fetchFromGitHub {
          inherit (oldAttrs.src) owner repo;
          tag = version;
          hash = "sha256-gx9IbFkwR5fiFFAZTiQKzBbVBJ/RYz29sztgbvAEeRQ=";
        };
      });
    };

    self = python;
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "wyoming-satellite";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "wyoming-satellite";
    tag = "v${version}";
    hash = "sha256-sAtyyS60Fr6iFE3tTxEgAjhmX6O5WjWwb9rk+phzrtM=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-njJ8kIVGOpYK6bDeGow3OSNHxKQ9NsUKAR3+lEUH3GE=";
      # https://github.com/rhasspy/wyoming-satellite/pull/285
      url = "https://github.com/rhasspy/wyoming-satellite/commit/69465fd56011179cb92e7ce95da2e79fb06a83fb.patch";
    })
  ];

  nativeCheckInputs = with python3Packages; [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = with python.pkgs; [
    setuptools
  ];

  dependencies = with python.pkgs; [
    pyring-buffer
    wyoming
    zeroconf
  ];

  optional-dependencies = lib.fix (self: {
    all = self.silerovad ++ self.webrtc;

    respeaker = with python3Packages; [
      gpiozero
      spidev
    ];

    silerovad = with python3Packages; [
      pysilero-vad
    ];

    webrtc = with python3Packages; [
      webrtc-noise-gain
    ];
  });

  pyproject = true;

  pythonImportsCheck = [
    "wyoming_satellite"
  ];

  pythonRelaxDeps = [
    "pyring-buffer"
    "zeroconf"
  ];

  meta = {
    description = "Remote voice satellite using Wyoming protocol";
    homepage = "https://github.com/rhasspy/wyoming-satellite";
    changelog = "https://github.com/rhasspy/wyoming-satellite/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "wyoming-satellite";
  };
}
