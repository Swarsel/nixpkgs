{
  lib,
  buildPythonPackage,
  django,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "filebrowser-safe";
  version = "1.1.1";

  src = fetchPypi {
    inherit version;
    sha256 = "499c5dbd9e112dfc436cae7713b2fb664a59015021f6c9d131e3b7980aeb5c94";
    pname = "filebrowser_safe";
  };

  buildInputs = [ django ];
  # There is no test embedded
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Snapshot of django-filebrowser for the Mezzanine CMS";

    longDescription = ''
      filebrowser-safe was created to provide a snapshot of the
      FileBrowser asset manager for Django, to be referenced as a
      dependency for the Mezzanine CMS for Django.
    '';

    homepage = "https://github.com/stephenmcd/filebrowser-safe";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prikhi ];
    platforms = lib.platforms.unix;
    downloadPage = "https://pypi.org/project/filebrowser_safe/";
  };
}
