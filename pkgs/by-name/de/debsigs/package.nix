{
  lib,
  fetchFromGitLab,
  binutils,
  perlPackages,
}:

perlPackages.buildPerlPackage rec {
  pname = "debsigs";
  version = "0.2.2";

  src = fetchFromGitLab {
    owner = "debsigs";
    repo = "debsigs";
    tag = "release/${version}";
    hash = "sha256-gCc5JmmdhTAUQqkMOK/0YmlCRD0JcpemCpqusYmpoKU=";
  };

  postPatch = ''
    substituteInPlace arf.pm \
      --replace-fail /usr/bin/ar ${binutils.bintools}/bin/ar
  '';

  sourceRoot = "${src.name}/perl";

  meta = {
    description = "Manipulate the cryptographic signatures stored inside a .deb file";
    homepage = "https://gitlab.com/debsigs/debsigs";
    changelog = "https://gitlab.com/debsigs/debsigs/-/tags/release/${version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ usertam ];
    mainProgram = "debsigs";
  };
}
