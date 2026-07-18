{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDunePackage,
  ctypes,
  dune-configurator,
}:

(buildDunePackage.override { inherit stdenv; }) (finalAttrs: {
  pname = "eigen";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "owlbarn";
    repo = "eigen";
    tag = finalAttrs.version;
    hash = "sha256-bi+7T9qXByVPIy86lBMiJ2LTKCoNesrKZPa3VEDyINA=";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ ctypes ];

  meta = {
    description = "Minimal/incomplete Ocaml interface to Eigen3, mostly for Owl";
    homepage = "https://github.com/owlbarn/eigen";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.x86_64;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
