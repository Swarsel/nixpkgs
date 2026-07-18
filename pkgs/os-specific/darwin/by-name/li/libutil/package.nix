{
  copyfile,
  mkAppleDerivation,
}:

mkAppleDerivation {
  outputs = [
    "out"
    "dev"
    "man"
  ];

  buildInputs = [
    copyfile
  ];

  releaseName = "libutil";
  xcodeHash = "sha256-LwR9fmvcdJ/QYlOx+7ffhV4mKvjkwN3rX3+yHSCovKQ=";
  meta.description = "System utilities library";
}
