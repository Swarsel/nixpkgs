{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  click,
  click-default-group,
  docutils,
  # Dependencies
  ffmpeg,
  hatch-fancy-pypi-readme,
  # Build system
  hatchling,
  # Optional dependencies
  ipython,
  jinja2,
  lxml,
  manim,
  manimgl,
  numpy,
  pillow,
  pydantic,
  pydantic-extra-types,
  pyqt6,
  pyside6,
  python-pptx,
  qtpy,
  requests,
  rich,
  rtoml,
  setuptools,
  tqdm,
}:
buildPythonPackage rec {
  pname = "manim-slides";
  version = "5.6.0";

  src = fetchFromGitHub {
    owner = "jeertmans";
    repo = "manim-slides";
    tag = "v${version}";
    hash = "sha256-aAkKUa0oA2hGcd3PAda4pXPb9SoBVDfuHPplXk+6Vuo=";
  };

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    ffmpeg
    beautifulsoup4
    click
    click-default-group
    jinja2
    lxml
    numpy
    pillow
    pydantic
    pydantic-extra-types
    python-pptx
    qtpy
    requests
    rich
    rtoml
    tqdm
  ];

  optional-dependencies = lib.fix (self: {
    full = self.magic ++ self.manim ++ self.sphinx-directive;

    magic = self.manim ++ [
      ipython
    ];

    manim = [
      manim
    ];

    manimgl = [
      manimgl
      setuptools
    ];

    pyqt6 = [
      pyqt6
    ];

    pyqt6-full = self.full ++ self.pyqt6;

    pyside6 = [
      pyside6
    ];

    pyside6-full = self.full ++ self.pyside6;

    sphinx-directive = self.manim ++ [
      docutils
    ];
  });

  pyproject = true;

  pythonImportsCheck = [
    "manim_slides"
  ];

  pythonRelaxDeps = [
    "rtoml" # We only package version 0.10, but manim-slides depends on 0.11.
  ];

  pythonRemoveDeps = [
    "av" # It can use ffmpeg, which we already provide.
  ];

  meta = {
    description = "Tool for live presentations using manim";
    homepage = "https://github.com/jeertmans/manim-slides";
    changelog = "https://github.com/jeertmans/manim-slides/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bpeetz ];
    mainProgram = "manim-slides";
  };
}
