"""Returns datafile that consists of lattice parameters, volume, and energy
Usage: getE.py (-a <lat_a>) (-c  <lat_c>) [-o <filename>]

Options:
-a <lat_a>     The lattice parameter a
-c <lat_c>     The lattice parameter c
-o <filename>  enter the output file [default: datafile.txt]
"""

from docopt import docopt
import csv   
import os.path

if __name__ == '__main__':
    arguments = docopt(__doc__,help=True)
    # print(arguments)
    a = float(arguments['-a'])
    c = float(arguments['-c'])
    output = str(arguments['-o'])

with open('OSZICAR','r') as f:      # read OSZICAR file
    f = f.readlines()               
    E_list = []
    for num, line in enumerate(f, 0):
        if 'E0=' in line:
            E_list.append(num)      # get the line numbers of E0 occurences
    s = f[E_list[-1]]               # select the last (converged) E0 value
    E0 = float(s[s.find('E0=')+len('E0='):s.find('d E')])

with open('OUTCAR','r') as f:       # read OUTCAR file
    for line in f:
        if 'volume of cell :' in line:
            s = line
            break
    V = float(s.partition(':')[-1]) # get the volume

# print(V,E0)


fields=[f'{a:.3f}',f'{c:.3f}',f'{V:.6f}',f'{E0:.7f}']

## check whether the file exists
if not os.path.isfile(output):
    with open(output,'w') as out:       # add header row
        out.writelines("# a c V E0 \n")

    with open(output, 'a') as f:
        writer = csv.writer(f, delimiter='\t')
        writer.writerow(fields)
else:
    with open(output, 'a') as f:
        # writer = csv.DictWriter(f, delimiter='\t')
        writer = csv.writer(f, delimiter='\t')
        writer.writerow(fields)