{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "credhub-cli";
  version = "2.9.54";

  src = fetchFromGitHub {
    owner = "cloudfoundry";
    repo = "credhub-cli";
    rev = finalAttrs.version;
    sha256 = "sha256-qp7Oj207uu2P/Jt9O5tZM0ra9fMx+DfuHPaKr5z+ef0=";
  };

  # these tests require network access that we're not going to give them
  postPatch = ''
    rm commands/api_test.go
    rm commands/socks5_test.go
  '';

  vendorHash = null;

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    ln -s $out/bin/credhub-cli $out/bin/credhub
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X code.cloudfoundry.org/credhub-cli/version.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Provides a command line interface to interact with CredHub servers";
    homepage = "https://github.com/cloudfoundry/credhub-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ris ];
  };
})
