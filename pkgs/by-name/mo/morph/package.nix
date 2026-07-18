{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  openssh,
}:

buildGoModule (finalAttrs: {
  pname = "morph";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "dbcdk";
    repo = "morph";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IqWtVklzSq334cGgLx/13l329g391oDW50MZWyO6l08=";
  };

  outputs = [
    "out"
    "lib"
  ];

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-zQlMtbXgrH83zrcIoOuFhb2tYCeQ1pz4UQUvRIsLMCE=";

  postInstall = ''
    mkdir -p $lib
    cp -v ./data/*.nix $lib
    wrapProgram $out/bin/morph --prefix PATH : ${lib.makeBinPath [ openssh ]};
  '';

  ldflags = [
    "-X main.version=${finalAttrs.version}"
    "-X main.assetRoot=${placeholder "lib"}"
  ];

  meta = {
    description = "NixOS host manager written in Golang";
    homepage = "https://github.com/dbcdk/morph";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      adamt
      johanot
    ];

    mainProgram = "morph";
  };
})
