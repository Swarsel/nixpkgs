{
  lib,
  fetchFromGitHub,
  buildGoModule,
  jq,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "jiq";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "fiatjaf";
    repo = "jiq";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-txhttYngN+dofA3Yp3gZUZPRRZWGug9ysXq1Q0RP7ig=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-ZUmOhPGy+24AuxdeRVF0Vnu8zDGFrHoUlYiDdfIV5lc=";
  nativeCheckInputs = [ jq ];

  postInstall = ''
    wrapProgram $out/bin/jiq \
      --prefix PATH : ${lib.makeBinPath [ jq ]}
  '';

  meta = {
    description = "Interactive JSON query tool using jq expressions";
    homepage = "https://github.com/fiatjaf/jiq";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "jiq";
  };
})
