{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "charge-lnd";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "accumulator";
    repo = "charge-lnd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rACpIHVVq4q3iOEJgJbslCzEcP3qYrc3rZQ85YJfzoQ=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  propagatedBuildInputs = with python3Packages; [
    aiorpcx
    colorama
    googleapis-common-protos
    grpcio
    protobuf
    six
    termcolor
  ];

  env = {
    PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
  };

  postInstall = ''
    install README.md -Dt $out/share/doc/charge-lnd

    wrapProgram $out/bin/charge-lnd \
      --set PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION "python"
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/charge-lnd --help > /dev/null
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Simple policy-based fee manager for lightning network daemon";
    homepage = "https://github.com/accumulator/charge-lnd";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      mmilata
      mariaa144
    ];

    mainProgram = "charge-lnd";
  };
})
