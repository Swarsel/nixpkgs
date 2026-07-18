{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fonttools,
  gitUpdater,
  librecad,
  matplotlib,
  numpy,
  pillow,
  pymupdf,
  pyparsing,
  pyqt5,
  pyside6,
  pytestCheckHook,
  qt6,
  setuptools,
  typing-extensions,
  withGui ? false,
}:

buildPythonPackage rec {
  pname = "ezdxf";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "mozman";
    repo = "ezdxf";
    tag = "v${version}";
    hash = "sha256-v/xW/Tg3OgzwvSNy3cfkxzf6R33ZvW4VE8k7MB+rM+w=";
  };

  nativeBuildInputs = lib.optionals withGui [ qt6.wrapQtAppsHook ];
  nativeCheckInputs = [ pytestCheckHook ];
  checkInputs = [ pillow ];

  preCheck = ''
    ln -s "${librecad}/${
      if stdenv.hostPlatform.isDarwin then
        "Applications/LibreCAD.app/Contents/Resources"
      else
        "share/librecad"
    }/fonts" fonts/librecad
  '';

  preFixup = lib.optionalString withGui ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = [
    setuptools
    cython
  ];

  dependencies = [
    pyparsing
    typing-extensions
    numpy
    fonttools
  ]
  ++ lib.optionals withGui ([ qt6.qtbase ] ++ optional-dependencies.draw);

  dontWrapQtApps = true;

  optional-dependencies = {
    draw = [
      pyside6
      matplotlib
      pymupdf
      pillow
    ];

    draw5 = [
      pyqt5
      matplotlib
      pymupdf
      pillow
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "ezdxf"
    "ezdxf.addons"
  ];

  # The default updateScript of Python packages does not filter prerelease versions.
  passthru.updateScript = gitUpdater {
    allowedVersions = "^[0-9]+\\.[0-9]+\\.[0-9]+$";
    rev-prefix = "v";
  };

  meta = {
    description = "Python package to read and write DXF drawings (interface to the DXF file format)";
    homepage = "https://ezdxf.mozman.at/";
    changelog = "https://github.com/mozman/ezdxf/blob/${src.rev}/notes/pages/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ezdxf";
  };
}
