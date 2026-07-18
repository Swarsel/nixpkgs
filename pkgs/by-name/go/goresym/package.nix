{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  unzip,
}:

buildGoModule (finalAttrs: {
  pname = "goresym";
  version = "3.4";

  src = fetchFromGitHub {
    owner = "mandiant";
    repo = "goresym";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zDa+NxoC9mAaITWEHzejJykWVnoqnlLQtzbu0vs3NoQ=";
  };

  vendorHash = "sha256-pjkBrHhIqLmSzwi1dKS5+aJrrAAIzNATOt3LgLsMtx0=";
  doCheck = true;
  nativeCheckInputs = [ unzip ];

  preCheck = ''
    cd test
    unzip weirdbins.zip
    cd ..
  '';

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Go symbol recovery tool";
    homepage = "https://github.com/mandiant/GoReSym";
    changelog = "https://github.com/mandiant/GoReSym/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "GoReSym";
  };
})
