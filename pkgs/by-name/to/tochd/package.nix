{
  lib,
  fetchFromGitHub,
  mame-tools,
  p7zip,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tochd";
  version = "0.13-unstable-2024-06-08";

  src = fetchFromGitHub {
    owner = "thingsiplay";
    repo = "tochd";
    rev = "eea871b51cd4962d23a6426194f6f524e864c0ac";
    hash = "sha256-lpDROCiXyfM4OdXBNGkEhD3T2c8aS8QyF7etHC5tQ8M=";
  };

  postInstall = ''
    mv $out/bin/tochd.py $out/bin/tochd
    install -Dm644 README.md -t $out/share/doc/tochd
    install -Dm644 LICENSE -t $out/share/licenses/tochd
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        mame-tools
        p7zip
      ]
    }"
  ];

  pyproject = true;

  meta = {
    description = "Convert game ISO and archives to CD/DVD CHD";
    homepage = "https://github.com/thingsiplay/tochd";
    changelog = "https://github.com/thingsiplay/tochd/blob/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ keenanweaver ];
    platforms = lib.platforms.unix;
    mainProgram = "tochd";
  };
})
