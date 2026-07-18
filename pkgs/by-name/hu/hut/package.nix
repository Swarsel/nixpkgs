{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  scdoc,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "hut";
  version = "0.8.0";

  src = fetchFromSourcehut {
    owner = "~xenrox";
    repo = "hut";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dbFqc+zlUihf/gz4Oo3LtbOClDDDB/khlCbI9/UgD2E=";
  };

  nativeBuildInputs = [
    scdoc
  ];

  vendorHash = "sha256-7N+Zn7tzEG3dGeqNWmY98XUUKV7Y6g8wFZcQP9wea/8=";
  makeFlags = [ "PREFIX=$(out)" ];

  postBuild = ''
    make $makeFlags completions doc/hut.1
  '';

  preInstall = ''
    make $makeFlags install
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    # Recommended in 0.7.0 release notes https://git.sr.ht/~xenrox/hut/refs/v0.7.0
    "-X main.version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "CLI tool for Sourcehut / sr.ht";
    homepage = "https://sr.ht/~xenrox/hut/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "hut";
  };
})
