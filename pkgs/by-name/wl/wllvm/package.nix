{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wllvm";
  version = "1.3.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-PgV6V18FyezIZpqMQEbyv98MaVM7h7T7/Kvg3yMMwzE=";
  };

  build-system = with python3Packages; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "wllvm.wllvm" ];

  meta = {
    description = "Wrapper script to build whole-program LLVM bitcode files";
    homepage = "https://github.com/travitch/whole-program-llvm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
    platforms = lib.platforms.all;
  };
})
