{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  mew,
  react,
}:

buildDunePackage (finalAttrs: {
  pname = "mew_vi";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "kandu";
    repo = "mew_vi";
    tag = finalAttrs.version;
    hash = "sha256-KI8yZGCYvKN59krpxBLBVNLZKoe1cGCoVr9MIZBbMFI=";
  };

  propagatedBuildInputs = [
    mew
    react
  ];

  meta = {
    description = "Modal Editing Witch, VI interpreter";
    homepage = "https://github.com/kandu/mew_vi";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
