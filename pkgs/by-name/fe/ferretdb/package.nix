{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ferretdb";
  version = "1.24.0";

  src = fetchFromGitHub {
    owner = "FerretDB";
    repo = "FerretDB";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WMejspnk2PvJhvNGi4h+DF+fzipuOMcS1QWim5DnAhQ=";
  };

  postPatch = ''
    echo v${finalAttrs.version} > build/version/version.txt
    echo nixpkgs     > build/version/package.txt
  '';

  vendorHash = "sha256-GT6e9yd6LF6GFlGBWVAmcM6ysB/6cIGLbnM0hxfX5TE=";
  env.CGO_ENABLED = 0;
  # tests in cmd/ferretdb are not production relevant
  doCheck = false;
  # the binary panics if something required wasn't set during compilation
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  subPackages = [ "cmd/ferretdb" ];
  passthru.tests = nixosTests.ferretdb;

  meta = {
    description = "Truly Open Source MongoDB alternative";
    homepage = "https://www.ferretdb.com/";
    changelog = "https://github.com/FerretDB/FerretDB/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      noisersup
      julienmalka
    ];

    mainProgram = "ferretdb";
  };
})
