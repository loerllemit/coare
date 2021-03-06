"""Generates the primitive lattice vectors in hexagonal/trigonal bravais lattice for a given volume to use in VASP POSCAR
Usage: lattice_hex.py (-V <vol>) (-c  <lat_c>)

Options:
-V <vol>     Volume
-c <lat_c>   Initial lattice parameter c

"""
from docopt import docopt
import numpy as np
import math

def writeposcar(a,c,theta):
    positions = f"""LiCaF-lattice
1.0
        {a}                         0.0000000000                0.0000000000
        {a * math.cos(theta)}       {a * math.sin(theta)}       0.0000000000
        0.0000000000                0.0000000000                {c}
   Li   Ca   Al    F
    2    2    2   12
Direct
     0.333333343         0.666666687         0.250000000
     0.666666627         0.333333313         0.750000000
     0.000000000         0.000000000         0.000000000
     0.000000000         0.000000000         0.500000000
     0.666666687         0.333333343         0.250000000
     0.333333313         0.666666627         0.750000000
     0.378760010         0.026930001         0.144260004
     0.621240020         0.973070025         0.855740011
     0.973070025         0.351830006         0.144260004
     0.026930001         0.648169994         0.855740011
     0.648169994         0.621240020         0.144260004
     0.351830006         0.378760010         0.855740011
     0.973070025         0.621240020         0.355740011
     0.026930001         0.378760010         0.644259989
     0.648169994         0.026930001         0.355740011
     0.351830006         0.973070025         0.644259989
     0.378760010         0.351830006         0.355740011
     0.621240020         0.648169994         0.644259989
"""
    return positions

def main():
    arguments = docopt(__doc__,help=True)
    # print(arguments)
    V = float(arguments['-V'])
    c = float(arguments['-c'])
    theta = math.radians(120)
    a = np.sqrt(V / (c * np.sin(theta)))

    with open('POSCAR','w') as out:
        out.writelines(writeposcar(a,c,theta))

if __name__ == '__main__':
    main()