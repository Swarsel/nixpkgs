{
  lib,
  fetchFromGitHub,
  callPackage,
  makeWrapper,
  nixosTests,
  python3,
}:
let
  python = python3;
in
python.pkgs.buildPythonPackage (finalAttrs: {
  pname = "pdfding";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "mrmn2";
    repo = "PdfDing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C1osj8V9+z3ahl4+zUtyI22GMtSgNLzfdGttL7gPDvY=";
  };

  # remove supervisor from dependencies
  postPatch = ''
    sed -i 's/supervisor.*$//' pyproject.toml
  '';

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  env.PDFDING_OUT_DIR = "${placeholder "out"}/${python.sitePackages}/pdfding";

  preBuild = ''
    # remove originals, copy from frontend
    rm -rf pdfding/static
    ln -s ${finalAttrs.passthru.frontend}/pdfding/static pdfding/static

    # staticfiles step requires prod configuration, remove dev.py
    mv pdfding/core/settings/dev.py dev.py.bak

    ${python.pythonOnBuildForHost.interpreter} pdfding/manage.py collectstatic

    # not needed, now we have staticfiles directory
    rm -rf pdfding/static

    # the following is from upstream's Dockerfile

    # remove django md5 hash from filenames of pdfjs as it will mess up the relative imports because of the whitenoise setup
    export PDFJS_PATH="pdfding/staticfiles/pdfjs"
    for file_name in $(find $PDFJS_PATH -type f -not -path "$PDFJS_PATH/web/images/*")
    do
      if [[ $file_name =~ "LICENSE" ]]; then
        new=$(echo "$file_name" | sed -E "s/LICENSE\.[a-zA-Z0-9]{12}/LICENSE/");
      else
        new=$(echo "$file_name" | sed -E "s/\.[a-zA-Z0-9]{12}\./\./");
      fi;
      mv -- "$file_name" "$new";
    done \
    && echo 'Successfully removed hash from pdfjs files'

    echo "VERSION = '${finalAttrs.version}'" > pdfding/core/settings/version.py;
  '';

  nativeCheckInputs = with python.pkgs; [
    pytestCheckHook
  ];

  checkInputs = with python.pkgs; [
    fido2
    pytest-django
  ];

  preCheck = ''
    # dev.py is required for tests, restore it
    mv dev.py.bak $PDFDING_OUT_DIR/core/settings/dev.py

    export DATA_DIR=$PWD/pdfding

    # tests should run in pdfding directory
    pushd pdfding
  '';

  postCheck = ''
    # come out of the pdfding directory
    popd

    unset DATA_DIR

    # remove dev.py
    rm $PDFDING_OUT_DIR/core/settings/dev.py
  '';

  postInstall = ''
    mkdir -p $out/bin

    makeWrapper "$PDFDING_OUT_DIR/manage.py" $out/bin/pdfding-manage \
      "''${makeWrapperArgs[@]}"

    makeWrapper ${lib.getExe python.pkgs.gunicorn} $out/bin/pdfding-start \
      --add-flags '--bind ''${HOST_IP:-127.0.0.1}:''${HOST_PORT:-8080} core.wsgi:application' \
      "''${makeWrapperArgs[@]}"
  '';

  __structuredAttrs = true;
  build-system = with python.pkgs; [ poetry-core ];

  dependencies =
    with python.pkgs;
    [
      django
      django-allauth
      django-cleanup
      django-htmx
      gunicorn
      huey
      markdown
      minio
      nh3
      oauthlib
      pillow
      psycopg2-binary
      pypdf
      pypdfium2
      python-magic
      qrcode
      rapidfuzz
      ruamel-yaml
      whitenoise

      # dependecies required for django collectstatic
      cryptography
      pyjwt
      requests
    ]
    ++ qrcode.optional-dependencies.pil
    ++ django-allauth.optional-dependencies.mfa
    ++ django-allauth.optional-dependencies.socialaccount;

  makeWrapperArgs = [
    "--set-default"
    "DATA_DIR"
    "/var/lib/pdfding"
    # allow for gunicorn processes to have access to Python packages
    "--prefix"
    "PYTHONPATH"
    ":"
    "${python.pkgs.makePythonPath finalAttrs.passthru.dependencies}:${finalAttrs.env.PDFDING_OUT_DIR}"
  ];

  optional-dependencies = {
    e2e = with python.pkgs; [
      pytest
      pytest-django
      pytest-playwright
      pytest-rerunfailures # required to retry some flaky e2e tests
    ];
  };

  pyproject = true;
  # from .github/workflows/tests.yaml
  pytestFlags = [ "--ignore=e2e" ];

  pythonImportsCheck = [
    "pdfding"
  ];

  pythonRelaxDeps = [
    "django"
    "gunicorn"
    "huey"
    "nh3"
    "psycopg2-binary"
    "pypdfium2"
  ];

  passthru = {
    inherit python;
    frontend = callPackage ./frontend.nix { };
    tests = nixosTests.pdfding;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Selfhosted PDF manager, viewer and editor offering a seamless user experience on multiple devices";
    homepage = "https://pdfding.com";
    changelog = "https://github.com/mrmn2/PdfDing/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "pdfding-manage";
    downloadPage = "https://github.com/mrmn2/PdfDing";
    teams = with lib.teams; [ ngi ];
  };
})
