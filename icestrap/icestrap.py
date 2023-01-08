import subprocess as sp
import sys, os
import time


project_path = os.getcwd()
src_path = os.path.join(project_path, "src")
driplib_path = os.path.join(project_path, "../../driplib")
driplib_path = os.path.abspath(driplib_path)
print(driplib_path)

def maybe_mkdir():
    build_path = os.path.join(project_path, "build")
    if not os.path.exists(build_path):
        os.makedirs(build_path)


def debug_build_shared_driplib():
    maybe_mkdir()
    os.chdir(driplib_path)
    current = time.time()
    result = sp.run(["nasm", "-f", "elf64", "-g", "-F", "dwarf", "driplib.asm", "-o", "../ice/icestrap/build/driplib.o"])
    if result.returncode != 0:
        print("Error compiling driplib")
        sys.exit(1)
    else:
        print("Successful building driplib, took: ", round((time.time() - current) * 1000), "ms")
    
    os.chdir(project_path)
    current = time.time()
    result = sp.run(["ld", "-shared", "build/driplib.o", "-o", "build/driplib.so"])
    if result.returncode != 0:
        print("Error linking driplib")
        sys.exit(1)
    else:
        print("Successful linking libdrip, took: ", round((time.time() - current) * 1000), "ms")


def debug_build():
    maybe_mkdir()
    os.chdir(src_path)
    current = time.time()
    result = sp.run(["nasm", "-f", "elf64", "-g", "-F", "dwarf", "main.asm", "-o", "../build/main.o"])
    if result.returncode != 0:
        print("Error compiling assembly")
        sys.exit(1)
    else:
        print("Successful building Project, took: ", round((time.time() - current) * 1000), "ms")
    
    os.chdir(project_path)
    current = time.time()
    result = sp.run(["ld", '--dynamic-linker',"/lib/ld-linux-x86-64.so.2", "build/driplib.so", "build/main.o", "-o", "build/main"])
    if result.returncode != 0:
        print("Error linking output")
        sys.exit(1)
    else:
        print("Successful linking Project, took: ", round((time.time() - current) * 1000), "ms")



def debug_run(args: list[str]):
    args.insert(0, "./build/main")
    print("Executing Project")
    print("-----------------------------------")
    current = time.time()
    result = sp.run(args)
    print("Program terminated with code: ", result.returncode)
    print("run: ", round((time.time() - current) * 1000), "ms")


if len(sys.argv) > 1 and sys.argv[1] is not None:
    if sys.argv[1] == "build":
        debug_build()
    elif sys.argv[1] == "lib":
        debug_build_shared_driplib()
    elif sys.argv[1] == "run":
        args = []
        if sys.argv[2] == "--lib":
            debug_build_shared_driplib()
            args = sys.argv[3:].copy()
        else:
            args = sys.argv[2:].copy()
        
        debug_build()
        debug_run(args)
    elif sys.argv[1] == "clean":
        [os.remove(os.path.join("build", f)) for f in os.listdir("build")]
