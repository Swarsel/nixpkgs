{
  nixosTests,
  python3Packages,
  withCPU ? false,
  withRapidocr ? false,
  withTesserocr ? false,
  withUI ? false,
}:

(python3Packages.toPythonApplication (
  python3Packages.docling-serve.override {
    inherit
      withUI
      withTesserocr
      withRapidocr
      withCPU
      ;
  }
))
// {
  passthru.tests = {
    docling-serve = nixosTests.docling-serve;
  };
}
