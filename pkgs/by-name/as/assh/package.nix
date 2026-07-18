{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  openssh,
  ps,
}:

buildGoModule (finalAttrs: {
  pname = "assh";
  version = "2.17.2";

  src = fetchFromGitHub {
    owner = "moul";
    repo = "assh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/w4RluA7py6d75S04czNsgHpmR5rmAUZx8OnZfu9oNg=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-EA39KqAN9SHPU362j6/j6okvT+eZb2R4unMA0bB+bVg=";
  nativeCheckInputs = lib.optionals stdenv.hostPlatform.isDarwin [ ps ];

  postInstall = ''
    wrapProgram "$out/bin/assh" \
      --prefix PATH : ${openssh}/bin
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/assh --help > /dev/null
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=moul.io/assh/v2/pkg/version.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Advanced SSH config - Regex, aliases, gateways, includes and dynamic hosts";
    homepage = "https://github.com/moul/assh";
    changelog = "https://github.com/moul/assh/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = with lib.platforms; linux ++ darwin;
  };
})
