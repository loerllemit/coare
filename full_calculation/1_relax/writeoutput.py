"""Returns datafile of the relaxed lattice parameters, volume, and energy
Usage:  writeoutput.py [-o <filename>]

Options:
-o <filename>  enter the output file [default: datafile.txt]
"""

from os.path import split
from docopt import docopt
import csv   
import os.path

if __name__ == '__main__':
    arguments = docopt(__doc__,help=True)
    print(arguments)
    output = str(arguments['-o'])

with open('OSZICAR','r') as f:      # read OSZICAR file
    f = f.readlines()               
    for line in reversed(f):        # start reading in reverse order to get the latest(converged) values
        if 'E0=' in line:
            s = line               
            break
    E0 = float(s[s.find('E0=')+len('E0='):s.find('d E')])   # get E0 value

with open('OUTCAR','r') as f:       # read OUTCAR file
    f = f.readlines()
    # scan the volume
    for line in reversed(f):        # start reading in reverse order to get the latest(converged) values
        if 'volume of cell :' in line:
            s = line
            break
    V = float(s.partition(':')[-1]) # get the relaxed volume

    # scan the lattice parameters
    num = len(f)
    for line in reversed(f):        # start reading at the end of file
        num = num - 1
        if 'length of vectors' in line:
            break
    s = f[num+1].split()            # get the relaxed lattice parameters
    a = float(s[0])  
    b = float(s[1])  
    c = float(s[2])  

fields=[f'{a:.9f}',f'{b:.9f}',f'{c:.9f}',f'{V:.4f}',f'{E0:.7f}']

## check whether the file exists
if not os.path.isfile(output):
    with open(output,'w') as out:       # add header row
        out.writelines("# a b c V E0 \n")

    with open(output, 'a') as f:
        writer = csv.writer(f, delimiter='\t')
        writer.writerow(fields)
else:
    with open(output, 'a') as f:
        # writer = csv.DictWriter(f, delimiter='\t')
        writer = csv.writer(f, delimiter='\t')
        writer.writerow(fields)