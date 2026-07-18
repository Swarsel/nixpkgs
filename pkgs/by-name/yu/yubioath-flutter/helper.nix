{
  buildPythonApplication,
  meta,
  mss,
  pillow,
  poetry-core,
  src,
  version,
  yubikey-manager,
  zxing-cpp,
}:

buildPythonApplication {
  inherit src version meta;
  pname = "yubioath-flutter-helper";

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "authenticator-helper" "yubioath-flutter-helper" \
      --replace "0.1.0" "${version}"
  '';

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    yubikey-manager
    mss
    zxing-cpp
    pillow
  ];

  postInstall = ''
    install -Dm 0755 authenticator-helper.py $out/bin/authenticator-helper
    install -d $out/libexec/helper
    ln -fs $out/bin/authenticator-helper $out/libexec/helper/authenticator-helper
  '';

  pyproject = true;
  pythonRelaxDeps = true;
  sourceRoot = "${src.name}/helper";
}
