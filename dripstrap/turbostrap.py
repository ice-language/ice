import subprocess as sp
import sys, os
import time


project_path = os.getcwd()
src_path = os.path.join(project_path, "src")

def debug_build():
    os.chdir(src_path)
    current = time.time()
    result = sp.run(["nasm", "-f", "elf64", "main.asm", "-o", "../build/main.o"])
    if result.returncode != 0:
        print("Error compiling assembly")
        sys.exit(1)
    else:
        print("Successful building Project, took: ", round((time.time() - current) * 1000), "ms")
    
    os.chdir(project_path)
    current = time.time()
    result = sp.run(["ld", "build/main.o", "-o", "build/main"])
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
    elif sys.argv[1] == "run":
        args = sys.argv[1:].copy()
        debug_build()
        debug_run(args)
    elif sys.argv[1] == "clean":
        [os.remove(os.path.join("build", f)) for f in os.listdir("build")]
