{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "kustomize_3";
  version = "3.10.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kustomize";
    rev = "kustomize/v${version}";
    sha256 = "sha256-ESIykbAKXdv8zM9be0zEJ71rBAzZby0aTg25NlCsIOM=";
  };

  vendorHash = "sha256-xLeetcmzvpILLLMhMx7oahWLxguFjG3qbYpeeWpFUlw=";
  doCheck = true;

  ldflags =
    let
      t = "sigs.k8s.io/kustomize/api/provenance";
    in
    [
      "-s -w"
      "-X ${t}.version=${version}"
      "-X ${t}.gitCommit=${rev}"
    ];

  # rev is the commit of the tag, mainly for kustomize version command output
  rev = "602ad8aa98e2e17f6c9119e027a09757e63c8bec";
  # avoid finding test and development commands
  sourceRoot = "${src.name}/kustomize";

  meta = {
    description = "Customization of kubernetes YAML configurations";

    longDescription = ''
      kustomize lets you customize raw, template-free YAML files for
      multiple purposes, leaving the original YAML untouched and usable
      as is.
    '';

    homepage = "https://github.com/kubernetes-sigs/kustomize";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      carlosdagos
      vdemeester
      zaninime
      Chili-Man
      saschagrunert
    ];

    mainProgram = "kustomize";
  };
}
