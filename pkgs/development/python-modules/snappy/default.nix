{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # Python runtime dependencies
  cypari,
  cython,
  fetchpatch,
  fxrays,
  ipython,
  # non-Python runtime dependencies
  libGL,
  low-index,
  nix-update-script,
  packaging,
  pickleshare,
  plink,
  pypng,
  python,
  pyx,
  # tests
  runCommand,
  sage,
  # build-time dependencies
  setuptools,
  snappy-15-knots,
  snappy-manifolds,
  spherogram,
  sphinx-rtd-theme,
  # documentation
  sphinxHook,
  tkinter-gl,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "snappy";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "SnapPy";
    tag = "${version}_as_released";
    hash = "sha256-Pl4Nl0LXNvdtQ/EFVQy0QdUA/Fqoz2QAFWW5nz0bv78=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-OV3Qr5wO5UHNzVFTPTujIpp5ptel6gvAlcMgrJ8C0KY=";
      name = "no-copy-doc.patch";
      url = "https://github.com/3-manifolds/SnapPy/commit/c6aeeaaec7010a54e4ebdf2e8dad7b384c2ce8e5.patch";
    })
  ];

  postPatch =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace setup.py \
        --replace-fail "/usr/include/GL" "${lib.getDev libGL}/include/GL"
      substituteInPlace freedesktop/share/applications/snappy.desktop \
        --replace-fail "Exec=/usr/bin/env python3 -m snappy.app" "Exec=SnapPy"
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      substituteInPlace setup.py \
        --replace-fail "poss_roots = [ ''' ]" "poss_roots = [ '$SDKROOT' ]"
    '';

  nativeBuildInputs = [
    sphinxHook
    sphinx-rtd-theme
  ];

  buildInputs = [
    libGL
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -m snappy.test --skip-gui
    runHook postCheck
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/share
    cp -r freedesktop/share/{applications,icons} $out/share
  '';

  build-system = [
    setuptools
    cython
  ];

  dependencies = [
    cypari
    fxrays
    ipython
    low-index
    packaging
    pickleshare
    plink
    pypng
    pyx
    snappy-manifolds
    spherogram
    tkinter-gl
  ];

  optional-dependencies.snappy-15-knots = [ snappy-15-knots ];

  postInstallSphinx = ''
    ln -s ''${!outputDoc}/share/doc/$name/html $out/${python.sitePackages}/snappy/doc
  '';

  pyproject = true;
  pythonImportsCheck = [ "snappy" ];
  sphinxRoot = "doc_src";

  passthru.tests.sage =
    let
      sage' = sage.override {
        extraPythonPackages = ps: [ ps.snappy ];
        requireSageTests = false;
      };
    in
    runCommand "snappy-sage-tests"
      {
        nativeBuildInputs = [
          sage'
          writableTmpDirAsHomeHook
        ];
      }
      ''
        sage -python -m snappy.test --skip-gui
        touch $out
      '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "(.*)_as_released"
    ];
  };

  meta = {
    description = "Studying the topology and geometry of 3-manifolds, with a focus on hyperbolic structures";
    homepage = "https://snappy.computop.org";
    changelog = "https://snappy.computop.org/news.html";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "SnapPy";
  };
}
