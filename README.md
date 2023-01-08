# Ice language

multi-paradigm langauge that got em drippin like water

## building

right now the bootstrapping part is in work.

### bootstrapping
#### Requirements
1. NASM
2. Linux x64 any distribution including WSL (Windows Subsystem for Linux)

#### Steps
1. git clone libcube to the same directory as ice is in
2. go into ice/cube 
3. use the cuber build tool
```
python cuber.py run --lib <file>
```

or to do it in single steps
```bash
python cuber.py lib
python cuber.py build
```
and with run `ice/build/main <file>`

or
```
python cuber.py lib
python cuber.py run <file>
```

compilation and linking can be done manually as well, see `cuber.py` for reference
