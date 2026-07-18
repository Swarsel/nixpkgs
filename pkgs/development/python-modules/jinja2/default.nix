{
  lib,
  stdenv,
  babel,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  markupsafe,
  pallets-sphinx-themes,
  pytestCheckHook,
  python,
  # Reverse dependency
  sage,
  sphinx-issues,
  sphinxHook,
  sphinxcontrib-log-cabinet,
}:

buildPythonPackage rec {
  pname = "jinja2";
  version = "3.1.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ATf7BZkNNfEnWlh+mu5tVtqCH8g0kaD7g4GDvkP2bW0=";
  };

  postPatch = ''
    # Do not test with trio, it increases jinja2's dependency closure by a lot
    # and everyone consuming these dependencies cannot rely on sphinxHook,
    # because sphinx itself depends on jinja2.
    substituteInPlace tests/test_async{,_filters}.py \
      --replace-fail "import trio" "" \
      --replace-fail ", trio.run" "" \
      --replace-fail ", \"trio\"" ""
  '';

  # Multiple tests run out of stack space on 32bit systems with python2.
  # See https://github.com/pallets/jinja/issues/1158
  doCheck = !stdenv.hostPlatform.is32bit;
  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.i18n;
  build-system = [ flit-core ];
  dependencies = [ markupsafe ];

  optional-dependencies = {
    i18n = [ babel ];
  };

  pyproject = true;

  passthru.doc = stdenv.mkDerivation {
    inherit src version;
    inherit (python) pythonVersion;
    inherit meta;
    # Forge look and feel of multi-output derivation as best as we can.
    #
    # Using 'outputs = [ "doc" ];' breaks a lot of assumptions.
    pname = "${pname}-doc";

    patches = [
      # Fix import of "sphinxcontrib-log-cabinet"
      ./patches/import-order.patch
    ];

    nativeBuildInputs = [
      sphinxHook
      sphinxcontrib-log-cabinet
      pallets-sphinx-themes
      sphinx-issues
    ];

    postInstallSphinx = ''
      mv $out/share/doc/* $out/share/doc/python$pythonVersion-$pname-$version
    '';
  };

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Very fast and expressive template engine";

    longDescription = ''
      Jinja is a fast, expressive, extensible templating engine. Special
      placeholders in the template allow writing code similar to Python
      syntax. Then the template is passed data to render the final document.
    '';

    homepage = "https://jinja.palletsprojects.com";
    changelog = "https://github.com/pallets/jinja/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pierron ];
    downloadPage = "https://github.com/pallets/jinja";
  };
}
