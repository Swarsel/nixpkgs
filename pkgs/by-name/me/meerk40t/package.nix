{
  lib,
  fetchFromGitHub,
  gtk3,
  meerk40t-camera,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication rec {
  pname = "MeerK40t";
  version = "0.9.8000";

  src = fetchFromGitHub {
    owner = "meerk40t";
    repo = "MeerK40t";
    tag = version;
    hash = "sha256-KvXX4s+oKj7nksQyb4U827A2JQ1z6hwrBxBAg4RfW8s=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
  ]
  ++ (with python3Packages; [
    setuptools
  ]);

  nativeCheckInputs = with python3Packages; [
    unittestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
    )
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  # https://github.com/meerk40t/meerk40t/blob/main/setup.py
  dependencies =
    with python3Packages;
    [
      meerk40t-camera
      numpy
      pyserial
      pyusb
      setuptools
      wxpython
    ]
    ++ lib.concatAttrValues optional-dependencies;

  # prevent double wrapping
  dontWrapGApps = true;

  optional-dependencies = with python3Packages; {
    cam = [
      opencv4
    ];

    camhead = [
      opencv4
    ];

    dxf = [
      ezdxf
    ];

    gui = [
      wxpython
      pillow
      opencv4
      ezdxf
    ];
  };

  pyproject = true;

  meta = {
    description = "MeerK40t LaserCutter Software";
    homepage = "https://github.com/meerk40t/meerk40t";
    changelog = "https://github.com/meerk40t/meerk40t/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    mainProgram = "meerk40t";
  };
}
