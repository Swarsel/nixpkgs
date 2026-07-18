{
  fetchzip,
  runCommand,
  testers,
  ...
}:

let
  url = "https://gist.github.com/glandium/01d54cefdb70561b5f6675e08f2990f2/archive/2f430f0c136a69b0886281d0c76708997d8878af.zip";
in
{
  hiddenDir = testers.invalidateFetcherByDrvHash fetchzip {
    sha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

    url = "file://${
      runCommand "hiddendir.tar" { } ''
        mkdir .foo
        tar -cf $out .foo
      ''
    }";
  };

  postFetch = testers.invalidateFetcherByDrvHash fetchzip {
    inherit url;
    postFetch = "touch $out/filee";
    sha256 = "sha256-7sAOzKa+9vYx5XyndHxeY2ffWAjOsgCkXC9anK6cuV0=";
  };

  simple = testers.invalidateFetcherByDrvHash fetchzip {
    inherit url;
    sha256 = "sha256-0ecwgL8qUavSj1+WkaxpmRBmu7cvj53V5eXQV71fddU=";
  };
}
