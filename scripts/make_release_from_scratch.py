"""
Install MinGW...
Yes, No, Reset questions [Y/N/R]? y

Install VSCode...
Yes, No, Reset questions [Y/N/R]? y

Install Juno...
Yes, No, Reset questions [Y/N/R]? y

Install Pluto...
Yes, No, Reset questions [Y/N/R]? y

Install PyCall...
Yes, No, Reset questions [Y/N/R]? y

Install Jupyter...
Yes, No, Reset questions [Y/N/R]? y
"""


import requests, zipfile, io
import tempfile
from pathlib import Path
import shutil
import subprocess


ziphome = Path(tempfile.mktemp()).parent.joinpath("juliawin-releases")
jwinhome = ziphome.joinpath("juliawin-min")

r = requests.get("https://codeload.github.com/heetbeet/juliawin/zip/refs/heads/main")
z = zipfile.ZipFile(io.BytesIO(r.content))
z.extractall(ziphome)


shutil.rmtree(jwinhome, ignore_errors=True)
shutil.move(ziphome.joinpath("juliawin-main"), jwinhome)


p = subprocess.call(f'"{jwinhome}/internals/scripts/bootstrap-juliawin-from-local-directory.bat"', 
                      shell=True)

