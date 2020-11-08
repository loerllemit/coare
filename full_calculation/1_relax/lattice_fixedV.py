"""Generates the primitive lattice vectors in hexagonal/trigonal bravais lattice for a given volume to use in VASP POSCAR
Usage: lattice_fixedV.py (-V <vol>) (-c <lat_c>)

Options:
-V <vol>     Volume
-c <lat_c>   Initial lattice parameter c
"""

from docopt import docopt
import numpy as np
import math

def writeposcar(a,c,theta):
    positions = f"""LiSAF-lattice
1.0
        {a}                         0.0000000000                0.0000000000
        {a * math.cos(theta)}       {a * math.sin(theta)}       0.0000000000
        0.0000000000                0.0000000000                {c}
   Li   Sr   Al    F
    2    2    2   12
Direct
     0.333333324         0.666666648         0.250000000
     0.666666648         0.333333296         0.749999976
     0.000000000         0.000000000         0.000000000
     -0.000000000        -0.000000000         0.500000000
     0.666666662         0.333333324         0.250000000
     0.333333296         0.666666593         0.749999976
     0.378760025         0.026930000         0.144260006
     0.621239986         0.973070022         0.855740041
     0.973070079         0.351829982         0.144260006
     0.026930002         0.648169990         0.855740041
     0.648169974         0.621239985         0.144260006
     0.351830000         0.378759987         0.855740041
     0.973070058         0.621239985         0.355740018
     0.026929987         0.378759987         0.644260006
     0.648169974         0.026930000         0.355740018
     0.351829989         0.973070022         0.644260006
     0.378759999         0.351829982         0.355740018
     0.621240011         0.648169990         0.644260006
"""
    return positions

def main():
    arguments = docopt(__doc__,help=True)
    print(arguments)
    V = float(arguments['-V'])
    c = float(arguments['-c'])
    theta = math.radians(120)
    a = np.sqrt(V / (c * np.sin(theta)))

    with open('POSCAR','w') as out:
        out.writelines(writeposcar(a,c,theta))

if __name__ == '__main__':
    main()
