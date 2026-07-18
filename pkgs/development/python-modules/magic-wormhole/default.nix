{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  attrs,
  autobahn,
  automat,
  buildPythonPackage,
  click,
  cryptography,
  gitUpdater,
  humanize,
  hypothesis,
  installShellFiles,
  iterable-io,
  magic-wormhole-mailbox-server,
  magic-wormhole-transit-relay,
  # tests
  net-tools,
  # optional-dependencies
  noiseprotocol,
  pynacl,
  pytest-twisted,
  pytestCheckHook,
  qrcode,
  # build-system
  setuptools,
  spake2,
  tqdm,
  twisted,
  txtorcon,
  unixtools,
  versioneer,
  zipstream-ng,
}:

buildPythonPackage (finalAttrs: {
  pname = "magic-wormhole";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "magic-wormhole";
    repo = "magic-wormhole";
    tag = finalAttrs.version;
    hash = "sha256-aY8dI5K2qroY+Nbc00R5XK0AjHpdnXFYWABgPqf8gQ8=";
  };

  postPatch =
    # enable tests by fixing the location of the wormhole binary
    ''
      substituteInPlace src/wormhole/test/test_cli.py --replace-fail \
        'locations = procutils.which("wormhole")' \
        'return "${placeholder "out"}/bin/wormhole"'
    ''
    # fix the location of the ifconfig binary
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      sed -i -e "s|'ifconfig'|'${net-tools}/bin/ifconfig'|" src/wormhole/ipaddrs.py
    '';

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = [
    hypothesis
    magic-wormhole-mailbox-server
    magic-wormhole-transit-relay
    pytestCheckHook
    pytest-twisted
  ]
  ++ finalAttrs.finalPackage.optional-dependencies.dilation
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ unixtools.locale ];

  postInstall = ''
    install -Dm644 docs/wormhole.1 $out/share/man/man1/wormhole.1

    # https://github.com/magic-wormhole/magic-wormhole/issues/619
    installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
      --bash wormhole_complete.bash \
      --fish wormhole_complete.fish \
      --zsh wormhole_complete.zsh
    rm $out/wormhole_complete.*
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    attrs
    autobahn
    automat
    click
    cryptography
    humanize
    iterable-io
    pynacl
    qrcode
    spake2
    tqdm
    twisted
    txtorcon
    zipstream-ng
  ]
  ++ autobahn.optional-dependencies.twisted
  ++ twisted.optional-dependencies.tls;

  optional-dependencies = {
    dilation = [ noiseprotocol ];
  };

  pyproject = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Securely transfer data between computers";
    homepage = "https://magic-wormhole.readthedocs.io/";
    changelog = "https://github.com/magic-wormhole/magic-wormhole/blob/${finalAttrs.src.rev}/NEWS.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mjoerg ];
    mainProgram = "wormhole";
  };
})
