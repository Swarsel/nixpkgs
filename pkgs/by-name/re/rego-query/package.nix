{
  lib,
  stdenv,
  buildGoModule,
  fetchFromSourcehut,
  which,
}:

buildGoModule (finalAttrs: {
  pname = "rego-query";
  version = "0.0.14";

  src = fetchFromSourcehut {
    owner = "~charles";
    repo = "rq";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SZnbjPiXW6mw3abyL2475sNq3s5Jw12D9ZqbLfvaHN8=";
  };

  vendorHash = "sha256-fOq62QRx7BoE7RJielTnu1dtvkLy2FkzG59uuMQVLc4=";
  nativeCheckInputs = [ which ];

  postCheck = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    substituteInPlace smoketest/smoketest.sh \
      --replace-fail 'RQ="$(pwd)/../build/rq"' "RQ=$GOPATH/bin/rq"
    patchShebangs --build smoketest
    smoketest/smoketest.sh
  '';

  subPackages = [ "cmd/rq" ];

  meta = {
    description = "CLI tool for evaluating Rego Queries";
    homepage = "https://sr.ht/~charles/rq";
    changelog = "https://git.sr.ht/~charles/rq/tree/${finalAttrs.src.rev}/item/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ refi64 ];
    mainProgram = "rq";
  };
})
