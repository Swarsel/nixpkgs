{ fetchDebianPatch, testers, ... }:

{
  libPackage = testers.invalidateFetcherByDrvHash fetchDebianPatch {
    pname = "libfile-pid-perl";
    version = "1.01";
    debianRevision = "2";
    hash = "sha256-VBsIYyCnjcZLYQ2Uq2MKPK3kF2wiMKvnq0m727DoavM=";
    patch = "missing-pidfile.patch";
  };

  simple = testers.invalidateFetcherByDrvHash fetchDebianPatch {
    pname = "pysimplesoap";
    version = "1.16.2";
    debianRevision = "5";
    hash = "sha256-xA8Wnrpr31H8wy3zHSNfezFNjUJt1HbSXn3qUMzeKc0=";
    patch = "Add-quotes-to-SOAPAction-header-in-SoapClient.patch";
  };
}
