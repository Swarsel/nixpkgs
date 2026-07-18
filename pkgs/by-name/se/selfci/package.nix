{
  lib,
  fetchFromRadicle,
  git,
  makeWrapper,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "selfci";
  version = "0.5.0";

  src = fetchFromRadicle {
    repo = "z2tDzYbAXxTQEKTGFVwiJPajkbeDU";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6Q9Enq02uJbcpr7pohh+uiGNus++TkUxCvO4KwX8fkk=";
    seed = "radicle.dpc.pw";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  cargoHash = "sha256-zgDbf0po0YJCRo4GyVce2YSzoFjBTWsKX86/aH3uZlY=";
  doCheck = false;

  postInstall = ''
    wrapProgram "$out"/bin/selfci \
    --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimalistic local-first Unix-philosophy-abiding CI";
    homepage = "https://radicle.network/nodes/radicle.dpc.pw/rad%3Az2tDzYbAXxTQEKTGFVwiJPajkbeDU";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      dvn0
    ];

    mainProgram = "selfci";
  };
})
