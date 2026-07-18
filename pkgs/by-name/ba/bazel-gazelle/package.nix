{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "bazel-gazelle";
  version = "0.51.3";

  src = fetchFromGitHub {
    owner = "bazel-contrib";
    repo = "bazel-gazelle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ooqk4xutkjXoy9Irikos/53+6Mhdh3+WmJF7vo3JVFw=";
  };

  vendorHash = null;
  doCheck = false;
  subPackages = [ "cmd/gazelle" ];

  meta = {
    description = ''
      Gazelle is a Bazel build file generator for Bazel projects. It natively
      supports Go and protobuf, and it may be extended to support new languages
      and custom rule sets.
    '';

    homepage = "https://github.com/bazel-contrib/bazel-gazelle";
    changelog = "https://github.com/bazel-contrib/bazel-gazelle/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kalbasit
      hythera
    ];

    mainProgram = "gazelle";
  };
})
