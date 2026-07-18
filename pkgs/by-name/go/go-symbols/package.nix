{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "go-symbols";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "acroca";
    repo = "go-symbols";
    rev = "v${finalAttrs.version}";
    hash = "sha256-P2N4Hqrazu02CWOfAu7/KGlpjzjN65hkyWI1S5nh33s=";
  };

  patches = [
    # Migrate to Go modules
    (fetchpatch {
      hash = "sha256-9lndJhyN8eaovjQlfSRGP8lC4F+pAXUoR2AvYvhSx2U=";
      url = "https://github.com/acroca/go-symbols/commit/414c2283696b50fc5009055e5bc2590ce45f4400.patch";
    })
  ];

  vendorHash = "sha256-8unWnxTQzPY8tKBtss9qQG+ksWyheKxKRlg65F0vWWU=";

  meta = {
    description = "Utility for extracting a JSON representation of the package symbols from a go source tree";
    homepage = "https://github.com/acroca/go-symbols";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      vdemeester
    ];

    mainProgram = "go-symbols";
  };
})
