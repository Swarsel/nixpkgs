{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch2,
  makeWrapper,
  tetex,
}:
buildGoModule (finalAttrs: {
  pname = "reporter";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "IzakMarais";
    repo = "reporter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lsraJwx56I2Gn8CePWUlQu1qdMp78P4xwPzLxetYUcw=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-CdI7/mkYG6t6H6ydGu7atwk18DpagdP7uzfrZVKKlhA=";
      name = "use-go-mod-and-remove-vendor-dirs";
      url = "https://github.com/IzakMarais/reporter/commit/e844b3f624e0da3a960f98cade427fe54f595504.patch";
    })
  ];

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-QlNOx2jm1LVz066t9khppf//T5c9z3YUrSOr6qzbUzI=";

  postInstall = ''
    wrapProgram $out/bin/grafana-reporter \
      --prefix PATH : ${lib.makeBinPath [ tetex ]}
  '';

  meta = {
    description = "PDF report generator from a Grafana dashboard";
    homepage = "https://github.com/IzakMarais/reporter";
    license = lib.licenses.mit;
    mainProgram = "grafana-reporter";
  };
})
