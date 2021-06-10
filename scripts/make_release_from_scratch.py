import requests, zipfile, io
import tempfile
from pathlib import Path
import shutil
import subprocess
import locate
import contextlib
import os

@contextlib.contextmanager
def cd(d):
    curdir= os.getcwd()
    try: 
        yield os.chdir(d)
    finally: os.chdir(curdir)

artifacts = locate.this_dir().joinpath("..", "artifacts")
icon = artifacts.joinpath("julia.ico")
dirname = input("Name of release: ")
ziphome = Path(tempfile.mktemp()).parent.joinpath("juliawin-releases")
sfx_conf = ziphome.joinpath("config.txt")
sfx_with_icon = ziphome.joinpath("sfx.exe")
jwinhome = ziphome.joinpath(dirname)
jwin7z = Path(f"{jwinhome}.7z")
jwinexe = Path(f"{jwinhome}.exe")
sevenzip = jwinhome.joinpath("packages","julia","libexec","7z.exe")
rcedit = locate.this_dir().joinpath("bootstrapped-rcedit.cmd")

"""
r = requests.get("https://codeload.github.com/heetbeet/juliawin/zip/refs/heads/main")
z = zipfile.ZipFile(io.BytesIO(r.content))
z.extractall(ziphome)

shutil.rmtree(jwinhome, ignore_errors=True)
shutil.move(ziphome.joinpath("juliawin-main"), jwinhome)

p = subprocess.call(f'"{jwinhome}/internals/scripts/bootstrap-juliawin-from-local-directory.bat"', 
                      shell=True)
"""

# Overwrite Git's installation settings
overwrite_config = {
    "Title": f'Title="{dirname}"',
    #"BeginPrompt": f'BeginPrompt="Extract {dirname}"',
    #"CancelPrompt": 'CancelPrompt="Do you want to cancel the Juliawin installation?"',
    #"ExtractPathText": f'ExtractPathText="Where do you want to install {dirname}?"',
    #"InstallPath": rf'InstallPath="%%S\\{dirname}"',
    "InstallPath": rf'InstallPath="%UserProfile%\\{dirname}"',
    "RunProgram": rf'''RunProgram="julia.exe -i --banner=no -e 'Base.banner(); println(); println(\"  Thanks for installing Juliawin!\"); println(\"  Welcome to the Julia REPL\"); println()'" '''
}

with artifacts.joinpath("7zsd_LZMA2_x64-from-7z-SFX-Builder.config").open("r") as f:
    config = f.read()
    config_juliawin = '\n'.join(
        [overwrite_config[key] if (key:=i.split("=")[0].strip().strip(";")) in overwrite_config else i for i in config.split("\n")]
    )

    with sfx_conf.open("w") as fw:
        fw.write(config_juliawin)

# Write new icon to the sfx binary header
shutil.copy(artifacts.joinpath("7zsd_LZMA2_x64-from-7z-SFX-Builder.sfx"), sfx_with_icon)
subprocess.call([rcedit, sfx_with_icon, "--set-icon", icon])
"""

# Don't add these folders to 7zip
nofolders = [
r"userdata\.julia\conda",
r"userdata\.julia\scratchspaces",
r"userdata\.julia\compiled",
r"userdata\.julia\registries"
]
nofoldersargs = [f"-xr!{i}" for i in nofolders]


# Blatently delete all pyc and __pycache__ directories
for i in list(Path(f"{jwinhome}/packages/conda").rglob("__pycache__")):
    shutil.rmtree(i, ignore_errors=True)

for i in list(Path(f"{jwinhome}/packages/conda").rglob("*.pyc")):
    i.unlink()


# Create 7zip archive of everything left over
with cd(jwinhome):
    subprocess.call([sevenzip, 'a', '-y', "-t7z", "-m0=lzma2:d1024m", "-mx=9", "-aoa", "-mfb=64", "-md=32m", "-ms=on", jwin7z, r".\*"]+nofoldersargs)

"""

# Copy everything nicely together
arg1 = sfx_with_icon.name
arg2 = sfx_conf.name
arg3 = jwin7z.name
arg4 = jwinexe.name
with cd(ziphome):
    subprocess.call(f'copy /b "{arg1}" + "{arg2}" + "{arg3}" "{arg4}"', shell=True)