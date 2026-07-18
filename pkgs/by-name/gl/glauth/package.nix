{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "glauth";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "glauth";
    repo = "glauth";
    tag = "GLAuth-v${finalAttrs.version}";
    hash = "sha256-9aymP2zhp2DaqqrC1tiTicqnzBvAHGdx4KHKXkYNNsg=";
  };

  vendorHash = "sha256-Lijy0LFy0PgWogdzYRNPFOkLym6Gf9qG4R+Bm91eYJg=";
  # Tests fail in the sandbox.
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  # Builds without go workspace fail with mysterious errors
  overrideModAttrs = _: {
    buildPhase = ''
      go work vendor -e -v
    '';
  };

  meta = {
    description = "Lightweight LDAP server for development, home use, or CI";
    homepage = "https://github.com/glauth/glauth";
    changelog = "https://github.com/glauth/glauth/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      bjornfor
      christoph-heiss
      xddxdd
    ];

    mainProgram = "glauth";
  };
})
