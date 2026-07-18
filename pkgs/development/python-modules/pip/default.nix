{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  flit-core,
  # checks
  freezegun,
  git,
  installShellFiles,
  mock,
  # coupled downstream dependencies
  pip-tools,
  pretend,
  proxy-py,
  pytestCheckHook,
  pythonAtLeast,
  scripttest,
  # docs
  sphinx,
  sphinx-issues,
  tomli-w,
  virtualenv,
  werkzeug,
}:

let

  sphinxSupported = !sphinx.disabled;

  self = buildPythonPackage rec {
    pname = "pip";
    version = "25.3";

    src = fetchFromGitHub {
      owner = "pypa";
      repo = "pip";
      tag = version;
      hash = "sha256-aHV4j9OMLD6I6Fe6A04bE7xk6eS5CxeUEw4Psqj7xz0=";
    };

    outputs = [
      "out"
    ]
    ++ lib.optionals sphinxSupported [
      "man"
    ];

    postPatch = ''
      # Remove vendored Windows PE binaries
      # Note: These are unused but make the package unreproducible.
      find -type f -name '*.exe' -delete
    '';

    nativeBuildInputs = [
      flit-core
      installShellFiles
    ]
    ++ lib.optionals sphinxSupported [
      # docs
      sphinx
      sphinx-issues
    ];

    # pip uses a custom sphinx extension and unusual conf.py location, mimic the internal build rather than attempting
    # to fit sphinxHook see https://github.com/pypa/pip/blob/0778c1c153da7da457b56df55fb77cbba08dfb0c/noxfile.py#L129-L148
    postBuild = lib.optionalString sphinxSupported ''
      cd docs

      # remove references to sphinx extentions only required for html doc generation
      # sphinx.ext.intersphinx requires network connection or packaged object.inv files for python and pypug
      # sphinxcontrib.towncrier is not currently packaged
      for ext in sphinx.ext.intersphinx sphinx_copybutton sphinx_inline_tabs sphinxcontrib.towncrier myst_parser; do
        substituteInPlace html/conf.py --replace-fail '"'$ext'",' ""
      done

      PYTHONPATH=$src/src:$PYTHONPATH sphinx-build -v \
        -d build/doctrees/man \
        -c html \
        -d build/doctrees/man \
        -b man \
        man \
        build/man
      cd ..
    '';

    doCheck = false;

    nativeCheckInputs = [
      freezegun
      git
      mock
      scripttest
      virtualenv
      pretend
      pytestCheckHook
      proxy-py
      tomli-w
      werkzeug
    ];

    postInstall = ''
      installManPage docs/build/man/*

      installShellCompletion --cmd pip \
        --bash <($out/bin/pip completion --bash --no-cache-dir) \
        --fish <($out/bin/pip completion --fish --no-cache-dir) \
        --zsh <($out/bin/pip completion --zsh --no-cache-dir)
    '';

    pyproject = true;

    passthru.tests = {
      inherit pip-tools;
      pytest = self.overridePythonAttrs { doCheck = true; };
    };

    meta = {
      description = "PyPA recommended tool for installing Python packages";
      homepage = "https://pip.pypa.io/";
      changelog = "https://pip.pypa.io/en/stable/news/#v${lib.replaceStrings [ "." ] [ "-" ] version}";
      license = with lib.licenses; [ mit ];
      mainProgram = "pip";
    };
  };
in
self
