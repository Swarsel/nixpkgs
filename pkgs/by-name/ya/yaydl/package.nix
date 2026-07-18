{
  lib,
  fetchFromGitHub,
  ffmpeg,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yaydl";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "dertuxmalwieder";
    repo = "yaydl";
    rev = "release-${finalAttrs.version}";
    sha256 = "sha256-X5D4kC5P5qHLSlTa9sQUAql1zK+Iut24224wvqihfAY=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-nt9S9KrHO8Vp75XZMQ0RAiALpdQ5LxI2Yaf3LRQD+fE=";

  postInstall = ''
    wrapProgram $out/bin/yaydl \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';

  meta = {
    description = "Yet another youtube down loader";
    homepage = "https://code.rosaelefanten.org/yaydl";
    license = lib.licenses.cddl;
    maintainers = [ ];
    mainProgram = "yaydl";
  };
})
