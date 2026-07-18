{
  lib,
  fetchgit,
  installShellFiles,
  makeWrapper,
  python3Packages,
  extraHandlers ? [ ],
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ssh-import-id";
  version = "5.11";

  src = fetchgit {
    url = "https://git.launchpad.net/ssh-import-id";
    tag = finalAttrs.version;
    hash = "sha256-tYbaJGH59qyvjp4kwo3ZFVs0EaE0Lsd2CQ6iraFkAdI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "long_description_content_type='markdown'" "long_description_content_type='text/markdown'"
  '';

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  postInstall = ''
    installManPage $src/usr/share/man/man1/ssh-import-id.1
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies =
    with python3Packages;
    [
      requests
      distro
    ]
    ++ extraHandlers;

  # Handlers require main bin, main bin requires handlers
  makeWrapperArgs = [
    "--prefix"
    ":"
    "$out/bin"
  ];

  pyproject = true;

  meta = {
    description = "Retrieves an SSH public key and installs it locally";
    homepage = "https://launchpad.net/ssh-import-id";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      mkg20001
      viraptor
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ssh-import-id";
  };
})
