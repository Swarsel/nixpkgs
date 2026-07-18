{
  lib,
  fetchPypi,
  nixosTests,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "whoogle-search";
  version = "1.2.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-Vq8CLElP1P/Lcq98IZHgug7a4+sSSyEL2ih4Y5McAfg=";
    pname = "whoogle_search";
  };

  postInstall = ''
    # This creates renamed versions of the static files for cache busting,
    # without which whoogle will not run. If we don't do this here, whoogle
    # will attempt to create them on startup, which fails since the nix store
    # is read-only.
    python3 $out/${python3Packages.python.sitePackages}/app/__init__.py
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies =
    with python3Packages;
    [
      attrs
      beautifulsoup4
      brotli
      cachetools
      certifi
      cffi
      click
      cryptography
      cssutils
      defusedxml
      flask
      h11
      httpcore
      httpx
      idna
      itsdangerous
      jinja2
      markupsafe
      more-itertools
      packaging
      pluggy
      pycodestyle
      pycparser
      pyopenssl
      pyparsing
      pytest
      python-dateutil
      python-dotenv
      soupsieve
      stem
      validators
      waitress
      wcwidth
      werkzeug
    ]
    ++ httpx.optional-dependencies.http2
    ++ httpx.optional-dependencies.socks;

  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) whoogle-search;
  };

  meta = {
    description = "Self-hosted, ad-free, privacy-respecting metasearch engine";
    homepage = "https://github.com/benbusby/whoogle-search";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.SchweGELBin ];
    mainProgram = "whoogle-search";
  };
})
