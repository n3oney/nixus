{
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage rec {
  pname = "android-unpinner";
  version = "unstable-2023-11-03";
  src = fetchFromGitHub {
    owner = "mitmproxy";
    repo = pname;
    rev = "f0822d02fe94d07f894ae2bd4f04340bade78d37";
    hash = "sha256-xPNNlQ2bF7DbBGGeIeFXcthI9KalV8uH8kyWkWlZ4WM=";
  };

  postFixup = ''
    cp -r $src/android_unpinner/vendor/build_tools/* $out/lib/python3.11/site-packages/android_unpinner/vendor/build_tools
    cp -r $src/android_unpinner/vendor/platform_tools/* $out/lib/python3.11/site-packages/android_unpinner/vendor/platform_tools
    # cp -r $src/android_unpinner/vendor/frida_tools/linux $out/lib/python3.11/site-packages/android_unpinner/vendor/frida_tools
  '';

  propagatedBuildInputs = with python3Packages; [rich-click];
}
