{
  lib,
  fetchFromGitHub,
  mkTclDerivation,
  ocl-icd,
  opencl-headers,
  vectcl,
}:

mkTclDerivation rec {
  pname = "tcl-opencl";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "ray2501";
    repo = "tcl-opencl";
    tag = version;
    hash = "sha256-nVqHWP6YbWbOAJsz0+4xYkOW3zWVmwhOI421Ak+8E3Q=";
  };

  buildInputs = [
    ocl-icd
    opencl-headers
  ];

  propagatedBuildInputs = [
    vectcl
  ];

  configureFlags = [
    "--with-vectcl=${vectcl}/lib/vectcl${vectcl.version}"
  ];

  meta = {
    description = "Tcl extension for OpenCL";
    homepage = "https://github.com/ray2501/tcl-opencl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
  };
}
