{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  nginx,
  python3,
}:

let
  python = python3.override {
    packageOverrides = self: super: {
      pyparsing = super.pyparsing.overridePythonAttrs rec {
        version = "2.4.7";

        src = fetchFromGitHub {
          owner = "pyparsing";
          repo = "pyparsing";
          rev = "pyparsing_${version}";
          sha256 = "14pfy80q2flgzjcx8jkracvnxxnr59kjzp3kdm5nh232gk1v6g6h";
        };

        nativeBuildInputs = [ super.setuptools ];
      };
    };

    self = python;
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "gixy";
  version = "0.1.21";

  # fetching from GitHub because the PyPi source is missing the tests
  src = fetchFromGitHub {
    owner = "yandex";
    repo = "gixy";
    rev = "v${version}";
    sha256 = "sha256-Ak2UTP0gDKoac/rR2h1XCUKld1b41O466ogZNQ1yQN0=";
  };

  patches = [
    # Migrate tests to pytest
    # https://github.com/yandex/gixy/pull/146
    (fetchpatch2 {
      hash = "sha256-qIKKTC65ewZqiKiNLcaglKEdFh0SBZMJgIvY41/7WUc=";
      name = "migrate-tests-to-pytest.patch";
      url = "https://github.com/yandex/gixy/compare/6f68624a7540ee51316651bda656894dc14c9a3e...b1c6899b3733b619c244368f0121a01be028e8c2.diff?full_index=1";
    })
    ./python3.13-compat.patch
  ];

  nativeCheckInputs = [ python.pkgs.pytestCheckHook ];
  build-system = [ python.pkgs.setuptools ];

  dependencies = with python.pkgs; [
    cached-property
    configargparse
    pyparsing
    jinja2
    six
  ];

  pyproject = true;
  pythonRemoveDeps = [ "argparse" ];

  passthru = {
    inherit (nginx.passthru) tests;
  };

  meta = {
    description = "Nginx configuration static analyzer";

    longDescription = ''
      Gixy is a tool to analyze Nginx configuration.
      The main goal of Gixy is to prevent security misconfiguration and automate flaw detection.
    '';

    homepage = "https://github.com/yandex/gixy";
    license = lib.licenses.mpl20;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "gixy";
  };
}
