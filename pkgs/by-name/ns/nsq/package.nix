{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "nsq";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "nsqio";
    repo = "nsq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qoAp8yAc4lJmlnHHcZskRzkleZ3Q5Gu3Lhk9u1jMR4g=";
  };

  vendorHash = "sha256-/5nH7zHg8zxWFgtVzSnfp7RZGvPWiuGSEyhx9fE2Pvo=";
  excludedPackages = [ "bench" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Realtime distributed messaging platform";
    homepage = "https://nsq.io/";
    changelog = "https://github.com/nsqio/nsq/raw/v${finalAttrs.version}/ChangeLog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ blakesmith ];
  };
})
