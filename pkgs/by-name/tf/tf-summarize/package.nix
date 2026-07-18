{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  tf-summarize,
}:

buildGoModule (finalAttrs: {
  pname = "tf-summarize";
  version = "0.3.20";

  src = fetchFromGitHub {
    owner = "dineshba";
    repo = "tf-summarize";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+u1akn3cEWoRza8IyJLh5GFJAxd2VVnusVKUFtcr0MY=";
  };

  vendorHash = "sha256-ncXJCOmpf6cuZd7JouAlyae/+pbjmlByrT3Z32EZEhc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "tf-summarize -v";
    package = tf-summarize;
  };

  meta = {
    description = "Command-line utility to print the summary of the terraform plan";
    homepage = "https://github.com/dineshba/tf-summarize";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pjrm ];
    mainProgram = "tf-summarize";
  };
})
