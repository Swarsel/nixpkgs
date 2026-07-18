{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  xclip,
  xvfb-run,
}:

buildPythonPackage rec {
  pname = "pyclip";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "spyoungtech";
    repo = "pyclip";
    tag = "v${version}";
    hash = "sha256-0nOkNgT8XCwtXI9JZntkhoMspKQU602rTKBFajVKBoM=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace docs/README.md README.md
  '';

  # Tests require `pbcopy` and `pbpaste` on darwin, which are dependencies that are not
  # available in the build environemt.
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytest
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    xclip
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck
    ${lib.optionalString stdenv.hostPlatform.isLinux "xvfb-run -s '-screen 0 800x600x24'"} pytest tests
    runHook postCheck
  '';

  format = "setuptools";

  meta = {
    description = "Cross-platform clipboard utilities supporting both binary and text data";
    homepage = "https://github.com/spyoungtech/pyclip";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "pyclip";
  };
}
