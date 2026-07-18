{
  lib,
  stdenv,
  fetchFromGitHub,
  acme,
  buildPythonPackage,
  configargparse,
  configobj,
  cryptography,
  dialog,
  distro,
  gnureadline,
  josepy,
  parsedatetime,
  pyrfc3339,
  pytest-xdist,
  pytestCheckHook,
  python,
  python-dateutil,
  runCommand,
  setuptools,
  writeShellScriptBin,
}:

buildPythonPackage (finalAttrs: {
  pname = "certbot";
  version = "5.6.0";

  src = fetchFromGitHub {
    owner = "certbot";
    repo = "certbot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-knaEk4bjC0cdnMiO4ENvaDm/i/3tn6ZOJPdyqJxLKOs=";
  };

  buildInputs = [
    dialog
    gnureadline
  ];

  nativeCheckInputs = [
    python-dateutil
    pytestCheckHook
    pytest-xdist
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (writeShellScriptBin "sw_vers" ''
      echo 'ProductVersion: 13.0'
    '')
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    configargparse
    acme
    configobj
    cryptography
    distro
    josepy
    parsedatetime
    pyrfc3339
  ];

  disabledTests = [
    # network access
    "test_lock_order"
  ];

  makeWrapperArgs = [ "--prefix PATH : ${dialog}/bin" ];
  pyproject = true;

  pytestFlags = [
    "-pno:cacheprovider"
    "-Wignore::DeprecationWarning"
  ];

  sourceRoot = "${finalAttrs.src.name}/certbot";

  # certbot.withPlugins has a similar calling convention as python*.withPackages
  # it gets invoked with a lambda, and invokes that lambda with the python package set matching certbot's:
  # certbot.withPlugins (cp: [ cp.certbot-dns-foo ])
  passthru.withPlugins =
    f:
    let
      pythonEnv = python.withPackages f;
    in
    runCommand "certbot-with-plugins-${finalAttrs.version}"
      {
        inherit (finalAttrs) pname version;
      }
      ''
        mkdir -p $out/bin
        cd $out/bin
        ln -s ${pythonEnv}/bin/certbot
      '';

  meta = {
    description = "ACME client that can obtain certs and extensibly update server configurations";
    homepage = "https://github.com/certbot/certbot";
    changelog = "https://github.com/certbot/certbot/blob/${finalAttrs.src.tag}/certbot/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ miniharinn ];
    platforms = lib.platforms.unix;
    mainProgram = "certbot";
  };
})
