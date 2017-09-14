#Where net argument is an neurolab.core.Net object
import neurolab as nl
import numpy as np
import json

samples = []
freqs = [82, 110, 147, 196, 247, 330]
for f in freqs:
    filename = './dataset_' + str(f) + 'hz.json'
    print filename, '... reading'
    with open(filename) as data_file:
        data = json.load(data_file)
        samples += data["samples"]

print("Count of samples ", len(samples))

levels = [2.5] #, 2.5, 2.5]

for level in levels:
    x, y = [], []

    balance = 0
    for sample in samples:
        if sample["o"] > level:
            if balance > 10: continue
            y.append([1.0])
            balance += 1
        else:
            if balance < -10: continue
            y.append([0.0])
            balance -= 1

        x.append(map(lambda x: float(x), sample["f"] + [sample["p"]]))

    print "balanced", len(x), len(y)

    x, y = np.array(x), np.array(y)
    print x, y

    m = 11
    net = nl.net.newff([[0.0, 1.0]] * m, [m, 3, 1])

    print("Start training level#", level)
    net.trainf = nl.train.train_gd
    error = net.train(x, y, epochs=2000, show=50, goal=0.001, adapt=True)
    #print(error)

    print("Check network")
    errors = 0
    for sample in samples:
        s = sample["f"] + [sample["p"]]
        r = net.sim(np.array([s]))[0][0]
        #print r, sample["o"]
        if r < 0.5 and sample["o"] < level: continue
        if r >= 0.5 and sample["o"] >= level: continue
        errors += 1

    print "errors:", float(errors) / len(samples)

    def getweights(net):
         vec = []
         for layer in net.layers:
             b = layer.np['b']
             w = layer.np['w']
             newvec = np.ravel(np.concatenate((b, np.ravel(w,order='F'))).reshape((layer.ci+1, layer.cn)), order = 'F')
             [vec.append(nv) for nv in newvec]
         return np.array(vec)

    print(getweights(net))
