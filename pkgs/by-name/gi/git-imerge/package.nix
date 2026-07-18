{
  lib,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "git-imerge";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mhagger";
    repo = "git-imerge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-17xUe1N4igx5HOZBU+q7UQxkpHOFQozhR18hUYuPVuo=";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --bash completions/git-imerge
  '';

  build-system = [ python3Packages.setuptools ];
  pyproject = true;

  meta = {
    description = "Perform a merge between two branches incrementally";
    homepage = "https://github.com/mhagger/git-imerge";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "git-imerge";
  };
})
