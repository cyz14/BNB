#!/usr/bin/env python

import os

SIZE = 16

def mif_to_matrix(miffile, outfile):
    '''
    WIDTH=3;
    DEPTH=256;

    ADDRESS_RADIX=UNS;
    DATA_RADIX=BIN;

    CONTENT BEGIN
    '''

    fin = open(miffile, 'r')
    fout = open(outfile, 'w')
    
    width = 0
    depth = 0
    while True:
        line = fin.readline()
        
        if len(line) == 0:
            continue
        if line.lower().startswith('end'):
            break
            
        if line.startswith('--'):
            continue
        
        if line.startswith('WIDTH'):
            width = int(line[6:7])
            print 'Width', width
        if line.startswith('DEPTH'):
            depth = int(line.replace(';', '')[6:])
            print 'Depth:', depth
        if line.startswith('ADDRESS_RADIX') or line.startswith('DATA_RADIX'):
            continue
        
        if line.startswith('CONTENT'):
            cnt = 0
            for i in range(depth):
                cnt += 1
                l = fin.readline()
                #print l.replace(';', '').strip().split(' ')
                fout.write(str(int(l.strip().replace(';','').split(' ')[2], 2)))
                if cnt == SIZE:
                    if i == depth - 1:
                        fout.write('\n')
                    else:
                        cnt = 0
                        fout.write(',\n')
                else:
                    fout.write(',')
            break    
            
            
mif_files = ['bubble.mif', 'bubed_dao.mif', 'dizni_16.mif', 'bubed_dizni.mif', 'tree.mif', 'grass.mif', 'stone.mif', 'wood.mif', 'mushroom.mif', 'explo.mif']

img_dir = '../src/img'

def main():
    for i in mif_files:
        path = '/'.join([img_dir, i])
        out = i.replace('.mif', '.rom')
        mif_to_matrix(path, out)
    


if __name__ == '__main__':
    main()