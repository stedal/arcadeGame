#subprocess.Popen(['C:\Program Files\Mozilla Firefox\firefox.exe']) opens the app and continues the script
#subprocess.call(['C:\Program Files\Mozilla Firefox\firefox.exe']) this opens it but doesnt continue the script
print('python runnin script')
import os
import subprocess
import time
filepath = 'C:\\Users\\Stikputt\\Desktop\\Stickputt_STED_181008\\pubstick\\application.windows64\\data1.txt'
num_game_cycles = 4
compare = ''
temp = True
# f = open('C:\\Users\\86mac\\Desktop\\data1.txt', 'r')
# #print(f.read())
# f.seek(0)
# var = f.read()
# f.close()
with open(r'C:\Users\Stikputt\Desktop\Stickputt_STED_181008\pubstick\application.windows64\data1.txt', 'r') as infile, open(r'C:\Users\Stikputt\Desktop\Stickputt_STED_181008\pubstick\application.windows64\data1.txt', 'w') as outfile:
    data = infile.read()
    data = data.replace("1", "0")
    outfile.write(data)
for x in range(num_game_cycles):
    compare += '1'
print('compare is :', compare)
while temp == True:
    print('in while loop')
    # f = open('C:\\Users\\86mac\\Desktop\\data1.txt', 'r')
    # f.seek(0)
    # var = f.read()
    # f.close()
    with open(filepath, 'r') as fp:
       line = fp.readline()
       cnt = 1
       cycles = line.strip()
       while line:
           #print("Line {}: {}".format(cnt, line.strip()))
           line = fp.readline()
           cycles += line.strip()
           cnt += 1
    print('data1 contains: ', cycles)
    time.sleep(1)
    if cycles >= compare:
        time.sleep(9.5)
        os.chdir('C:\\Users\\Stikputt\\Desktop\\Stickputt_STED_181008\\pubstick\\application.windows64\\')
        os.system("C:\\Users\\Stikputt\\Desktop\\Stickputt_STED_181008\\pubstick\\application.windows64\\pubstick.exe")
        with open(r'C:\Users\Stikputt\Desktop\Stickputt_STED_181008\pubstick\application.windows64\data1.txt', 'r') as infile, open(r'C:\Users\Stikputt\Desktop\Stickputt_STED_181008\pubstick\application.windows64\data1.txt', 'w') as outfile:
            data = infile.read()
            data = data.replace("1", "0")
            outfile.write(data)
