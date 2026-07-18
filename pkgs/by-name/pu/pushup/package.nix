{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "pushup";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "adhocteam";
    repo = "pushup";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9ENXeVON2/Bt8oXnyVw+Vl0bPVPP7iFSyhxwc091ZIs=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = null;
  # Pushup doesn't need CGO so disable it.
  env.CGO_ENABLED = 0;

  postInstall = ''
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} --prefix PATH : ${lib.makeBinPath [ go ]}
  '';

  # The Go compiler is a runtime dependency of Pushup.
  allowGoReference = true;

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = ".";

  meta = {
    description = "Web framework for Go";
    homepage = "https://pushup.adhoc.dev/";
    changelog = "https://github.com/adhocteam/pushup/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ paulsmith ];
    mainProgram = "pushup";
  };
})
